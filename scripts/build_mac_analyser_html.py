#!/usr/bin/env python3
"""Embed a grain CSV into CR_Analyser.html (Mac LIVE refresh without a server)."""
from __future__ import annotations

import csv
import json
import re
import sys
from collections import defaultdict
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
HTML = ROOT / "CR_Analyser.html"


def grain_to_data(rows):
    skip = {"dt", "user_type", "language", "platform"}
    num_keys = [k for k in rows[0].keys() if k not in skip]

    def group(key_fn, labels):
        bags = defaultdict(lambda: defaultdict(float))
        meta = {}
        for r in rows:
            key = key_fn(r)
            meta[key] = {lk: r[lk] for lk in labels}
            for nk in num_keys:
                try:
                    bags[key][nk] += float(r.get(nk) or 0)
                except ValueError:
                    pass
        out = []
        for key in sorted(bags):
            out.append({**meta[key], **{k: bags[key][k] for k in num_keys}})
        return out

    return {
        "days": group(lambda r: r["dt"], ["dt"]),
        "by_user_type": group(lambda r: r["user_type"], ["user_type"]),
        "by_platform": group(lambda r: r["platform"], ["platform"]),
        "by_language": group(lambda r: r["language"], ["language"]),
    }


def main():
    csv_path = Path(sys.argv[1] if len(sys.argv) > 1 else ROOT / "data" / "feb_data_check2.csv")
    rows = list(csv.DictReader(csv_path.open()))
    data = grain_to_data(rows)
    html = HTML.read_text()
    new = re.sub(
        r"let DATA = \{.*?\};",
        "let DATA = " + json.dumps(data, separators=(",", ":")) + ";",
        html,
        count=1,
        flags=re.S,
    )
    if new == html:
        raise SystemExit("Could not find DATA assignment in CR_Analyser.html")
    HTML.write_text(new)
    print(f"embedded {csv_path} → {HTML} ({len(data['days'])} days)")


if __name__ == "__main__":
    main()
