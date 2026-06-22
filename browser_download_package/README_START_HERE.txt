RBI AMEX browser-download package
Prepared for environments where git clone / Git LFS is restricted.

Use this folder if you downloaded the repository from GitHub using Code > Download ZIP.
Do not use the older transfer_package folder from a ZIP download.

Files:
- chunks\verified_pdfs_only.7z.chunk001 through chunks\verified_pdfs_only.7z.chunk041
- dump_information_SIMPLE_FOR_TEAM.xlsx: simplified team-facing workbook
- dump_information_VERIFIED_FINAL_20_6.xlsx
- reassemble_and_verify_browser_download.ps1
- DOUBLE_CLICK_REASSEMBLE_AND_EXTRACT.bat

Workbook guidance:
- Use dump_information_SIMPLE_FOR_TEAM.xlsx for normal team review.
- Keep dump_information_VERIFIED_FINAL_20_6.xlsx as the detailed audit/evidence workbook.
- The simple workbook has five sheets:
  1. Total Dump
  2. Category Summary
  3. MX Category Summary
  4. MX Applicable Detail
  5. Definitions

Steps:
1. Extract the GitHub ZIP fully. Do not run the script from inside the compressed ZIP preview.
2. Open the extracted folder:
   rbi-amex-transfer-20260620-main\browser_download_package
3. Double-click:
   DOUBLE_CLICK_REASSEMBLE_AND_EXTRACT.bat

What the script does:
1. Reads all 41 chunk files from the chunks folder.
2. Rebuilds verified_pdfs_only.7z in this browser_download_package folder.
3. Verifies the archive SHA256:
   e11993ff63fcd4a92e9fda8715fdabebc0734c5b21836b790613a79a9194912c
4. If 7-Zip is installed, extracts PDFs to:
   browser_download_package\verified_pdfs_only

Expected results:
- Reassembled archive: verified_pdfs_only.7z
- Extracted folder: verified_pdfs_only
- Expected PDF count after extraction: 13,658
- Workbook rows in Verified Dump: 14,015

If extraction does not happen automatically, install/use the approved 7-Zip tool and manually extract verified_pdfs_only.7z into this same folder.
