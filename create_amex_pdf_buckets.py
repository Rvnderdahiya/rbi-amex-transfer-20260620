"""
Create AMEX RBI PDF bucket folders from the final bifurcation workbook.

This script is intentionally dependency-free: it reads .xlsx files using only
the Python standard library, so it can run on a restricted corporate machine
without installing openpyxl/pandas.

It creates:
  - pdfs_active_review
  - pdfs_withdrawn_removed
  - pdfs_possible_withdrawn_review

Recommended use: copy mode. It preserves the original dump and creates a
separate bucketed output folder for review/sharing.
"""

from __future__ import annotations

import argparse
import csv
import os
import shutil
import sys
import zipfile
from collections import Counter, defaultdict
from pathlib import Path
from typing import Dict, Iterable, List, Optional, Tuple
from xml.etree import ElementTree as ET


BUCKET_TO_FOLDER = {
    "Active Review": "pdfs_active_review",
    "Withdrawn Removed": "pdfs_withdrawn_removed",
    "Possible Withdrawn Review": "pdfs_possible_withdrawn_review",
}

BUCKET_ALIASES = {
    "active": "Active Review",
    "active review": "Active Review",
    "withdrawn": "Withdrawn Removed",
    "withdrawn removed": "Withdrawn Removed",
    "removed": "Withdrawn Removed",
    "possible": "Possible Withdrawn Review",
    "possible withdrawn": "Possible Withdrawn Review",
    "possible withdrawn review": "Possible Withdrawn Review",
}

NS = {
    "main": "http://schemas.openxmlformats.org/spreadsheetml/2006/main",
    "rel": "http://schemas.openxmlformats.org/officeDocument/2006/relationships",
    "pkgrel": "http://schemas.openxmlformats.org/package/2006/relationships",
}


def clean(value: object) -> str:
    if value is None:
        return ""
    return str(value).strip()


def normalize_bucket(value: str) -> str:
    text = clean(value)
    return BUCKET_ALIASES.get(text.lower(), text)


def col_letters_to_index(ref: str) -> int:
    letters = "".join(ch for ch in ref if ch.isalpha()).upper()
    idx = 0
    for ch in letters:
        idx = idx * 26 + (ord(ch) - ord("A") + 1)
    return idx - 1


def read_shared_strings(zf: zipfile.ZipFile) -> List[str]:
    if "xl/sharedStrings.xml" not in zf.namelist():
        return []
    root = ET.fromstring(zf.read("xl/sharedStrings.xml"))
    strings: List[str] = []
    for si in root.findall("main:si", NS):
        parts = []
        for t in si.findall(".//main:t", NS):
            parts.append(t.text or "")
        strings.append("".join(parts))
    return strings


def read_sheet_map(zf: zipfile.ZipFile) -> Dict[str, str]:
    workbook = ET.fromstring(zf.read("xl/workbook.xml"))
    rels = ET.fromstring(zf.read("xl/_rels/workbook.xml.rels"))
    rel_map = {}
    for rel in rels.findall("pkgrel:Relationship", NS):
        rel_id = rel.attrib.get("Id", "")
        target = rel.attrib.get("Target", "")
        if target.startswith("/"):
            path = target.lstrip("/")
        else:
            path = "xl/" + target
        rel_map[rel_id] = path.replace("\\", "/")

    sheet_map: Dict[str, str] = {}
    for sheet in workbook.findall("main:sheets/main:sheet", NS):
        name = sheet.attrib.get("name", "")
        rel_id = sheet.attrib.get(f"{{{NS['rel']}}}id", "")
        if name and rel_id in rel_map:
            sheet_map[name] = rel_map[rel_id]
    return sheet_map


def cell_value(cell: ET.Element, shared_strings: List[str]) -> str:
    cell_type = cell.attrib.get("t", "")
    if cell_type == "inlineStr":
        return "".join(t.text or "" for t in cell.findall(".//main:t", NS)).strip()

    v = cell.find("main:v", NS)
    if v is None or v.text is None:
        return ""

    if cell_type == "s":
        try:
            return shared_strings[int(v.text)]
        except Exception:
            return ""
    return v.text.strip()


def read_xlsx_sheet_rows(path: Path, sheet_name: str) -> Tuple[List[str], List[Dict[str, str]]]:
    with zipfile.ZipFile(path) as zf:
        shared = read_shared_strings(zf)
        sheet_map = read_sheet_map(zf)
        if sheet_name not in sheet_map:
            raise KeyError(f"Sheet not found: {sheet_name}")

        root = ET.fromstring(zf.read(sheet_map[sheet_name]))
        rows_matrix: List[List[str]] = []
        for row in root.findall(".//main:sheetData/main:row", NS):
            values: Dict[int, str] = {}
            max_idx = -1
            for cell in row.findall("main:c", NS):
                idx = col_letters_to_index(cell.attrib.get("r", ""))
                values[idx] = cell_value(cell, shared)
                max_idx = max(max_idx, idx)
            if max_idx >= 0:
                rows_matrix.append([values.get(i, "") for i in range(max_idx + 1)])

    if not rows_matrix:
        return [], []

    headers = [clean(h) for h in rows_matrix[0]]
    rows: List[Dict[str, str]] = []
    for raw in rows_matrix[1:]:
        if not any(clean(v) for v in raw):
            continue
        row = {headers[i]: raw[i] if i < len(raw) else "" for i in range(len(headers))}
        rows.append(row)
    return headers, rows


def workbook_sheet_names(path: Path) -> List[str]:
    with zipfile.ZipFile(path) as zf:
        return list(read_sheet_map(zf).keys())


def load_bifurcation_rows(workbook_path: Path) -> List[Dict[str, str]]:
    sheet_names = workbook_sheet_names(workbook_path)
    rows: List[Dict[str, str]] = []

    if "Traceability" in sheet_names:
        _headers, trace_rows = read_xlsx_sheet_rows(workbook_path, "Traceability")
        for row in trace_rows:
            bucket = normalize_bucket(row.get("Bifurcation Bucket", ""))
            if bucket not in BUCKET_TO_FOLDER:
                continue
            rows.append(
                {
                    "Serial No": row.get("Serial No", ""),
                    "File Name": row.get("File Name", ""),
                    "Bifurcation Bucket": bucket,
                    "Source PDF Path": row.get("Source PDF Path", ""),
                    "Title": row.get("Title", ""),
                }
            )
        return rows

    # Also supports the final team workbook, where active/withdrawn/possible
    # are split across separate sheets.
    sheet_to_bucket = {
        "Total Dump": "Active Review",
        "Withdrawn Removed": "Withdrawn Removed",
        "Possible Withdrawn Review": "Possible Withdrawn Review",
    }
    for sheet, bucket in sheet_to_bucket.items():
        if sheet not in sheet_names:
            continue
        _headers, sheet_rows = read_xlsx_sheet_rows(workbook_path, sheet)
        for row in sheet_rows:
            rows.append(
                {
                    "Serial No": row.get("Serial No", ""),
                    "File Name": row.get("File Name", ""),
                    "Bifurcation Bucket": bucket,
                    "Source PDF Path": row.get("Source PDF Path", ""),
                    "Title": row.get("Title", ""),
                }
            )
    return rows


def index_pdfs(pdf_root: Path) -> Dict[str, List[Path]]:
    pdf_map: Dict[str, List[Path]] = defaultdict(list)
    for path in pdf_root.rglob("*.pdf"):
        pdf_map[path.name.lower()].append(path)
    return pdf_map


def path_after_known_root(source_path: str) -> Optional[Path]:
    if not source_path:
        return None
    normalized = source_path.replace("\\", "/")
    for marker in ["/verified_pdfs_only/", "/pdfs/"]:
        pos = normalized.lower().find(marker)
        if pos >= 0:
            return Path(normalized[pos + len(marker) :])
    return None


def choose_source_pdf(row: Dict[str, str], pdf_root: Path, pdf_map: Dict[str, List[Path]]) -> Tuple[Optional[Path], str]:
    file_name = Path(clean(row.get("File Name", ""))).name
    if not file_name:
        return None, "missing file name in workbook"

    rel = path_after_known_root(row.get("Source PDF Path", ""))
    if rel:
        candidate = pdf_root / rel
        if candidate.exists():
            return candidate, "matched by relative source path"

    matches = pdf_map.get(file_name.lower(), [])
    if len(matches) == 1:
        return matches[0], "matched by file name"
    if len(matches) > 1:
        return matches[0], f"duplicate file name; used first of {len(matches)} matches"
    return None, "PDF not found under dump folder"


def unique_target_path(target: Path) -> Path:
    if not target.exists():
        return target
    parent = target.parent
    stem = target.stem
    suffix = target.suffix
    for i in range(2, 10000):
        candidate = parent / f"{stem}__{i}{suffix}"
        if not candidate.exists():
            return candidate
    raise RuntimeError(f"Could not create unique target for {target}")


def copy_or_move(source: Path, target: Path, action: str) -> str:
    target.parent.mkdir(parents=True, exist_ok=True)
    final_target = unique_target_path(target)
    if action == "dry-run":
        return f"would_copy -> {final_target}"
    if action == "copy":
        shutil.copy2(source, final_target)
        return f"copied -> {final_target}"
    if action == "move":
        shutil.move(str(source), str(final_target))
        return f"moved -> {final_target}"
    raise ValueError(f"Unsupported action: {action}")


def write_report(report_path: Path, rows: Iterable[Dict[str, str]]) -> None:
    report_path.parent.mkdir(parents=True, exist_ok=True)
    headers = [
        "Serial No",
        "File Name",
        "Bucket",
        "Action",
        "Status",
        "Source PDF",
        "Target PDF",
        "Notes",
        "Title",
    ]
    with report_path.open("w", newline="", encoding="utf-8-sig") as f:
        writer = csv.DictWriter(f, fieldnames=headers)
        writer.writeheader()
        for row in rows:
            writer.writerow({h: row.get(h, "") for h in headers})


def prompt_if_missing(args: argparse.Namespace) -> argparse.Namespace:
    if args.pdf_root and args.workbook:
        return args

    print("")
    print("AMEX RBI PDF bucket creator")
    print("Paste paths when prompted. Quotes are optional.")
    print("")
    if not args.pdf_root:
        args.pdf_root = input("PDF dump folder path, e.g. ...\\verified_pdfs_only: ").strip().strip('"')
    if not args.workbook:
        args.workbook = input("Final workbook or traceability workbook path: ").strip().strip('"')
    if not args.output_dir:
        default_out = str(Path(args.pdf_root).parent / "amex_pdf_buckets_output")
        entered = input(f"Output folder path [Enter for {default_out}]: ").strip().strip('"')
        args.output_dir = entered or default_out
    if not args.action:
        entered = input("Action: copy / dry-run / move [copy]: ").strip().lower()
        args.action = entered or "copy"
    return args


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Create three AMEX RBI PDF buckets from final bifurcation workbook.")
    parser.add_argument("--pdf-root", help="Folder containing the extracted PDF dump, usually verified_pdfs_only.")
    parser.add_argument("--workbook", help="Final bifurcated workbook or withdrawn_bifurcation_traceability.xlsx.")
    parser.add_argument("--output-dir", help="Folder where the three bucket folders and report will be created.")
    parser.add_argument("--action", choices=["copy", "dry-run", "move"], help="Default: copy. Use move only if you intentionally want to move files out of the dump.")
    parser.add_argument("--yes", action="store_true", help="Do not ask for final confirmation.")
    return prompt_if_missing(parser.parse_args())


def main() -> int:
    args = parse_args()
    pdf_root = Path(args.pdf_root).expanduser().resolve()
    workbook_path = Path(args.workbook).expanduser().resolve()
    output_dir = Path(args.output_dir).expanduser().resolve() if args.output_dir else pdf_root.parent / "amex_pdf_buckets_output"
    action = args.action or "copy"

    if not pdf_root.exists() or not pdf_root.is_dir():
        print(f"ERROR: PDF dump folder not found: {pdf_root}")
        return 2
    if not workbook_path.exists():
        print(f"ERROR: Workbook not found: {workbook_path}")
        return 2

    if action == "move" and not args.yes:
        confirm = input("MOVE will remove PDFs from the original dump. Type MOVE to continue: ").strip()
        if confirm != "MOVE":
            print("Cancelled.")
            return 1

    print("")
    print(f"PDF dump folder : {pdf_root}")
    print(f"Workbook        : {workbook_path}")
    print(f"Output folder   : {output_dir}")
    print(f"Action          : {action}")
    print("")

    rows = load_bifurcation_rows(workbook_path)
    if not rows:
        print("ERROR: No bifurcation rows found. Use the final workbook or traceability workbook.")
        return 2

    print(f"Workbook rows loaded: {len(rows):,}")
    print("Indexing PDFs...")
    pdf_map = index_pdfs(pdf_root)
    print(f"PDF files indexed: {sum(len(v) for v in pdf_map.values()):,}")

    for folder in BUCKET_TO_FOLDER.values():
        (output_dir / folder).mkdir(parents=True, exist_ok=True)

    report_rows: List[Dict[str, str]] = []
    bucket_counts: Counter[str] = Counter()
    status_counts: Counter[str] = Counter()

    for idx, row in enumerate(rows, start=1):
        bucket = normalize_bucket(row.get("Bifurcation Bucket", ""))
        if bucket not in BUCKET_TO_FOLDER:
            status = "skipped"
            notes = f"Unknown bucket: {bucket}"
            source = None
            target = ""
        else:
            source, notes = choose_source_pdf(row, pdf_root, pdf_map)
            if source is None:
                status = "missing_pdf"
                target = ""
            else:
                try:
                    rel = source.relative_to(pdf_root)
                except ValueError:
                    rel = Path(source.name)
                target_path = output_dir / BUCKET_TO_FOLDER[bucket] / rel
                status = copy_or_move(source, target_path, action)
                target = status.split(" -> ", 1)[-1] if " -> " in status else str(target_path)

        bucket_counts[bucket] += 1
        status_key = status.split(" -> ", 1)[0]
        status_counts[status_key] += 1
        report_rows.append(
            {
                "Serial No": row.get("Serial No", ""),
                "File Name": Path(clean(row.get("File Name", ""))).name,
                "Bucket": bucket,
                "Action": action,
                "Status": status,
                "Source PDF": str(source) if source else "",
                "Target PDF": target,
                "Notes": notes,
                "Title": row.get("Title", ""),
            }
        )
        if idx % 1000 == 0:
            print(f"Processed {idx:,}/{len(rows):,} rows...")

    report_path = output_dir / "amex_pdf_bucket_creation_report.csv"
    write_report(report_path, report_rows)

    print("")
    print("Done.")
    print(f"Output folder: {output_dir}")
    print(f"Report: {report_path}")
    print("")
    print("Bucket counts:")
    for bucket, count in bucket_counts.most_common():
        print(f"  {bucket}: {count:,}")
    print("Action/status counts:")
    for status, count in status_counts.most_common():
        print(f"  {status}: {count:,}")
    if status_counts.get("missing_pdf", 0):
        print("")
        print("WARNING: Some PDFs were not found. Open the CSV report and filter Status = missing_pdf.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
