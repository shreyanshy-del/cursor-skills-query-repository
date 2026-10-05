"""Athena / Trino live pull for CR Analyser dashboard grain."""
from __future__ import annotations

import os
import time
from pathlib import Path
from typing import Optional

import pandas as pd

SQL_PATH = Path(__file__).resolve().parent / "sql" / "live_cr_grain_1d.sql"


def _load_sql(t_start: str, t_end: str) -> str:
    text = SQL_PATH.read_text()
    # Replace the two TIMESTAMP literals in params CTE
    import re

    text = re.sub(
        r"TIMESTAMP '[0-9:\-\s]+' AS t_start",
        f"TIMESTAMP '{t_start}' AS t_start",
        text,
        count=1,
    )
    text = re.sub(
        r"TIMESTAMP '[0-9:\-\s]+' AS t_end",
        f"TIMESTAMP '{t_end}' AS t_end",
        text,
        count=1,
    )
    return text


def athena_available() -> bool:
    try:
        import boto3  # noqa: F401
    except ImportError:
        return False
    return bool(
        os.environ.get("AWS_ACCESS_KEY_ID")
        or os.environ.get("AWS_PROFILE")
        or os.environ.get("AWS_ROLE_ARN")
        or os.path.exists(os.path.expanduser("~/.aws/credentials"))
    )


def run_athena_sql(sql: str) -> pd.DataFrame:
    import boto3

    region = os.environ.get("AWS_REGION", os.environ.get("AWS_DEFAULT_REGION", "ap-south-1"))
    database = os.environ.get("ATHENA_DATABASE", "user_interaction")
    output = os.environ.get("ATHENA_OUTPUT", "s3://aws-athena-query-results/")
    workgroup = os.environ.get("ATHENA_WORKGROUP", "primary")
    client = boto3.client("athena", region_name=region)
    resp = client.start_query_execution(
        QueryString=sql,
        QueryExecutionContext={"Database": database},
        ResultConfiguration={"OutputLocation": output},
        WorkGroup=workgroup,
    )
    qid = resp["QueryExecutionId"]
    while True:
        st = client.get_query_execution(QueryExecutionId=qid)["QueryExecution"]["Status"]["State"]
        if st in ("SUCCEEDED", "FAILED", "CANCELLED"):
            break
        time.sleep(1.5)
    if st != "SUCCEEDED":
        reason = client.get_query_execution(QueryExecutionId=qid)["QueryExecution"]["Status"].get(
            "StateChangeReason", st
        )
        raise RuntimeError(f"Athena query {st}: {reason}")
    # Read results via pandas from S3 path or get_query_results
    paginator = client.get_paginator("get_query_results")
    rows = []
    header = None
    for page in paginator.paginate(QueryExecutionId=qid):
        for i, row in enumerate(page["ResultSet"]["Rows"]):
            vals = [c.get("VarCharValue") for c in row["Data"]]
            if header is None:
                header = vals
                continue
            rows.append(vals)
    return pd.DataFrame(rows, columns=header)


def sync_live_main_csv(
    out_path: str,
    t_start: str,
    t_end: str,
) -> str:
    """Pull live grain and write dashboard CSV. Requires Athena credentials."""
    if not athena_available():
        raise RuntimeError(
            "Live Athena credentials not configured. Set AWS_ACCESS_KEY_ID/SECRET "
            "(or AWS_PROFILE), ATHENA_OUTPUT (s3://...), and optionally ATHENA_DATABASE / AWS_REGION."
        )
    sql = _load_sql(t_start, t_end)
    df = run_athena_sql(sql)
    Path(out_path).parent.mkdir(parents=True, exist_ok=True)
    df.to_csv(out_path, index=False)
    # marker
    Path(out_path).with_suffix(".live.json").write_text(
        f'{{"mode":"live","t_start":"{t_start}","t_end":"{t_end}","rows":{len(df)}}}\n'
    )
    return out_path


def data_mode() -> str:
    if os.environ.get("CSV_DATA_PATH") and Path(os.environ["CSV_DATA_PATH"]).exists():
        marker = Path(os.environ["CSV_DATA_PATH"]).with_suffix(".live.json")
        if marker.exists() or os.environ.get("CR_DATA_MODE") == "live":
            return "live"
        return "csv"
    if os.environ.get("CR_DATA_MODE") == "live":
        return "live"
    return "sample"
