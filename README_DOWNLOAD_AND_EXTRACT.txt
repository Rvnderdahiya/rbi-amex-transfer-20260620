India LRR Active Regulatory Inventory - Download and Extract Instructions

What this package contains
1. India_LRR_Active_Regulatory_Inventory_20260714.xlsx
   - Final workbook for team review.

2. archive_parts
   - Numbered parts of the PDF archive.
   - These are real file parts, not Git LFS pointer files.

3. reassemble_and_extract.bat
   - Double-click this file after downloading the GitHub repository ZIP.
   - It rebuilds PDFs.7z from the numbered parts and then extracts the PDF folders.

How to use on the AMEX laptop
1. Open the GitHub repository.
2. Click Code > Download ZIP.
3. Extract the downloaded GitHub ZIP to a normal folder.
4. Open the extracted folder.
5. Double-click reassemble_and_extract.bat.
6. Wait until the script says extraction is complete.

Expected output after extraction
The script should create a folder named PDFs containing:
1. 01_PDFs_Matched_With_RBI_Dump
2. 02_PDFs_Not_Matched_With_RBI_Dump
3. 03_RBI_Dump_PDFs_Not_In_Final_KMT_Inventory

Workbook to use
Use India_LRR_Active_Regulatory_Inventory_20260714.xlsx first.

Folder meaning
1. 01_PDFs_Matched_With_RBI_Dump
   - Final active KMT records where PDF evidence was already available from the RBI download base.

2. 02_PDFs_Not_Matched_With_RBI_Dump
   - Final active KMT records where PDF evidence was not directly matched with the earlier RBI dump.

3. 03_RBI_Dump_PDFs_Not_In_Final_KMT_Inventory
   - Remaining RBI active-review records not represented in the final active KMT inventory.

If extraction does not start
The rebuild step will still create PDFs.7z.
If the script says 7-Zip/tar is not available, open PDFs.7z manually using 7-Zip or Windows Explorer if supported on the laptop.
