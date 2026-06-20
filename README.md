# RBI AMEX Transfer Package 2026-06-20

Temporary private transfer package for the RBI compliance evidence dump.

## Contents

The `transfer_package` folder contains:

- `verified_pdfs_only.7z.part001` through `verified_pdfs_only.7z.part004`
- `dump_information_VERIFIED_FINAL_20_6.xlsx`
- `SHA256SUMS.txt`
- `README_DOWNLOAD_AND_REASSEMBLE.txt`
- `reassemble_and_verify.ps1`
- `transfer_manifest.json`

The large archive parts are tracked with Git LFS.

## Download On Target Machine

Clone with Git LFS enabled:

```powershell
git clone https://github.com/Rvnderdahiya/rbi-amex-transfer-20260620.git
cd rbi-amex-transfer-20260620\transfer_package
powershell -ExecutionPolicy Bypass -File .\reassemble_and_verify.ps1
```

Compare the displayed SHA256 hash for `verified_pdfs_only.7z` with `SHA256SUMS.txt`, then extract the archive.

Expected PDF count after extraction: `13,658`.

Expected `Verified Dump` workbook rows: `14,015`.

Delete this private repository after the Amex machine copy is verified.
