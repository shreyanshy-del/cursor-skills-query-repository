"""CR Analyser — India FastAPI backend."""
from __future__ import annotations

import os
import uuid
from pathlib import Path
from typing import Any, Optional

from dotenv import load_dotenv
from fastapi import FastAPI, HTTPException, Query
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import FileResponse
from fastapi.staticfiles import StaticFiles
from pydantic import BaseModel, Field

load_dotenv()

from csv_data_engine import CRDataEngine

ROOT = Path(__file__).resolve().parent.parent
FRONTEND = ROOT / "frontend"

app = FastAPI(title="CR Analyser", version="1.0.0")
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"],
)

engine = CRDataEngine()
CHAT_MEMORY: dict[str, list[dict[str, str]]] = {}


def _filters(
    start_date: Optional[str] = None,
    end_date: Optional[str] = None,
    filter_user_type: Optional[str] = None,
    filter_platform: Optional[str] = None,
    filter_language: Optional[str] = None,
    filter_region: Optional[str] = None,
    filter_dbd: Optional[str] = None,
) -> dict[str, Any]:
    return {
        "start_date": start_date,
        "end_date": end_date,
        "filter_user_type": filter_user_type,
        "filter_platform": filter_platform,
        "filter_language": filter_language,
        # region/dbd reserved for slices endpoints
        "filter_region": filter_region,
        "filter_dbd": filter_dbd,
    }


@app.get("/api/meta")
def meta():
    return engine.meta()


@app.get("/api/kpis")
def kpis(
    start_date: Optional[str] = None,
    end_date: Optional[str] = None,
    filter_user_type: Optional[str] = None,
    filter_platform: Optional[str] = None,
    filter_language: Optional[str] = None,
):
    return engine.kpis(**_filters(start_date, end_date, filter_user_type, filter_platform, filter_language))


@app.get("/api/cr-trend")
def cr_trend(
    start_date: Optional[str] = None,
    end_date: Optional[str] = None,
    breakdown_by: Optional[str] = None,
    filter_user_type: Optional[str] = None,
    filter_platform: Optional[str] = None,
    filter_language: Optional[str] = None,
):
    return engine.cr_trend(
        breakdown_by=breakdown_by,
        **_filters(start_date, end_date, filter_user_type, filter_platform, filter_language),
    )


@app.get("/api/funnel")
def funnel(
    start_date: Optional[str] = None,
    end_date: Optional[str] = None,
    filter_user_type: Optional[str] = None,
    filter_platform: Optional[str] = None,
    filter_language: Optional[str] = None,
):
    return engine.funnel(**_filters(start_date, end_date, filter_user_type, filter_platform, filter_language))


@app.get("/api/dimension/{dim}")
def dimension(
    dim: str,
    start_date: Optional[str] = None,
    end_date: Optional[str] = None,
    filter_user_type: Optional[str] = None,
    filter_platform: Optional[str] = None,
    filter_language: Optional[str] = None,
):
    try:
        return engine.dimension(
            dim,
            **_filters(start_date, end_date, filter_user_type, filter_platform, filter_language),
        )
    except KeyError:
        raise HTTPException(404, f"Unknown dimension: {dim}")


@app.get("/api/insights")
def insights(
    start_date: Optional[str] = None,
    end_date: Optional[str] = None,
    filter_user_type: Optional[str] = None,
    filter_platform: Optional[str] = None,
    filter_language: Optional[str] = None,
):
    return engine.insights(**_filters(start_date, end_date, filter_user_type, filter_platform, filter_language))


@app.get("/api/seats")
def seats(
    start_date: Optional[str] = None,
    end_date: Optional[str] = None,
    filter_user_type: Optional[str] = None,
    filter_platform: Optional[str] = None,
    filter_language: Optional[str] = None,
):
    return engine.seats(**_filters(start_date, end_date, filter_user_type, filter_platform, filter_language))


@app.get("/api/period-comparison")
def period_comparison(
    mode: str = Query("dod", pattern="^(dod|wow_same|wow_7|mom)$"),
    start_date: Optional[str] = None,
    end_date: Optional[str] = None,
    filter_user_type: Optional[str] = None,
    filter_platform: Optional[str] = None,
    filter_language: Optional[str] = None,
):
    return engine.period_comparison(
        mode=mode,
        **_filters(start_date, end_date, filter_user_type, filter_platform, filter_language),
    )


@app.get("/api/wow-chart")
def wow_chart(
    start_date: Optional[str] = None,
    end_date: Optional[str] = None,
    filter_user_type: Optional[str] = None,
    filter_platform: Optional[str] = None,
    filter_language: Optional[str] = None,
):
    return engine.wow_same_day_series(
        **_filters(start_date, end_date, filter_user_type, filter_platform, filter_language)
    )


@app.get("/api/filter-options")
def filter_options():
    return engine.filter_options()


@app.get("/api/transaction-mix")
def transaction_mix(
    start_date: Optional[str] = None,
    end_date: Optional[str] = None,
    filter_user_type: Optional[str] = None,
    filter_platform: Optional[str] = None,
    filter_language: Optional[str] = None,
):
    k = engine.kpis(**_filters(start_date, end_date, filter_user_type, filter_platform, filter_language))
    return {
        "asp": k["asp"],
        "discount_pct": k["discount_pct"],
        "reddeal_pct": k["reddeal_pct"],
    }


@app.get("/api/rca")
def rca(
    start_date: Optional[str] = None,
    end_date: Optional[str] = None,
    filter_user_type: Optional[str] = None,
    filter_platform: Optional[str] = None,
    filter_language: Optional[str] = None,
):
    return engine.rca_snapshot(**_filters(start_date, end_date, filter_user_type, filter_platform, filter_language))


class ChatRequest(BaseModel):
    message: str
    session_id: Optional[str] = None
    start_date: Optional[str] = None
    end_date: Optional[str] = None
    filter_user_type: Optional[str] = None
    filter_platform: Optional[str] = None
    filter_language: Optional[str] = None
    team_context: list[str] = Field(default_factory=list)


@app.post("/api/chat")
def chat(req: ChatRequest):
    sid = req.session_id or str(uuid.uuid4())
    mem = CHAT_MEMORY.setdefault(sid, [])
    filters = _filters(req.start_date, req.end_date, req.filter_user_type, req.filter_platform, req.filter_language)
    snapshot = engine.rca_snapshot(**filters)
    funnel = engine.funnel(**filters)
    insights = engine.insights(**filters)

    api_key = os.environ.get("ANTHROPIC_API_KEY")
    tools_used = ["rca_snapshot", "funnel", "insights"]

    if not api_key:
        # Deterministic local RCA narrative (no Claude)
        sig = snapshot["signal_type"]
        worst = snapshot.get("worst_funnel_step") or {}
        reply = (
            f"**CR Analyser RCA (local)** — signal: **{sig}**\n\n"
            f"- Actual CR: **{snapshot['actual_cr']:.2f}%**\n"
            f"- Mix-expected CR: **{snapshot['expected_cr_mix']:.2f}%**\n"
            f"- Residual gap: **{snapshot['residual_gap_pp']:.2f} pp** "
            f"({'structural/correlation' if abs(snapshot['residual_gap_pp']) <= 0.3 else 'operational/causation'})\n"
            f"- Worst funnel step: **{worst.get('description', 'n/a')}** "
            f"(drop {worst.get('step_drop', 0):.1f}%)\n"
            f"- Oops rate: {snapshot['kpis']['oops_rate']:.2f}% · "
            f"SL fail: {snapshot['kpis']['sl_failure_rate']:.2f}% · "
            f"Tentative error: {snapshot['kpis']['error_rate']:.2f}% · "
            f"Payment drop: {snapshot['kpis']['payment_drop']:.2f}%\n\n"
            f"Identity check product-of-steps ≈ actual CR: "
            f"{'OK' if funnel.get('identity_check', {}).get('ok') else 'CHECK'}.\n\n"
            f"Question: {req.message}"
        )
        if req.team_context:
            reply += "\n\nTeam context considered: " + "; ".join(req.team_context[:5])
        if insights.get("insights"):
            reply += "\n\nAuto-insights: " + "; ".join(
                i["title"] for i in insights["insights"][:4]
            )
    else:
        try:
            import anthropic

            client = anthropic.Anthropic(api_key=api_key)
            system = (
                "You are CR Analyser for redBus India. Use the provided RCA snapshot. "
                "Apply causation vs correlation and the funnel decision tree from Skills. "
                "CR = Transactions/SRP. Be concise and actionable."
            )
            user_payload = (
                f"Team context: {req.team_context}\n"
                f"User question: {req.message}\n"
                f"RCA snapshot JSON: {snapshot}\n"
                f"Funnel: {funnel}\n"
                f"Insights: {insights}"
            )
            messages = mem[-20:] + [{"role": "user", "content": user_payload}]
            msg = client.messages.create(
                model=os.environ.get("ANTHROPIC_MODEL", "claude-sonnet-4-6"),
                max_tokens=1200,
                system=system,
                messages=messages,
            )
            reply = "".join(
                b.text for b in msg.content if getattr(b, "type", None) == "text"
            )
            tools_used.append("anthropic")
        except Exception as exc:  # noqa: BLE001
            reply = f"Claude call failed ({exc}). Falling back.\n\nSignal: {snapshot['signal_type']}, CR={snapshot['actual_cr']:.2f}%"

    mem.append({"role": "user", "content": req.message})
    mem.append({"role": "assistant", "content": reply})
    CHAT_MEMORY[sid] = mem[-30:]
    return {"session_id": sid, "reply": reply, "tools_used": tools_used, "rca": snapshot}


@app.delete("/api/chat/{session_id}")
def clear_chat(session_id: str):
    CHAT_MEMORY.pop(session_id, None)
    return {"ok": True}


@app.get("/")
def index():
    return FileResponse(FRONTEND / "index.html")


if FRONTEND.exists():
    app.mount("/static", StaticFiles(directory=str(FRONTEND)), name="static")
