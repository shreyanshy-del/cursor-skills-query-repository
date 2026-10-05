# CR Analyser — Live Data

## What’s ready

| Piece | Path |
|---|---|
| Full app | `/home/ubuntu/cr-analytics` (also `app/` on PRs) |
| Core SQL skill | `skills/cr-analyser` |
| Live grain SQL | `backend/sql/live_cr_grain_1d.sql` |
| Athena sync | `scripts/sync-live-athena.sh` |
| Skills / RCA log | `SKILLS.md` / `skills/cr-analytics-assistant` |
| Catalog | `Skills_CR.md` |

## Live data blockers on this Cloud Agent

This cloud VM **cannot** pull Unity / Iceberg live today:

1. **Unity-india MCP** — local-only (Cursor desktop); auth URL unavailable on cloud
2. **Athena** — no `AWS_*` credentials / profile in the environment

Egress is open; once credentials exist, sync works.

## How to run with live data

### Option A — Athena (recommended for cloud)

```bash
export AWS_ACCESS_KEY_ID=...
export AWS_SECRET_ACCESS_KEY=...
export AWS_REGION=ap-south-1
export ATHENA_OUTPUT=s3://<your-athena-results-bucket>/
# optional: ATHENA_DATABASE, ATHENA_WORKGROUP

cd /home/ubuntu/cr-analytics
pip3 install boto3
./scripts/sync-live-athena.sh                 # yesterday IST day
# or: ./scripts/sync-live-athena.sh '2026-10-03 18:30:00' '2026-10-04 18:30:00'

export CSV_DATA_PATH=/home/ubuntu/cr-analytics/data/feb_data_check2.csv
export CR_DATA_MODE=live
./START_HERE.sh
```

UI header shows **LIVE** when `data_mode=live`.

### Option B — Cursor desktop + Unity-india MCP

Run the same `live_cr_grain_1d.sql` (or `skills/cr-analyser/references/cr_analyser_1d.sql`) via Unity, export CSV into `CSV_DATA_PATH`, restart the app.

### Option C — Drop your own export

Place a CSV matching the Skills schema at `CSV_DATA_PATH` and restart.

## Contracts (unchanged)

CR = TIN / SRP · steps SRP→SL→CI→TCO→PAY→PAY_NOW→CONFIRM · `mri_session_id` · BTE 101/2 · IND
