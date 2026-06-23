AMEX RBI Final Workbook and PDF Bucket Package
Generated: 2026-06-23

What is included
1. dump_information_SIMPLE_FOR_TEAM_WITHDRAWN_BIFURCATED_EXCEL_SAFE.xlsx
   - Final Excel-safe workbook for team review.
   - Uses AMEX wording, not MX.
   - Includes Regulation Status, Addressee, Additional Team Keywords Matched,
     and All Team Keywords Matched.

2. withdrawn_bifurcation_traceability_EXCEL_SAFE.xlsx
   - Audit/traceability workbook.
   - Shows each source row, bifurcation bucket, evidence source, page/snippet,
     PDF scan status, and target bucket planning.

3. create_amex_pdf_buckets.py
   - Standard-library Python script to create three PDF folders from the final
     workbook and the extracted PDF dump.
   - It does not need pandas/openpyxl.

4. RUN_CREATE_AMEX_PDF_BUCKETS.bat
   - Double-click launcher for create_amex_pdf_buckets.py.

Recommended AMEX-machine steps
1. Download this package from GitHub.
2. Keep these files together in one folder.
3. Make sure the extracted PDF dump folder is available on the AMEX machine.
   The folder is usually named verified_pdfs_only.
4. Double-click RUN_CREATE_AMEX_PDF_BUCKETS.bat.
5. Paste the PDF dump folder path when prompted.
6. Paste the final workbook path when prompted:
   dump_information_SIMPLE_FOR_TEAM_WITHDRAWN_BIFURCATED_EXCEL_SAFE.xlsx
7. For output folder, press Enter for the default or provide your own folder.
8. For action, type copy.

Output folders created by the script
1. pdfs_active_review
2. pdfs_withdrawn_removed
3. pdfs_possible_withdrawn_review
4. amex_pdf_bucket_creation_report.csv

Important
- Use copy mode unless you intentionally want to move PDFs out of the original
  dump. Copy mode keeps the source dump intact.
- The Excel files in this package are rebuilt in Excel-safe mode, without
  table XML objects, to avoid the Excel repair prompt.
- If any PDF is missing, the CSV report will show Status = missing_pdf.
