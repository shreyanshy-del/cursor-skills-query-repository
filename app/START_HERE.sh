#!/usr/bin/env bash
# Start CR Analyser (India) on http://127.0.0.1:8080
set -euo pipefail
ROOT="$(cd "$(dirname "$0")" && pwd)"
cd "$ROOT/backend"
export PATH="${HOME}/.local/bin:${PATH}"
export PYTHONPATH="$ROOT/backend${PYTHONPATH:+:$PYTHONPATH}"

# Free port 8080 if held
if command -v fuser >/dev/null 2>&1; then
  fuser -k 8080/tcp 2>/dev/null || true
elif command -v lsof >/dev/null 2>&1; then
  lsof -ti:8080 | xargs -r kill -9 2>/dev/null || true
fi

python3 - <<'PY'
import importlib
for m in ("fastapi", "uvicorn", "pandas", "numpy", "dotenv"):
    importlib.import_module(m if m != "dotenv" else "dotenv")
print("deps ok")
PY

# Generate sample CSVs on first run via engine import
python3 - <<'PY'
from csv_data_engine import CRDataEngine
e = CRDataEngine()
print("data ready", e.meta()["date_min"], "→", e.meta()["date_max"], "rows", e.meta()["rows_main"])
PY

echo "Starting CR Analyser at http://127.0.0.1:8080"
exec python3 -m uvicorn main:app --host 0.0.0.0 --port 8080 --reload
