# RBI AMEX Transfer Package 2026-06-20

Temporary private transfer package for the RBI compliance evidence dump.

## Contents

The `transfer_package` folder contains:

- `verified_pdfs_only.7z.001` through `verified_pdfs_only.7z.004`
- `dump_information_VERIFIED_FINAL_20_6.xlsx`
- `SHA256SUMS.txt`
- `README_DOWNLOAD_AND_REASSEMBLE.txt`
- `reassemble_and_verify.ps1`
- `DOUBLE_CLICK_REASSEMBLE_AND_EXTRACT.bat`
- `transfer_manifest.json`

The large archive parts are tracked with Git LFS.

## Download On Target Machine

Do not use GitHub's plain **Download ZIP** option for this repository. These large files are stored through Git LFS, so the safest route on the target machine is:

```powershell
git lfs install
git clone https://github.com/Rvnderdahiya/rbi-amex-transfer-20260620.git
cd rbi-amex-transfer-20260620\transfer_package
powershell -ExecutionPolicy Bypass -File .\reassemble_and_verify.ps1
```

The script rebuilds `verified_pdfs_only.7z`, verifies the SHA256 hash, and extracts it automatically if 7-Zip is installed. You can also double-click `DOUBLE_CLICK_REASSEMBLE_AND_EXTRACT.bat`.

Expected PDF count after extraction: `13,658`.

Expected `Verified Dump` workbook rows: `14,015`.

Delete this private repository after the Amex machine copy is verified.
