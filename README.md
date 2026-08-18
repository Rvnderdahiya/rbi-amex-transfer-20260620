# India Market Merchant Monitoring - GitHub Transfer Package

This package is intentionally small enough for GitHub. It does not include the 500+ MB evidence snapshot folder.

## Contents

- `india_market_merchant_monitoring_results.xlsx` - final India workbook.
- `india_scope_candidate_pages.jsonl` - India-scope row data used by the workbook and rebuild script.
- `snapshot_manifest.csv` - map of each row to the expected snapshot file.
- `rebuild_evidence_snapshots.py` - recreates the `evidence_snapshots` folder on the target machine.
- `run_rebuild_evidence_snapshots.bat` - double-click helper for Windows.

## How To Recreate Evidence Snapshots

On the target machine, open this folder and run:

```powershell
python rebuild_evidence_snapshots.py
```

Or double-click:

```text
run_rebuild_evidence_snapshots.bat
```

The script creates the same `evidence_snapshots` folder structure referenced in the workbook.

## Important Note

The workbook contains scan-time evidence snippets. The rebuild script downloads live pages again, so the rebuilt HTML files may differ if a website changed after the original scan.

For compliance review, treat public evidence as a lead list. Final confirmation should come from internal merchant records, descriptors, acquirer/payment facilitator data, and AmEx transaction/submission history.
