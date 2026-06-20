RBI AMEX transfer package
Prepared: 2026-06-20T12:09:07

Files in this transfer:
- verified_pdfs_only.7z.part001 ... partNNN: split parts of the verified PDF archive
- dump_information_VERIFIED_FINAL_20_6.xlsx: final team-facing workbook
- SHA256SUMS.txt: checksums for all uploaded files and original files
- reassemble_and_verify.ps1: PowerShell helper to rebuild verified_pdfs_only.7z
- transfer_manifest.json: machine-readable manifest

Download instructions on the Amex machine:
1. Download every file from the GitHub Release into one folder.
2. Open PowerShell in that folder.
3. Run:
   powershell -ExecutionPolicy Bypass -File .\reassemble_and_verify.ps1
4. Compare the displayed SHA256 for verified_pdfs_only.7z with SHA256SUMS.txt.
5. Extract verified_pdfs_only.7z using 7-Zip or an approved archive tool.
6. Verify PDF count:
   Get-ChildItem .\verified_pdfs_only -Recurse -Filter *.pdf | Measure-Object

Expected PDF count: 13,658
Workbook rows in Verified Dump: 14,015

Security/cleanup:
- Keep the GitHub repository private.
- Grant read-only access only to the intended GitHub/AEXP account.
- Delete the release/repo after the Amex machine copy has been verified.
