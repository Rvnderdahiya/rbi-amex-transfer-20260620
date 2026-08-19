from __future__ import annotations

import argparse
import csv
import hashlib
import sys
import zipfile
from pathlib import Path
from typing import Any


def sha256_file(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as handle:
        for chunk in iter(lambda: handle.read(1024 * 1024), b""):
            digest.update(chunk)
    return digest.hexdigest()


def load_manifest(path: Path) -> list[dict[str, str]]:
    if not path.exists():
        return []
    with path.open("r", newline="", encoding="utf-8-sig") as handle:
        return list(csv.DictReader(handle))


def safe_extract(zip_path: Path, output_dir: Path) -> int:
    output_root = output_dir.resolve()
    extracted = 0
    with zipfile.ZipFile(zip_path, "r", allowZip64=True) as archive:
        for member in archive.infolist():
            if member.is_dir():
                continue
            member_name = Path(member.filename.replace("\\", "/")).name
            if not member_name:
                continue
            target = (output_dir / member_name).resolve()
            if output_root not in [target, *target.parents]:
                raise RuntimeError(f"Unsafe archive path blocked: {member.filename}")
            output_dir.mkdir(parents=True, exist_ok=True)
            with archive.open(member, "r") as source, target.open("wb") as destination:
                for chunk in iter(lambda: source.read(1024 * 1024), b""):
                    destination.write(chunk)
            extracted += 1
    return extracted


def should_hash(index: int, item: dict[str, str], total: int, full_hash: bool) -> bool:
    if full_hash:
        return True
    if index <= 25 or index > max(total - 25, 0):
        return True
    if index % 250 == 0:
        return True
    return False


def restore(package_dir: Path, output_dir: Path | None = None, full_hash: bool = False) -> dict[str, Any]:
    package_dir = package_dir.resolve()
    parts_dir = package_dir / "snapshot_archive_parts"
    manifest_path = package_dir / "snapshot_manifest.csv"
    output_dir = (output_dir or package_dir / "evidence_snapshots").resolve()
    parts = sorted(parts_dir.glob("evidence_snapshots.zip.part*"))
    if not parts:
        raise FileNotFoundError(f"No archive parts found in {parts_dir}")

    combined_zip = package_dir / "evidence_snapshots_combined.zip.tmp"
    print(f"Joining {len(parts)} archive parts...", flush=True)
    with combined_zip.open("wb") as destination:
        for index, part in enumerate(parts, start=1):
            print(f"  part {index}/{len(parts)}: {part.name}", flush=True)
            with part.open("rb") as source:
                for chunk in iter(lambda: source.read(1024 * 1024), b""):
                    destination.write(chunk)

    try:
        print("Extracting evidence snapshots...", flush=True)
        extracted_count = safe_extract(combined_zip, output_dir)
    finally:
        if combined_zip.exists():
            combined_zip.unlink()

    manifest = load_manifest(manifest_path)
    print(f"Validating {len(manifest)} expected files...", flush=True)
    missing = 0
    hash_mismatch = 0
    size_mismatch = 0
    checked = 0
    for index, item in enumerate(manifest, start=1):
        archive_member = item.get("archive_member", "")
        expected_hash = item.get("sha256", "")
        expected_size = int(item.get("bytes") or 0)
        if not archive_member:
            continue
        path = output_dir / archive_member
        if not path.exists():
            missing += 1
            continue
        if expected_size and path.stat().st_size != expected_size:
            size_mismatch += 1
        if expected_hash and should_hash(index, item, len(manifest), full_hash):
            checked += 1
            if sha256_file(path).lower() != expected_hash.lower():
                hash_mismatch += 1
        if index % 500 == 0:
            print(f"  validated {index}/{len(manifest)} files...", flush=True)

    result = {
        "parts": len(parts),
        "extracted_files": extracted_count,
        "manifest_files": len(manifest),
        "full_hash": full_hash,
        "hashes_checked": checked,
        "missing_files": missing,
        "size_mismatch": size_mismatch,
        "hash_mismatch": hash_mismatch,
    }
    if extracted_count != len(manifest):
        raise RuntimeError(f"Extracted file count does not match manifest: {result}")
    if missing or size_mismatch or hash_mismatch:
        raise RuntimeError(f"Restore validation failed: {result}")
    return result


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Restore evidence snapshots from split archive parts.")
    parser.add_argument("--package-dir", type=Path, default=Path(__file__).resolve().parent)
    parser.add_argument("--output-dir", type=Path, default=None)
    parser.add_argument("--full-hash", action="store_true", help="Hash every restored file. Default checks all sizes and hashes action rows plus a deterministic sample.")
    return parser.parse_args()


def main() -> None:
    args = parse_args()
    try:
        result = restore(args.package_dir, args.output_dir, args.full_hash)
    except Exception as exc:
        print(f"Restore failed: {exc}", file=sys.stderr)
        sys.exit(1)
    print("Restore completed successfully.")
    for key, value in result.items():
        print(f"{key}: {value}")


if __name__ == "__main__":
    main()
