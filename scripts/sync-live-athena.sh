#!/usr/bin/env bash
# Pull live India CR grain from Athena into data/feb_data_check2.csv
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT/backend"
export PATH="${HOME}/.local/bin:${PATH}"
export PYTHONPATH="$ROOT/backend${PYTHONPATH:+:$PYTHONPATH}"

# Default: yesterday IST day in UTC walls
T_START="${1:-}"
T_END="${2:-}"
OUT="${3:-$ROOT/data/feb_data_check2.csv}"

python3 - <<PY
import os
from datetime import datetime, timedelta, timezone
from live_athena import sync_live_main_csv, athena_available

t_start = os.environ.get("T_START") or "${T_START}"
t_end = os.environ.get("T_END") or "${T_END}"
out = "${OUT}"

if not t_start or not t_end:
    # Approximate: last completed IST day = UTC [D-1 18:30, D 18:30)
    now = datetime.now(timezone.utc)
    # floor to today 18:30 UTC boundary
    end = now.replace(hour=18, minute=30, second=0, microsecond=0)
    if now < end:
        end = end - timedelta(days=1)
    start = end - timedelta(days=1)
    t_start, t_end = start.strftime("%Y-%m-%d %H:%M:%S"), end.strftime("%Y-%m-%d %H:%M:%S")

print("athena_available=", athena_available())
print("window", t_start, "→", t_end)
path = sync_live_main_csv(out, t_start, t_end)
os.environ["CR_DATA_MODE"] = "live"
print("wrote", path)
PY

echo "Set CSV_DATA_PATH=$OUT CR_DATA_MODE=live and restart START_HERE.sh"
