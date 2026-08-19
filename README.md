# India Market Merchant Monitoring - Transfer Package

This package contains the India workbook and the exact evidence snapshots captured during the scan.
Sensitive tokens incidentally present in captured public page source are redacted in the transferable snapshots.

## How to use

1. Open `india_market_merchant_monitoring_results.xlsx`.
2. Use `India Summary` first, then `Analyst Working View`, then `Full Detail` only when more context is needed.
3. To restore the evidence files, double-click `run_restore_evidence_snapshots_from_parts.bat`.
4. After restore, the `evidence_snapshots` folder will be created in this folder. The restore script validates ZIP extraction/CRC, file count, every file size, and deterministic SHA-256 samples against `snapshot_manifest.csv`.
5. Optional full hash check: run `python restore_evidence_snapshots_from_parts.py --full-hash` from this folder.

## What is included

- India-scope rows in workbook: 3646
- Rows requiring analyst action: 500
- Visible AmEx acceptance rows: 21
- Possible AmEx signal rows: 163
- Evidence snapshots in archive: 3455
- Archive parts: 21
- Source scan folder: `20260819_192306_india_enhanced_combined`

## Important note

The workbook is an external web evidence lead list. Final confirmation should be completed using internal merchant records, descriptors, acquirer/payment facilitator information, and transaction/submission history.
