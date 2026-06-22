# RBI AMEX Transfer Package 2026-06-20

Temporary private transfer package for the RBI compliance evidence dump.

## Download Without Git Clone

Use this route when the target environment does not allow `git clone` or Git LFS:

1. On GitHub, select **Code > Download ZIP**.
2. Extract the ZIP fully.
3. Open `browser_download_package`.
4. Double-click `DOUBLE_CLICK_REASSEMBLE_AND_EXTRACT.bat`.

This browser package uses normal Git files under 50 MB each, so it does not depend on Git LFS.

## Contents

The `browser_download_package` folder contains:

- `chunks\verified_pdfs_only.7z.chunk001` through `chunks\verified_pdfs_only.7z.chunk041`
- `dump_information_SIMPLE_FOR_TEAM.xlsx`
- `dump_information_VERIFIED_FINAL_20_6.xlsx`
- `README_START_HERE.txt`
- `reassemble_and_verify_browser_download.ps1`
- `DOUBLE_CLICK_REASSEMBLE_AND_EXTRACT.bat`

Use `dump_information_SIMPLE_FOR_TEAM.xlsx` for team review. Keep `dump_information_VERIFIED_FINAL_20_6.xlsx` as the detailed evidence workbook.

The script rebuilds `verified_pdfs_only.7z`, verifies the SHA256 hash, and extracts it automatically if 7-Zip is installed.

Expected PDF count after extraction: `13,658`.

Expected `Verified Dump` workbook rows: `14,015`.

Delete this private repository after the approved environment copy is verified.
