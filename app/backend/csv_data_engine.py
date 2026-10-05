"""CSV / mock analytics engine for India CR Analyser."""
from __future__ import annotations

import os
from datetime import datetime, timedelta
from typing import Any, Optional

import numpy as np
import pandas as pd

from mock_data import ensure_sample_csvs

FUNNEL_STEPS = [
    ("SRP", "search_sessions", None, "SRP Sessions"),
    ("SL", "seatlayout_sessions", "search_sessions", "SRP to SL"),
    ("CI", "custinfo_sessions", "seatlayout_sessions", "SL to CI"),
    ("TCO", "create_order_sessions", "custinfo_sessions", "CI to TCO"),
    ("PAY", "orderinfo_sessions", "create_order_sessions", "TCO to PAY"),
    ("TXN", "total_txns", "orderinfo_sessions", "PAY to Confirm"),
]


def _parse_dates(series: pd.Series) -> pd.Series:
    sample = str(series.dropna().iloc[0]) if len(series.dropna()) else ""
    if "/" in sample:
        # DD/MM/YYYY
        return pd.to_datetime(series, dayfirst=True, errors="coerce")
    return pd.to_datetime(series, errors="coerce")


def _clean(obj: Any) -> Any:
    if isinstance(obj, dict):
        return {k: _clean(v) for k, v in obj.items()}
    if isinstance(obj, list):
        return [_clean(v) for v in obj]
    if isinstance(obj, (np.floating, float)):
        v = float(obj)
        return None if np.isnan(v) else round(v, 6)
    if isinstance(obj, (np.integer, int)):
        return int(obj)
    if isinstance(obj, (np.bool_, bool)):
        return bool(obj)
    if pd.isna(obj):
        return None
    return obj


class CRDataEngine:
    def __init__(self, main_path: Optional[str] = None, slices_path: Optional[str] = None):
        data_dir = os.environ.get("CR_DATA_DIR", os.path.join(os.path.dirname(__file__), "..", "data"))
        if not main_path:
            main_path = os.environ.get("CSV_DATA_PATH")
        if not slices_path:
            slices_path = os.environ.get("SLICES_DATA_PATH")
        if not main_path or not os.path.exists(main_path or ""):
            main_path, slices_path = ensure_sample_csvs(data_dir)
        self.main_path = main_path
        self.slices_path = slices_path
        self.df = self._load_main(main_path)
        self.slices = self._load_slices(slices_path) if slices_path and os.path.exists(slices_path) else None

    def _load_main(self, path: str) -> pd.DataFrame:
        df = pd.read_csv(path)
        df["dt"] = _parse_dates(df["dt"])
        df = df.dropna(subset=["dt"])
        for c in df.columns:
            if c in ("dt", "user_type", "language", "platform"):
                continue
            df[c] = pd.to_numeric(df[c], errors="coerce")
        df["user_type"] = df["user_type"].astype(str).str.lower()
        df["platform"] = df["platform"].astype(str).str.lower()
        df["language"] = df["language"].astype(str).str.lower()
        # drop noisy languages
        lang_srp = df.groupby("language")["search_sessions"].sum()
        keep = lang_srp[lang_srp >= lang_srp.sum() * 0.0005].index
        df = df[df["language"].isin(keep)]
        return df

    def _load_slices(self, path: str) -> pd.DataFrame:
        df = pd.read_csv(path)
        df["doi"] = _parse_dates(df["doi"])
        df = df.dropna(subset=["doi"])
        for c in ("SRP", "SL", "Cust_Info", "Create_Order", "Payment_Page", "Order_Confirmed",
                  "tentative_failure", "SL_Failure", "seats", "tin", "GMV", "dis_seats", "dis_tin"):
            if c in df.columns:
                df[c] = pd.to_numeric(df[c], errors="coerce").fillna(0)
        return df

    def meta(self) -> dict:
        dmin, dmax = self.df["dt"].min(), self.df["dt"].max()
        return _clean({
            "geo": "IN",
            "product": "CR Analyser",
            "date_min": dmin.date().isoformat(),
            "date_max": dmax.date().isoformat(),
            "days": int((dmax - dmin).days + 1),
            "rows_main": int(len(self.df)),
            "rows_slices": int(len(self.slices)) if self.slices is not None else 0,
            "anomaly_dates": ["2026-02-11", "2026-02-12", "2026-03-18"],
            "source_main": self.main_path,
            "source_slices": self.slices_path,
            "cr_definition": "total_txns / search_sessions",
        })

    def _filter(
        self,
        start_date: Optional[str] = None,
        end_date: Optional[str] = None,
        filter_user_type: Optional[str] = None,
        filter_platform: Optional[str] = None,
        filter_language: Optional[str] = None,
        **_ignored: Any,
    ) -> pd.DataFrame:
        df = self.df
        if start_date:
            df = df[df["dt"] >= pd.to_datetime(start_date)]
        if end_date:
            df = df[df["dt"] <= pd.to_datetime(end_date)]
        if filter_user_type:
            vals = [v.strip().lower() for v in filter_user_type.split(",")]
            df = df[df["user_type"].isin(vals)]
        if filter_platform:
            vals = [v.strip().lower() for v in filter_platform.split(",")]
            df = df[df["platform"].isin(vals)]
        if filter_language:
            vals = [v.strip().lower() for v in filter_language.split(",")]
            df = df[df["language"].isin(vals)]
        return df

    def _agg(self, df: pd.DataFrame) -> dict[str, float]:
        if df.empty:
            return {k: 0 for _, k, _, _ in FUNNEL_STEPS} | {
                "oops": 0, "seatlayout_failures": 0, "tentative_error_sessions": 0,
                "total_tentative_errors": 0, "total_seats": 0, "GMV": 0,
                "discount_txns": 0, "reddeal_txns": 0,
            }
        cols = [
            "search_sessions", "oops", "seatlayout_sessions", "seatlayout_failures",
            "custinfo_sessions", "create_order_sessions", "tentative_error_sessions",
            "total_tentative_errors", "orderinfo_sessions", "total_txns", "total_seats",
            "GMV", "discount_txns", "reddeal_txns",
        ]
        out = {c: float(df[c].sum()) for c in cols if c in df.columns}
        return out

    def _metrics(self, a: dict[str, float]) -> dict[str, Any]:
        srp = a.get("search_sessions", 0) or 0
        txn = a.get("total_txns", 0) or 0
        pay = a.get("orderinfo_sessions", 0) or 0
        tco = a.get("create_order_sessions", 0) or 0
        sl = a.get("seatlayout_sessions", 0) or 0
        seats = a.get("total_seats", 0) or 0
        gmv = a.get("GMV", 0) or 0
        cr = (100.0 * txn / srp) if srp else 0.0
        oops_rate = (100.0 * a.get("oops", 0) / srp) if srp else 0.0
        sl_fail = (100.0 * a.get("seatlayout_failures", 0) / sl) if sl else 0.0
        tent = (100.0 * a.get("total_tentative_errors", 0) / tco) if tco else 0.0
        pay_drop = (100.0 * (1 - (txn / pay))) if pay else 0.0
        asp = (gmv / seats) if seats else 0.0
        avg_seats = (seats / txn) if txn else 1.5
        err_sess = a.get("tentative_error_sessions", 0) + a.get("seatlayout_failures", 0)
        seats_lost = err_sess * avg_seats
        discount_pct = (100.0 * a.get("discount_txns", 0) / txn) if txn else 0.0
        reddeal_pct = (100.0 * a.get("reddeal_txns", 0) / txn) if txn else 0.0
        return {
            "cr": cr,
            "srp": srp,
            "bookings": txn,
            "error_rate": tent,
            "payment_drop": pay_drop,
            "seats_booked": seats,
            "seats_lost": seats_lost,
            "oops_rate": oops_rate,
            "sl_failure_rate": sl_fail,
            "asp": asp,
            "discount_pct": discount_pct,
            "reddeal_pct": reddeal_pct,
            "raw": a,
        }

    def kpis(self, **filters) -> dict:
        df = self._filter(**filters)
        m = self._metrics(self._agg(df))
        # DoD vs previous equal-length window ending day before start
        start = filters.get("start_date")
        end = filters.get("end_date")
        if end:
            end_d = pd.to_datetime(end)
            start_d = pd.to_datetime(start) if start else end_d
            span = (end_d - start_d).days + 1
            prev_end = (start_d - timedelta(days=1)).date().isoformat()
            prev_start = (start_d - timedelta(days=span)).date().isoformat()
            prev = self._metrics(self._agg(self._filter(
                start_date=prev_start, end_date=prev_end,
                filter_user_type=filters.get("filter_user_type"),
                filter_platform=filters.get("filter_platform"),
                filter_language=filters.get("filter_language"),
            )))
        else:
            prev = {k: 0 for k in m if k != "raw"}

        def delta(cur, old):
            if not old:
                return None
            return 100.0 * (cur - old) / abs(old)

        cards = []
        mapping = [
            ("Conv. Rate", "cr", "%", True),
            ("SRP Sessions", "srp", "", True),
            ("Bookings", "bookings", "", True),
            ("Error Rate", "error_rate", "%", False),
            ("Payment Drop", "payment_drop", "%", False),
            ("Seats Booked", "seats_booked", "", True),
            ("Seats Lost (est.)", "seats_lost", "", False),
        ]
        for label, key, unit, higher_better in mapping:
            cards.append({
                "label": label,
                "key": key,
                "value": m[key],
                "prev": prev.get(key),
                "delta_pct": delta(m[key], prev.get(key) or 0),
                "unit": unit,
                "higher_better": higher_better,
            })
        return _clean({"metrics": m, "cards": cards, "asp": m["asp"], "discount_pct": m["discount_pct"], "reddeal_pct": m["reddeal_pct"]})

    def cr_trend(self, breakdown_by: Optional[str] = None, **filters) -> dict:
        df = self._filter(**filters)
        if df.empty:
            return _clean({"series": [], "anomaly_dates": self.meta()["anomaly_dates"]})
        if breakdown_by in ("user_type", "platform", "language"):
            g = df.groupby(["dt", breakdown_by], as_index=False).agg(
                search_sessions=("search_sessions", "sum"),
                total_txns=("total_txns", "sum"),
            )
            series = []
            for dim_val, part in g.groupby(breakdown_by):
                part = part.sort_values("dt")
                series.append({
                    "name": str(dim_val),
                    "points": [
                        {
                            "date": r.dt.date().isoformat(),
                            "cr": 100.0 * r.total_txns / r.search_sessions if r.search_sessions else 0,
                            "bookings": int(r.total_txns),
                            "srp": int(r.search_sessions),
                        }
                        for r in part.itertuples()
                    ],
                })
            return _clean({"series": series, "anomaly_dates": self.meta()["anomaly_dates"]})

        g = df.groupby("dt", as_index=False).agg(
            search_sessions=("search_sessions", "sum"),
            total_txns=("total_txns", "sum"),
            tentative_error_sessions=("tentative_error_sessions", "sum"),
            create_order_sessions=("create_order_sessions", "sum"),
        ).sort_values("dt")
        points = []
        for r in g.itertuples():
            points.append({
                "date": r.dt.date().isoformat(),
                "cr": 100.0 * r.total_txns / r.search_sessions if r.search_sessions else 0,
                "bookings": int(r.total_txns),
                "srp": int(r.search_sessions),
                "error_rate": 100.0 * r.tentative_error_sessions / r.create_order_sessions if r.create_order_sessions else 0,
            })
        return _clean({"series": [{"name": "Overall", "points": points}], "anomaly_dates": self.meta()["anomaly_dates"]})

    def funnel(self, **filters) -> dict:
        a = self._agg(self._filter(**filters))
        steps = []
        srp = a.get("search_sessions", 0) or 0
        for name, col, parent, desc in FUNNEL_STEPS:
            val = a.get(col, 0) or 0
            parent_val = a.get(parent, 0) if parent else None
            step_cr = (100.0 * val / parent_val) if parent and parent_val else 100.0
            drop = 100.0 - step_cr if parent else 0.0
            cum = (100.0 * val / srp) if srp else 0.0
            steps.append({
                "stage": name,
                "description": desc,
                "sessions": val,
                "step_cr": step_cr,
                "step_drop": drop,
                "cumulative_cr": cum,
            })
        # product identity check (assistant funnel without PAY_NOW split)
        product = 1.0
        for s in steps[1:]:
            product *= (s["step_cr"] / 100.0)
        identity_cr = 100.0 * product
        actual_cr = steps[-1]["cumulative_cr"]
        return _clean({
            "steps": steps,
            "identity_check": {
                "product_of_steps_pct": identity_cr,
                "actual_cr_pct": actual_cr,
                "ok": abs(identity_cr - actual_cr) < 0.05,
            },
        })

    def dimension(self, dim: str, **filters) -> dict:
        dim = dim.lower()
        if dim in ("region", "dbd") and self.slices is not None:
            return self._dimension_slices(dim, **filters)
        if dim not in ("user_type", "platform", "language", "os"):
            if dim == "os":
                dim = "platform"
            else:
                raise KeyError(dim)
        df = self._filter(**filters)
        rows = []
        for val, part in df.groupby(dim):
            m = self._metrics(self._agg(part))
            rows.append({
                "segment": str(val),
                "cr": m["cr"],
                "srp": m["srp"],
                "bookings": m["bookings"],
                "error_rate": m["error_rate"],
                "payment_drop": m["payment_drop"],
                "asp": m["asp"],
            })
        rows.sort(key=lambda r: r["srp"], reverse=True)
        return _clean({"dimension": dim, "rows": rows})

    def _dimension_slices(self, dim: str, **filters) -> dict:
        df = self.slices.copy()
        start, end = filters.get("start_date"), filters.get("end_date")
        if start:
            df = df[df["doi"] >= pd.to_datetime(start)]
        if end:
            df = df[df["doi"] <= pd.to_datetime(end)]
        if filters.get("filter_user_type"):
            vals = [v.strip().upper() for v in filters["filter_user_type"].split(",")]
            df = df[df["user_type"].str.upper().isin(vals)]
        key = "Region_Final" if dim == "region" else "dbd"
        rows = []
        for val, part in df.groupby(key):
            srp = float(part["SRP"].sum())
            tin = float(part["tin"].sum())
            seats = float(part["seats"].sum())
            gmv = float(part["GMV"].sum())
            sl = float(part["SL"].sum())
            rows.append({
                "segment": str(val),
                "cr": 100.0 * tin / srp if srp else 0,
                "srp": srp,
                "bookings": tin,
                "error_rate": 100.0 * part["tentative_failure"].sum() / part["Create_Order"].sum() if part["Create_Order"].sum() else 0,
                "payment_drop": 100.0 * (1 - tin / part["Payment_Page"].sum()) if part["Payment_Page"].sum() else 0,
                "asp": gmv / seats if seats else 0,
                "discount_pct": 100.0 * part["dis_tin"].sum() / tin if tin else 0,
                "sl_failure_rate": 100.0 * part["SL_Failure"].sum() / sl if sl else 0,
            })
        rows.sort(key=lambda r: r["srp"], reverse=True)
        return _clean({"dimension": dim, "rows": rows, "note": "slices grain — use CR% and shares, not absolute vs main"})

    def insights(self, **filters) -> dict:
        trend = self.cr_trend(**filters)
        points = trend["series"][0]["points"] if trend["series"] else []
        if len(points) < 5:
            return _clean({"insights": []})
        crs = np.array([p["cr"] for p in points], dtype=float)
        mean, std = float(crs.mean()), float(crs.std() or 1e-6)
        insights = []
        for p in points:
            if p["cr"] > mean + 1.8 * std:
                insights.append({"severity": "positive", "title": f"CR spike on {p['date']}", "detail": f"CR {p['cr']:.2f}% vs mean {mean:.2f}%"})
            if p["cr"] < mean - 1.8 * std:
                insights.append({"severity": "critical", "title": f"CR drop on {p['date']}", "detail": f"CR {p['cr']:.2f}% vs mean {mean:.2f}%"})
        # rolling 7d
        if len(crs) >= 14:
            recent = crs[-7:].mean()
            prior = crs[-14:-7].mean()
            if recent < prior - 0.15:
                insights.append({"severity": "warning", "title": "7-day CR softening", "detail": f"Recent 7d avg {recent:.2f}% vs prior {prior:.2f}%"})
            elif recent > prior + 0.15:
                insights.append({"severity": "positive", "title": "7-day CR improving", "detail": f"Recent 7d avg {recent:.2f}% vs prior {prior:.2f}%"})
        # error anomalies
        for d in self.meta()["anomaly_dates"]:
            insights.append({"severity": "warning", "title": f"Known anomaly window {d}", "detail": "Historic error / SL failure spike date from Skills log"})
        return _clean({"insights": insights[:12]})

    def seats(self, **filters) -> dict:
        df = self._filter(**filters)
        by_ut = []
        for ut, part in df.groupby("user_type"):
            m = self._metrics(self._agg(part))
            by_ut.append({
                "user_type": ut,
                "seats_booked": m["seats_booked"],
                "seats_lost": m["seats_lost"],
                "error_sessions": m["raw"].get("tentative_error_sessions", 0) + m["raw"].get("seatlayout_failures", 0),
                "loss_rate": 100.0 * m["seats_lost"] / (m["seats_booked"] + m["seats_lost"]) if (m["seats_booked"] + m["seats_lost"]) else 0,
            })
        daily = []
        for dt, part in df.groupby("dt"):
            m = self._metrics(self._agg(part))
            daily.append({"date": dt.date().isoformat(), "booked": m["seats_booked"], "lost": m["seats_lost"]})
        daily.sort(key=lambda x: x["date"])
        return _clean({"by_user_type": by_ut, "daily": daily})

    def period_comparison(self, mode: str = "dod", **filters) -> dict:
        meta = self.meta()
        end = pd.to_datetime(filters.get("end_date") or meta["date_max"])
        if mode == "dod":
            cur_start = cur_end = end
            prev_start = prev_end = end - timedelta(days=1)
            label = "Day-over-Day"
        elif mode == "wow_same":
            cur_start = cur_end = end
            prev_start = prev_end = end - timedelta(days=7)
            label = "WoW Same Day"
        elif mode == "wow_7":
            cur_end = end
            cur_start = end - timedelta(days=6)
            prev_end = cur_start - timedelta(days=1)
            prev_start = prev_end - timedelta(days=6)
            label = "WoW 7-Day"
        else:  # mom
            cur_end = end
            day = end.day
            cur_start = end.replace(day=1)
            prev_month_end = cur_start - timedelta(days=1)
            prev_start = (prev_month_end.replace(day=1))
            prev_end = min(prev_month_end, prev_start + timedelta(days=day - 1))
            label = "Month-over-Month"

        def pack(s, e):
            return self._metrics(self._agg(self._filter(
                start_date=s.date().isoformat(), end_date=e.date().isoformat(),
                filter_user_type=filters.get("filter_user_type"),
                filter_platform=filters.get("filter_platform"),
                filter_language=filters.get("filter_language"),
            )))

        cur, prev = pack(cur_start, cur_end), pack(prev_start, prev_end)
        keys = [
            ("Conv. Rate", "cr", "%", True),
            ("SRP Sessions", "srp", "", True),
            ("Bookings", "bookings", "", True),
            ("Error Rate", "error_rate", "%", False),
            ("Payment Drop", "payment_drop", "%", False),
            ("Seats Booked", "seats_booked", "", True),
            ("Seats Lost", "seats_lost", "", False),
        ]
        grid = []
        for name, k, unit, hb in keys:
            c, p = cur[k], prev[k]
            grid.append({
                "label": name,
                "current": c,
                "previous": p,
                "delta_pct": 100.0 * (c - p) / abs(p) if p else None,
                "unit": unit,
                "higher_better": hb,
            })
        return _clean({
            "mode": mode,
            "label": label,
            "current_range": [cur_start.date().isoformat(), cur_end.date().isoformat()],
            "previous_range": [prev_start.date().isoformat(), prev_end.date().isoformat()],
            "grid": grid,
        })

    def filter_options(self) -> dict:
        return _clean({
            "user_type": sorted(self.df["user_type"].dropna().unique().tolist()),
            "platform": sorted(self.df["platform"].dropna().unique().tolist()),
            "language": sorted(self.df["language"].dropna().unique().tolist()),
            "region": sorted(self.slices["Region_Final"].dropna().unique().tolist()) if self.slices is not None else [],
            "dbd": sorted(self.slices["dbd"].dropna().unique().tolist()) if self.slices is not None else [],
        })

    def wow_same_day_series(self, **filters) -> dict:
        meta = self.meta()
        end = pd.to_datetime(filters.get("end_date") or meta["date_max"])
        start = pd.to_datetime(filters.get("start_date") or (end - timedelta(days=13)).date().isoformat())
        cur = self.cr_trend(start_date=start.date().isoformat(), end_date=end.date().isoformat(),
                            filter_user_type=filters.get("filter_user_type"),
                            filter_platform=filters.get("filter_platform"),
                            filter_language=filters.get("filter_language"))
        pts = cur["series"][0]["points"] if cur["series"] else []
        prior = []
        for p in pts:
            d = pd.to_datetime(p["date"]) - timedelta(days=7)
            day = self._filter(start_date=d.date().isoformat(), end_date=d.date().isoformat(),
                               filter_user_type=filters.get("filter_user_type"),
                               filter_platform=filters.get("filter_platform"),
                               filter_language=filters.get("filter_language"))
            m = self._metrics(self._agg(day))
            prior.append({"date": p["date"], "cr": m["cr"]})
        return _clean({"current": pts, "prior_week": prior})

    def rca_snapshot(self, **filters) -> dict:
        """Lightweight RCA payload for chat / narratives."""
        k = self.kpis(**filters)
        f = self.funnel(**filters)
        dim_ut = self.dimension("user_type", **filters)
        # mix-shift expected CR vs last week
        meta = self.meta()
        end = pd.to_datetime(filters.get("end_date") or meta["date_max"])
        start = pd.to_datetime(filters.get("start_date") or end.date().isoformat())
        prev_filters = dict(filters)
        span = (end - start).days + 1
        prev_filters["end_date"] = (start - timedelta(days=1)).date().isoformat()
        prev_filters["start_date"] = (start - timedelta(days=span)).date().isoformat()
        prev_dim = self.dimension("user_type", **prev_filters)
        prev_map = {r["segment"]: r for r in prev_dim["rows"]}
        cur_rows = dim_ut["rows"]
        total_srp = sum(r["srp"] for r in cur_rows) or 1
        expected = 0.0
        for r in cur_rows:
            share = r["srp"] / total_srp
            base_cr = prev_map.get(r["segment"], {}).get("cr", r["cr"])
            expected += share * base_cr
        actual = k["metrics"]["cr"]
        gap = actual - expected
        signal = "correlation" if abs(gap) <= 0.3 else "causation"
        worst = max(f["steps"][1:], key=lambda s: s["step_drop"]) if len(f["steps"]) > 1 else None
        return _clean({
            "actual_cr": actual,
            "expected_cr_mix": expected,
            "residual_gap_pp": gap,
            "signal_type": signal,
            "worst_funnel_step": worst,
            "kpis": k["metrics"],
            "funnel": f["steps"],
            "user_type_mix": cur_rows,
        })
