"""Mock India CR Analytics data when CSVs are not configured."""
from __future__ import annotations

from datetime import date, timedelta
from typing import Any

import numpy as np
import pandas as pd

USER_TYPES = ["GUEST", "NEW", "RETURNING"]
PLATFORMS = ["android", "ios", "mobile_web", "web_direct"]
LANGUAGES = ["en", "hi", "ta", "te", "kn", "mr"]
REGIONS = [
    "North", "South", "West", "East", "Central",
    "Karnataka", "Tamil Nadu", "Maharashtra", "Delhi NCR", "UP",
]
DBD_BUCKETS = [
    "sameday lmb", "sameday non lmb", "next day", "2 days", "more than 2 days",
]


def _rng(seed: int = 42) -> np.random.Generator:
    return np.random.default_rng(seed)


def generate_main_csv(start: date | None = None, days: int = 46) -> pd.DataFrame:
    """Session-level aggregated grain matching feb_data_check2.csv schema."""
    start = start or date(2026, 2, 1)
    rng = _rng(42)
    rows: list[dict[str, Any]] = []

    # CR baselines by user_type (India-ish)
    cr_base = {"GUEST": 0.018, "NEW": 0.028, "RETURNING": 0.045}
    plat_mult = {"android": 1.0, "ios": 1.12, "mobile_web": 0.85, "web_direct": 0.9}
    lang_share = {"en": 0.42, "hi": 0.28, "ta": 0.1, "te": 0.08, "kn": 0.07, "mr": 0.05}

    for d in range(days):
        dt = start + timedelta(days=d)
        # Sunday dip, festival-ish bump mid window
        dow = dt.weekday()  # Mon=0
        dow_mult = 0.92 if dow == 6 else (1.05 if dow in (4, 5) else 1.0)
        anomaly = 1.0
        if dt in (date(2026, 2, 11), date(2026, 2, 12)):
            anomaly = 1.8  # tentative/error spike
        sl_fail_boost = 3.2 if dt == date(2026, 3, 18) else 1.0
        traffic_boost = 1.25 if d >= 30 else 1.0  # late-window shopper spike

        for ut in USER_TYPES:
            for plat in PLATFORMS:
                for lang, lshare in lang_share.items():
                    base_srp = {
                        "GUEST": 4200, "NEW": 2800, "RETURNING": 3600,
                    }[ut]
                    srp = int(
                        base_srp
                        * plat_mult[plat]
                        * lshare
                        * dow_mult
                        * traffic_boost
                        * rng.uniform(0.85, 1.15)
                    )
                    oops_rate = 0.035 * anomaly * rng.uniform(0.8, 1.2)
                    oops = int(srp * oops_rate)
                    sl = int(srp * (0.42 / anomaly) * rng.uniform(0.9, 1.05))
                    sl_fail = int(sl * 0.03 * sl_fail_boost * rng.uniform(0.7, 1.3))
                    ci = int(sl * 0.55 * rng.uniform(0.9, 1.05))
                    tco = int(ci * 0.72 * rng.uniform(0.9, 1.05))
                    tent_err_rate = 0.04 * anomaly * rng.uniform(0.7, 1.3)
                    tent_err_sess = int(tco * tent_err_rate)
                    total_tent_err = int(tent_err_sess * rng.uniform(1.0, 1.4))
                    pay = int(tco * (1 - tent_err_rate) * 0.88 * rng.uniform(0.9, 1.05))
                    pay_drop = 0.22 * rng.uniform(0.85, 1.2)
                    txns = max(1, int(pay * (1 - pay_drop) * (cr_base[ut] / 0.03) * rng.uniform(0.85, 1.1)))
                    # keep CR roughly coherent with SRP
                    txns = max(1, min(txns, int(srp * cr_base[ut] * plat_mult[plat] * rng.uniform(0.8, 1.15))))
                    seats = int(txns * rng.uniform(1.4, 2.2))
                    gmv = float(seats * rng.uniform(450, 950))
                    discount_txns = int(txns * rng.uniform(0.15, 0.35))
                    reddeal_txns = int(txns * rng.uniform(0.05, 0.18))
                    rows.append({
                        "dt": dt.isoformat(),
                        "user_type": ut.lower(),
                        "language": lang,
                        "platform": plat,
                        "search_sessions": srp,
                        "oops": oops,
                        "seatlayout_sessions": sl,
                        "seatlayout_clicks": int(sl * rng.uniform(1.1, 1.8)),
                        "avg_clicks_per_session": float(rng.uniform(1.1, 1.8)),
                        "seatlayout_failures": sl_fail,
                        "custinfo_sessions": ci,
                        "create_order_sessions": tco,
                        "tentative_error_sessions": tent_err_sess,
                        "total_tentative_errors": total_tent_err,
                        "orderinfo_sessions": pay,
                        "total_payment_attempts": int(pay * rng.uniform(1.0, 1.25)),
                        "total_txns": txns,
                        "total_seats": seats,
                        "discount_txns": discount_txns,
                        "reddeal_txns": reddeal_txns,
                        "GMV": round(gmv, 2),
                        "payment_success_rate": round(1 - pay_drop, 4),
                    })
    return pd.DataFrame(rows)


def generate_slices_csv(start: date | None = None, days: int = 46) -> pd.DataFrame:
    """Route-level slices (intentionally higher counts than main)."""
    start = start or date(2026, 2, 1)
    rng = _rng(7)
    cities = [
        ("Bangalore", "Chennai", "South"),
        ("Mumbai", "Pune", "West"),
        ("Delhi", "Jaipur", "North"),
        ("Hyderabad", "Bangalore", "South"),
        ("Kolkata", "Bhubaneswar", "East"),
        ("Ahmedabad", "Surat", "West"),
        ("Lucknow", "Kanpur", "UP"),
        ("Chennai", "Madurai", "Tamil Nadu"),
    ]
    rows: list[dict[str, Any]] = []
    for d in range(days):
        dt = start + timedelta(days=d)
        for ut in USER_TYPES:
            for plat in ["Android", "iOS", "MOBILE_WEB", "WEB_DIRECT"]:
                for src, dest, region in cities:
                    dbd = DBD_BUCKETS[int(rng.integers(0, len(DBD_BUCKETS)))]
                    srp = int(rng.integers(80, 420))
                    sl = int(srp * rng.uniform(0.35, 0.5))
                    ci = int(sl * rng.uniform(0.5, 0.65))
                    tco = int(ci * rng.uniform(0.65, 0.8))
                    pay = int(tco * rng.uniform(0.75, 0.9))
                    tin = max(1, int(pay * rng.uniform(0.55, 0.85)))
                    seats = int(tin * rng.uniform(1.3, 2.1))
                    gmv = float(seats * rng.uniform(400, 1000))
                    rows.append({
                        "doi": dt.isoformat(),
                        "user_type": ut,
                        "channel": plat,
                        "language": rng.choice(LANGUAGES),
                        "dbd": dbd,
                        "Region_Final": region,
                        "Source": src,
                        "Destination": dest,
                        "SRP": srp,
                        "SL": sl,
                        "Cust_Info": ci,
                        "Create_Order": tco,
                        "Payment_Page": pay,
                        "Order_Confirmed": tin,
                        "tentative_failure": int(tco * rng.uniform(0.02, 0.08)),
                        "SL_Failure": int(sl * rng.uniform(0.01, 0.06)),
                        "seats": seats,
                        "tin": tin,
                        "GMV": round(gmv, 2),
                        "dis_seats": int(seats * rng.uniform(0.1, 0.3)),
                        "dis_tin": int(tin * rng.uniform(0.1, 0.3)),
                    })
    return pd.DataFrame(rows)


def ensure_sample_csvs(data_dir: str) -> tuple[str, str]:
    from pathlib import Path

    p = Path(data_dir)
    p.mkdir(parents=True, exist_ok=True)
    main_path = p / "feb_data_check2.csv"
    slices_path = p / "feb_data_check2_with_moreslices.csv"
    if not main_path.exists():
        generate_main_csv().to_csv(main_path, index=False)
    if not slices_path.exists():
        generate_slices_csv().to_csv(slices_path, index=False)
    return str(main_path), str(slices_path)
