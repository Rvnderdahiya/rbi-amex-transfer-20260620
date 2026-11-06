CKYCR REGULATORY INVENTORY
Collection cut-off: 5 November 2026
Purpose: Tranche 2 source inventory and preliminary AEBC review

START HERE
Open CKYCR_Inventory.xlsx after extracting the whole package. Keep it beside
the Originals, Supporting and Audit folders. Clicking a document name opens
the downloaded original; clicking CKYCR in Website name opens its source URL.
Do not move the workbook away from these folders.

WHAT IS INCLUDED
126 source-list occurrences are represented by 123 document entries.
Three repeated occurrences point to exact same originals. Their listing titles,
dates, sections and URLs are retained in Audit/source_occurrences.csv.
This is document-level deduplication, not a count of individual legal duties.

There are 123 original PDFs containing 252 pages, plus two original ZIPs,
one original DOCX consent template and one publisher-supplied JPG banner.
The banner is an actual source attachment, not a generated screenshot.
PDFs extracted from those source ZIPs are already counted within the 123 PDFs.
No publisher file has been rewritten or replaced with a screenshot/HTML PDF.

FOLDERS
Originals/Notifications: original notification and related statutory PDFs.
Originals/Communiques: original letters, communiques and operational guidance.
Originals/Controlled: two SOP versions marked Confidential by the publisher.
Supporting: the two original ZIPs, consent DOCX and publisher banner.
Audit: source-to-file mapping, checksums, evidence and disclosed open issues.

THE SEVEN COLUMNS
Name: document name, linked to its local original PDF. The cell note identifies
the short file name, supporting originals and document-review basis.
Date: date printed in the original. For the two SOPs this is explicitly a
version date, identified in Nature and the date-cell note, not an issue date.
For 16 undated documents, Date says Not stated. Website listing dates are
retained in the audit mapping and have not been substituted as issue dates.
Issuing Authority: actual issuer; a Ministry of Finance notification hosted
by CKYCR is not described as legislation issued by CKYCR.
Nature: notification, statutory amendment, communique, letter, SOP, etc.
Website name: CKYCR, linked to the official original-download URL.
Applicability for AEBC: document-specific preliminary assessment and condition.
Addressee: printed To block, or an expressly identified body-scope audience
when the original has no formal To block.

APPLICABILITY AND HISTORICAL DOCUMENTS
AEBC means American Express Banking Corporation, India, not every company in
the American Express group. Conditional means that the stated registration,
channel, customer type, transaction or incident must be confirmed by AEBC.
Informational means contextual guidance or an obligation addressed to another
actor; it is not automatically a direct AEBC mandate. A PSB-only letter is
retained but identified as outside AEBC's direct addressee under that letter.

This inventory includes historical notices, reminders, release plans and
distinct versions. It is NOT an active-only register. Preliminary relevance
does not establish current legal force or a final applicability decision.
Compliance must confirm the business facts, operative version and legal status
before using a historical instruction as a present-day obligation.

VALIDATION AND LIMITATIONS
Every packaged file matches the preserved original SHA256 and byte length.
Every page of all 123 packaged PDFs opened and rendered in MuPDF and PDFium.
Six publisher originals (C012, C017, C018, C019, C020 and C021) trigger structural
recovery in MuPDF, although PDFium opens/renders them. They remain unchanged
and are flagged in Audit/file_opening_checks.json. No signature-validity or
publisher-file-completeness certificate is implied by successful rendering.

The collected Notifications and Communiques listings and evidenced successor
portal were reconciled. This does not certify that every item ever issued by
CKYCR, every website section, or every historical supporting specification is
available. Seventeen explicit technical/manual/archive reference URLs could not
be retrieved (connection resets/timeouts) and remain open in
Audit/supporting_reference_exceptions.csv.
Those are references inside the collected PDFs, not 17 missing main notices.
Do not describe this as a complete historical technical-specification archive.
English operative content was reviewed; no certified Hindi/English equivalence
review or independent human legal sign-off has been performed.

CONTROLLED HANDLING
The SOP originals carry a Confidential marking. Use approved internal storage
and access controls. Do not upload this package to public GitHub or other public
sharing services. No external upload has been performed for this tranche.

OVERALL PROJECT STATUS
This is the CKYCR review package only. IRDAI, CERSAI, UIDAI, FIU India and the
Gazette ministry inventories still have separate validation/collection work.
It is not the final combined Tranche 2 delivery or an audit approval.
