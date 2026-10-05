# CR Analytics

**India BUS Conversion Rate Analyser** — dashboard + Cursor skills.

## Quick start

```bash
./START_HERE.sh
# → http://127.0.0.1:8080
```

## Layout

```
backend/     FastAPI APIs + live Athena sync
frontend/    Single-file dashboard UI
skills/      cr-analyser, cr-dim-*, cr-analytics-assistant, domain packs
scripts/     install-cursor-skills.sh, sync-live-athena.sh
SKILLS.md    Product / RCA feature log (India)
Skills_CR.md Skill catalog
LIVE_DATA.md How to wire Unity / Athena live data
```

## Contracts

CR = TIN / SRP · funnel SRP→SL→CI→TCO→PAY→PAY_NOW→CONFIRM · `mri_session_id` · BTE 101/2 · IND

## Live data

See [`LIVE_DATA.md`](LIVE_DATA.md). Cloud agents need Athena credentials or Cursor-desktop Unity-india MCP.

## Install skills

```bash
./scripts/install-cursor-skills.sh
```
