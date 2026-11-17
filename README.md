# India Regulatory Inventory - Tranche 2

This branch contains the transfer packages for the Tranche 2 inventory exercise.
It is separate from the previous RBI/KMT delivery branches. Future source
packages will be added to this same branch after validation.

| Source | Folder | Uploaded Status |
| --- | --- | --- |
| CKYCR | `CKYCR/` | Collected-source review inventory and originals uploaded; supporting-reference exceptions disclosed |
| IRDAI Batch 01 | [Open package folder](IRDAI_Review_Batch_01_Interim/) | 163 source-reviewed inventory entries; interim subset |
| IRDAI Batch 02 | [Open package folder](IRDAI_Review_Batch_02_Interim/) | 625 additional source-reviewed inventory entries; interim subset |
| IRDAI Batch 03 | [Open package folder](IRDAI_Review_Batch_03_Interim/) | 9 inventory entries from 10 additional source records; 16 distinct original PDFs |
| IRDAI Batch 04 | [Open package folder](IRDAI_Review_Batch_04_Interim/) | 9 inventory entries from 13 additional source records; 17 distinct original PDFs |
| IRDAI Batch 05 | [Open package folder](IRDAI_Review_Batch_05_Interim/) | 14 inventory entries from 18 additional source records; 27 original PDFs |
| IRDAI Batch 06 | [Open package folder](IRDAI_Review_Batch_06_Interim/) | 17 inventory entries from 20 additional source records; 32 original PDFs |
| IRDAI Batch 07 | [Open package folder](IRDAI_Review_Batch_07_Interim/) | 17 inventory entries from 24 additional source records; 29 original PDFs |
| IRDAI Batch 08 | [Open package folder](IRDAI_Review_Batch_08_Interim/) | 15 inventory entries from 16 additional source records; 24 original PDFs |
| CERSAI | `CERSAI/` | Collected-source review package uploaded; 95 retained entries, 67 exclusions; original excluded training video preserved in audit |
| UIDAI | `UIDAI/` | Collected-source review package; 100 inventory entries and 108 instrument PDFs; missing referenced opinion disclosed |
| FIU India | `FIU_India/` | Review package: 182 retained entries, 183 original PDFs and one XLS; one portal-only item disclosed |
| Gazette of India Batch 01 | [Open package folder](Gazette_Review_Batch_01_Interim/) | 41 reviewed single-notice entries; 41 original PDFs; interim subset |
| Gazette of India Batch 02 | [Open package folder](Gazette_Review_Batch_02_Interim/) | 33 individually reviewed notices from 9 multi-notice original PDFs |
| Gazette of India Batch 03 | [Open package folder](Gazette_Review_Batch_03_Interim/) | 85 inventory entries from 80 source records and 80 original PDFs |
| Gazette of India Batch 04 | [Open package folder](Gazette_Review_Batch_04_Interim/) | 77 inventory entries from 72 source records and 72 original PDFs |
| Gazette of India Batch 05 | [Open package folder](Gazette_Review_Batch_05_Interim/) | 88 inventory entries from 80 source records and 81 original PDFs |
| Gazette of India Batch 06 | [Open package folder](Gazette_Review_Batch_06_Interim/) | 74 inventory entries from 72 source records and 72 original PDFs |

## Review Checkpoint - 17 November 2026

The full Tranche 2 handover is **not complete**. The uploaded IRDAI batches
cover 889 nonoverlapping source records in 869 inventory entries. Twenty confirmed
duplicate catalogue representations were merged in Batches 03 through 08, with every
source occurrence and original PDF retained in their audit manifests. These
counts are not a count of unique laws or a current-force approval.

The complete-file recheck also confirmed one older cross-batch duplicate:
"Working Group on IRDA Investment Regulations", dated 30 June 2006. When combining
the interim workbooks, keep Batch 02 Inventory row 42 (source 807563) and do not
count Batch 03 Inventory row 12 (source 807576) again. The 869 delivered rows
therefore become 868 after this confirmed cross-batch adjustment. Both source
IDs and all original versions remain preserved. See the
[duplicate map](Audit/IRDAI_Cross_Batch_Duplicate_Map_20261117.csv) and
[bound adjudication](Audit/IRDAI_Cross_Batch_Duplicate_Adjudication_20261117.json).
The final cross-source deduplication is still in progress; 868 is not represented
as a certified unique-law total.

IRDAI's 5,733 captured source records currently reconcile to 1,610 retained under
the supplied collection rules, 335 excluded, 3,787 requiring further content
review, and one mixed archive requiring individual treatment. Source-rule
retention does not mean the seven fields or legal applicability are complete.
The earlier source snapshot is preserved; 128 content holds were cleared through
separately hash-bound complete-page reviews. Missing content and ambiguous dates
remain held rather than guessed.

The newly confirmed Insurance Institute of India trainee wording was checked in
source titles and official download labels. All 27 previously flagged records,
plus one further official-label match, were already excluded by another supplied
phrase. No second subtraction or extra 28-record reduction was applied.
An additional scan of available hash-bound native/OCR/Office text and saved
publisher bodies identified 32 candidate source records, including body-only
candidates. All 32 were already excluded; none is in a published inventory.
Extraction negatives are not claimed to clear unreadable or missing content.

Gazette's 18,861 canonical source notice rows reconcile to 11,646 retained under
source rules, 5,907 excluded and 1,308 held. The six uploaded Gazette batches
contain 398 inventory entries from 354 nonoverlapping source records. Multiple
independently numbered notices in a PDF have separate rows; bilingual versions
of one notice do not. The remaining
metadata, held content reviews and six unresolved publisher-original targets
are not represented as completed. Retained notices and PDF files are different
counting units.

Batch 05 also supplies an officially recovered, complete English original of
the 9 November 2000 TRAI Tenth Amendment, alongside the captured Gazette
version. This resolves a missing English continuation for that item; it is
separate from the six unresolved publisher-original targets listed in the audit.

Batch 06 preserves two distinct 6 May 1999 Government Stock auction notices
despite their common Ministry file reference. Their stock rates, maturity years
and amounts differ. Shared references alone are not used to merge notices.

Not yet released: 4,509 non-excluded IRDAI source IDs and 12,600 non-excluded
Gazette source IDs. These are records still requiring inventory completion or
review, not counts of missing PDFs. The machine-readable review status accounts
separately for uploaded, pending, held and excluded source records.

## Download the Additional Reviewed Batches

For IRDAI Batches 03 onward and all Gazette batches, open the corresponding folder
above and download its ZIP. Use Windows **Extract All** to a short folder and
open the workbook inside it. Keep `Originals` and `Audit` alongside the workbook.
Each document title opens its local PDF; the website field opens the official
source. No Git, Python, multipart joining or setup program is required for
these ordinary ZIPs. Their archives contain no screenshot substitutes.

Each new ZIP passed member CRC and SHA-256 checks, Windows extraction, native
Excel checks before and after extraction, and full payload download/hash
verification from GitHub. Original PDF bytes were not repaired or rewritten.
Publisher reader warnings are disclosed in the enclosed audit files.

Batch 02 is larger: follow its folder's download instructions and supplied
setup to assemble its independent ordinary ZIP packages. Do not discard
Batches 01 or 02; the later inventory entries are additional, not replacements.

## Download CKYCR

1. Open the `CKYCR` folder and download `CKYCR_Review_Package.zip` using the
   download button. Git cloning or Git LFS is not required.
2. Extract the entire ZIP to a short folder, for example a folder named
   `CKYCR` in Documents.
3. Open `CKYCR_Inventory.xlsx` inside the extracted folder. Keep it beside
   `Originals`, `Supporting` and `Audit` so the PDF links continue to work.

The separately uploaded workbook is provided for convenience. Its local PDF
links work when it is kept with the folders from the full package.

## CKYCR Contents and Checks

- Collection cut-off: 5 November 2026.
- 126 source-list occurrences represented by 123 document entries. Three
  exact shared-original occurrences are consolidated, with all occurrences
  preserved in the audit mapping.
- 123 original PDFs, containing 252 pages; two original ZIPs, one original
  DOCX consent template and one original publisher JPG banner are also supplied.
- Seven requested inventory columns, with preliminary AEBC assessments.
- All original file hashes match; every PDF page rendered in MuPDF and PDFium.
- Native Microsoft Excel and relocated ZIP/extraction/link checks passed.

This is not an active-only register or a final legal/applicability approval.
Six publisher PDFs trigger structural recovery in MuPDF and remain flagged.
Seventeen historical supporting-file reference URLs could not be retrieved;
the main collected notices are supplied and the supporting exceptions are
listed separately. Sixteen undated documents remain explicitly undated.

The SOPs retain their publisher's **Confidential** marking. Repository visibility
does not change that classification. Use and onward distribution remain subject
to the relevant permissions. Consult the package's `Read_Me.txt` for details.

## Download CERSAI

Open `CERSAI/` and download `CERSAI_Review_Package.zip`. Extract the entire ZIP
to a short folder named `CERSAI` in Documents. Open the workbook inside that
folder and keep it beside `Originals`, `Announcements`, `Supporting` and `Audit`.
No Git cloning or Git LFS is required. Its seven-column inventory accounts for
95 retained source entries, with all 67 exclusions separately recorded.

The 162-entry source capture and dated 7 November listing recheck are reconciled
in the audit. Original PDF,
Office, archive and data files are supplied where offered. Announcement-only
entries have saved text evidence, not manufactured PDFs. One linked original
training video is preserved in `Audit/Excluded_files`. Its opening slide contains
Maintenance in a statutory records-rule title. The user confirmed applying that
literal exclusion. The audit supplies the matching frame and decision. This is
not a finding of no compliance relevance or a claim of continuous manual video
review. Literal keyword context risks and mutable historical links remain explicit.

## Download IRDAI Interim Batch 01

Open `IRDAI_Review_Batch_01_Interim/` and download
`IRDAI_Review_Batch_01_Interim_TRANSFER.zip`. Extract the ZIP to a short folder.
Open the workbook beside `Originals`, `Pending_Review` and `Audit`; use the PDF
manifests to map source rows to files. The separate workbook is available in the
same GitHub folder for preview.

This batch contains 163 source-reviewed inventory rows from a bounded IRDAI
subset. A further 79 reviewed records are held in `Pending_Review` and are not
in the inventory worksheet. The full IRDAI source review and final workbook are
not complete. Applicability is preliminary, and current legal status is not
certified. See the batch README and audit files for the scope, file counts,
exclusion checks, hashes and open items.

## Download UIDAI

Open `UIDAI/` and download `UIDAI_Review_Package.zip`. Extract the whole ordinary
ZIP and open `UIDAI_Inventory.xlsx` alongside `Originals` and `Audit`. No Git
cloning, Git LFS or assembly script is required. The separate workbook alone
does not include the PDF folders.

The six requested sections contain 101 source items. One exact duplicate SOP
listing is consolidated, giving 100 inventory rows in the seven requested
columns. The package supplies 107 distinct listed PDF payloads and one recovered
original 2020 Gazette, plus an RTI disclosure PDF documenting that recovery.
All 1,065 pages rendered in two PDF engines. The workbook opened in native Excel
without recovery, including after ZIP extraction. All file links and hashes
were checked. Screenshots are not substitutes for the originals.

No UIDAI subject/HR/status exclusions were specified. Historical and internal
documents are retained, with document-specific preliminary AEBC relevance.
Conditional relevance requires confirmation of AEBC's actual role. Missing issue
dates, title/date discrepancies and language compilation differences are explicit.
One source-content exception remains: the 23 October 2018 circular refers to an
Attorney General opinion which is absent from its two-page publisher PDF and
was not separately recovered. Read `READ_ME.txt` and the audit exceptions.

## Download FIU India

Open `FIU_India/` and follow its README. Download `FIU_Inventory_Audit.zip`,
`FIU_Originals_01.zip` and `FIU_Originals_02.zip`. Extract all three into the same
parent folder, merging their `FIU_India` folder. These are independent ordinary
ZIPs, not split parts. No Git cloning, Git LFS or assembly script is required.
Open the workbook inside that combined folder to use the portable original links.

What's New and Archives reconcile to 213 distinct announcements, with 18 repeated
listing appearances consolidated. The four supplied title/full-document exclusion
phrases remove 31 announcements, leaving 182 inventory rows. All retained
attachment-bearing notices have their originals supplied: 183 PDFs / 942 pages
and one original XLS. One further retained item is only a FINnet portal link and
offers no attachment. Its listing extract is labelled, not converted into a fake PDF.

The broken FINGate memorandum link was recovered using the same official FIU
filename without an extra space. Its subject, reference and 11 April 2023 date
were verified on the original page. Failed-link and recovery evidence are retained.
All originals match their captured hashes. Every PDF page rendered in two engines.
The seven-column workbook passed native Excel checks before and after extraction,
including all 1,274 data cells and 364 hyperlinks. Publisher PDF structural warnings,
partial/missing issue dates and OCR limitations are disclosed in Audit and READ_ME.

The four exclusions were not expanded to remove every staffing or tender notice.
AEBC relevance is preliminary and role-specific, not a final legal/current-force
approval. Drafts, final policies and historical transition instructions are distinct.

The overall multi-regulator tranche remains in progress. The status table refers
only to packages actually uploaded here, not to final regulatory approval.
