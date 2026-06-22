RBI AMEX transfer package
Prepared: 2026-06-20T12:09:07

Files in this transfer:
- verified_pdfs_only.7z.001 ... verified_pdfs_only.7z.004: split parts of the verified PDF archive
- dump_information_VERIFIED_FINAL_20_6.xlsx: final team-facing workbook
- SHA256SUMS.txt: checksums for all uploaded files and original files
- reassemble_and_verify.ps1: PowerShell helper to rebuild, verify, and extract verified_pdfs_only.7z
- DOUBLE_CLICK_REASSEMBLE_AND_EXTRACT.bat: double-click helper for Windows
- transfer_manifest.json: machine-readable manifest

Download instructions on the Amex machine:
1. Do not use GitHub's plain "Download ZIP" button. It may download Git LFS pointer files instead of the real archive parts.
2. Use Git LFS:
   git lfs install
   git clone https://github.com/Rvnderdahiya/rbi-amex-transfer-20260620.git
3. Open PowerShell in:
   rbi-amex-transfer-20260620\transfer_package
4. Run:
   powershell -ExecutionPolicy Bypass -File .\reassemble_and_verify.ps1
5. The script rebuilds verified_pdfs_only.7z, verifies its SHA256 hash, and extracts it if 7-Zip is installed.
6. Verify PDF count:
   Get-ChildItem .\verified_pdfs_only -Recurse -Filter *.pdf | Measure-Object

Expected PDF count: 13,658
Workbook rows in Verified Dump: 14,015

Security/cleanup:
- Keep the GitHub repository private.
- Grant read-only access only to the intended GitHub/AEXP account.
- Delete the release/repo after the Amex machine copy has been verified.
