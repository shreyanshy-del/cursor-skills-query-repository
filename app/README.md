# CR Analyser app (India)

FastAPI + single-file frontend implementing the CR Analytics Assistant Skills log.

```bash
./START_HERE.sh
# http://127.0.0.1:8080
```

Sample CSVs auto-generate under `data/` on first boot. Override with `CSV_DATA_PATH` / `SLICES_DATA_PATH`. Set `ANTHROPIC_API_KEY` for Claude chat (local RCA works without it).
