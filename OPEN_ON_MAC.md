# Open CR Analyser on your Mac (no server)

1. Download or checkout this branch.
2. Double-click **`CR_Analyser.html`**
   - or in Terminal: `open CR_Analyser.html`
3. It opens in Chrome/Safari. No Python, no `localhost`, no port 8080.

## Make it LIVE

1. Export the India CR grain CSV (Athena / Unity) — same columns as `data/feb_data_check2.csv`.
2. In the dashboard, click **Load live CSV** and pick that file.
3. Badge turns **LIVE** and KPIs/funnel refresh.

Or embed permanently:

```bash
./scripts/sync-live-athena.sh   # needs AWS_* + ATHENA_OUTPUT
python3 scripts/build_mac_analyser_html.py data/feb_data_check2.csv
open CR_Analyser.html
```

That’s it.
