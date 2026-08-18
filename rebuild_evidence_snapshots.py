from __future__ import annotations

import argparse
import csv
import hashlib
import json
import time
import urllib.error
import urllib.parse
import urllib.request
from datetime import datetime
from pathlib import Path
from typing import Any


DEFAULT_DATA_FILE = Path("india_scope_candidate_pages.jsonl")
MAX_BYTES = 3_000_000
USER_AGENT = (
    "Mozilla/5.0 (Windows NT 10.0; Win64; x64) "
    "AppleWebKit/537.36 (KHTML, like Gecko) "
    "Chrome/126.0 Safari/537.36"
)


def load_rows(path: Path) -> list[dict[str, Any]]:
    return [json.loads(line) for line in path.read_text(encoding="utf-8").splitlines() if line.strip()]


def fetch_url(url: str, timeout_seconds: int) -> tuple[int | str, str, bytes]:
    request = urllib.request.Request(url, headers={"User-Agent": USER_AGENT, "Accept": "text/html,*/*;q=0.8"})
    with urllib.request.urlopen(request, timeout=timeout_seconds) as response:  # noqa: S310 - user-provided public URLs for evidence rebuild
        status = getattr(response, "status", "")
        final_url = response.geturl()
        data = response.read(MAX_BYTES)
    return status, final_url, data


def row_url(row: dict[str, Any]) -> str:
    return str(row.get("final_url") or row.get("candidate_url") or "").strip()


def should_download(row: dict[str, Any], only_action: bool) -> bool:
    if not only_action:
        return True
    return str(row.get("action") or row.get("review_priority") or "") not in {"", "no_immediate_signal", "No immediate action"}


def rebuild_snapshots(
    data_file: Path,
    output_dir: Path,
    timeout_seconds: int,
    delay_seconds: float,
    overwrite: bool,
    only_action: bool,
) -> dict[str, Any]:
    rows = load_rows(data_file)
    snapshot_dir = output_dir / "evidence_snapshots"
    snapshot_dir.mkdir(parents=True, exist_ok=True)
    log_path = output_dir / "rebuild_snapshot_log.csv"

    attempted = 0
    skipped = 0
    saved = 0
    failed = 0

    with log_path.open("w", newline="", encoding="utf-8") as handle:
        writer = csv.DictWriter(
            handle,
            fieldnames=[
                "serial_no",
                "snapshot_file",
                "source_url",
                "result",
                "http_status",
                "saved_bytes",
                "original_sha256",
                "rebuilt_sha256",
                "rebuilt_at",
                "note",
            ],
        )
        writer.writeheader()

        for row in rows:
            snapshot_file = str(row.get("snapshot_file", "")).replace("\\", "/")
            source_url = row_url(row)
            target = output_dir / snapshot_file
            if not snapshot_file or not source_url:
                skipped += 1
                continue
            if not should_download(row, only_action):
                skipped += 1
                continue
            if target.exists() and not overwrite:
                skipped += 1
                writer.writerow(
                    {
                        "serial_no": row.get("serial_no", ""),
                        "snapshot_file": snapshot_file,
                        "source_url": source_url,
                        "result": "already_exists",
                        "http_status": "",
                        "saved_bytes": target.stat().st_size,
                        "original_sha256": row.get("sha256", ""),
                        "rebuilt_sha256": "",
                        "rebuilt_at": datetime.now().strftime("%Y-%m-%d %H:%M:%S"),
                        "note": "Existing file kept. Use --overwrite to refresh.",
                    }
                )
                continue

            attempted += 1
            target.parent.mkdir(parents=True, exist_ok=True)
            try:
                http_status, final_url, data = fetch_url(source_url, timeout_seconds)
                target.write_bytes(data)
                rebuilt_sha = hashlib.sha256(data).hexdigest()
                saved += 1
                writer.writerow(
                    {
                        "serial_no": row.get("serial_no", ""),
                        "snapshot_file": snapshot_file,
                        "source_url": final_url or source_url,
                        "result": "saved",
                        "http_status": http_status,
                        "saved_bytes": len(data),
                        "original_sha256": row.get("sha256", ""),
                        "rebuilt_sha256": rebuilt_sha,
                        "rebuilt_at": datetime.now().strftime("%Y-%m-%d %H:%M:%S"),
                        "note": "Live page was downloaded to recreate the evidence folder. Content may differ from scan-time snapshot if the website changed.",
                    }
                )
            except (urllib.error.URLError, TimeoutError, OSError) as exc:
                failed += 1
                writer.writerow(
                    {
                        "serial_no": row.get("serial_no", ""),
                        "snapshot_file": snapshot_file,
                        "source_url": source_url,
                        "result": "failed",
                        "http_status": "",
                        "saved_bytes": 0,
                        "original_sha256": row.get("sha256", ""),
                        "rebuilt_sha256": "",
                        "rebuilt_at": datetime.now().strftime("%Y-%m-%d %H:%M:%S"),
                        "note": exc.__class__.__name__,
                    }
                )
            if delay_seconds:
                time.sleep(delay_seconds)

    return {
        "data_file": str(data_file.resolve()),
        "output_dir": str(output_dir.resolve()),
        "rows_in_data_file": len(rows),
        "attempted_downloads": attempted,
        "saved": saved,
        "failed": failed,
        "skipped": skipped,
        "log_file": str(log_path.resolve()),
    }


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Rebuild India evidence snapshot files from the GitHub transfer package.")
    parser.add_argument("--data-file", type=Path, default=DEFAULT_DATA_FILE, help="Path to india_scope_candidate_pages.jsonl.")
    parser.add_argument("--output-dir", type=Path, default=Path("."), help="Folder where evidence_snapshots will be created.")
    parser.add_argument("--timeout-seconds", type=int, default=20)
    parser.add_argument("--delay-seconds", type=float, default=0.15)
    parser.add_argument("--overwrite", action="store_true", help="Download again even if a snapshot file already exists.")
    parser.add_argument("--only-action", action="store_true", help="Download only rows that need analyst action.")
    return parser.parse_args()


def main() -> None:
    args = parse_args()
    result = rebuild_snapshots(
        data_file=args.data_file,
        output_dir=args.output_dir,
        timeout_seconds=args.timeout_seconds,
        delay_seconds=args.delay_seconds,
        overwrite=args.overwrite,
        only_action=args.only_action,
    )
    print(json.dumps(result, indent=2))


if __name__ == "__main__":
    main()
