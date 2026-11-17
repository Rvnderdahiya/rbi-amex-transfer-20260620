param([string]$Destination, [switch]$NoOpen)
$ErrorActionPreference = 'Stop'
$summaryPath = Join-Path $PSScriptRoot 'Validation_Summary.json'
if (-not (Test-Path -LiteralPath $summaryPath)) { throw 'Download Validation_Summary.json alongside this setup and all fourteen ZIPs first.' }
if ((Get-FileHash -LiteralPath $summaryPath -Algorithm SHA256).Hash.ToLowerInvariant() -cne '500031e39e299b3bb74b2495b5b97fc55dcd35173fd4497d4a9b40fd8f3c9877') { throw 'Validation summary differs. Download a fresh copy from the same batch folder.' }
$control = Get-Content -LiteralPath $summaryPath -Raw -Encoding UTF8 | ConvertFrom-Json
if ($control.source_records -ne 625 -or $control.distinct_pdf_payloads -ne 641 -or $control.packages.Count -ne 14) { throw 'Unexpected package summary' }
foreach ($package in $control.packages) {
    if ($package.file -notmatch '^IRDAI_Batch02_(Inventory|Originals_[0-9]{2})\.zip$') { throw 'Unexpected ZIP filename' }
    $file = Join-Path $PSScriptRoot $package.file
    if (-not (Test-Path -LiteralPath $file)) { throw "Missing ZIP: $($package.file). Download all fourteen ZIPs into this same folder." }
    if ((Get-Item -LiteralPath $file).Length -ne $package.bytes -or (Get-FileHash -LiteralPath $file -Algorithm SHA256).Hash.ToLowerInvariant() -cne $package.sha256) { throw "Corrupt or incomplete download: $($package.file)" }
}
if (-not $Destination) {
    $default = Join-Path $env:USERPROFILE 'Documents\LRR_Batch02'
    $chosen = Read-Host "Destination folder (press Enter for $default)"
    $Destination = if ([string]::IsNullOrWhiteSpace($chosen)) { $default } else { $chosen.Trim('"') }
}
$Destination = [IO.Path]::GetFullPath($Destination)
if (Test-Path -LiteralPath $Destination) {
    if (@(Get-ChildItem -LiteralPath $Destination -Force).Count -gt 0) { throw 'Choose a new or empty destination. Setup will not overwrite an existing collection.' }
} else { New-Item -ItemType Directory -Path $Destination | Out-Null }
foreach ($package in $control.packages) {
    Write-Host "Extracting $($package.file)"
    Expand-Archive -LiteralPath (Join-Path $PSScriptRoot $package.file) -DestinationPath $Destination -Force
}
$folder = Join-Path $Destination 'IRDAI_Batch02'
$count = 0
foreach ($line in Get-Content -LiteralPath (Join-Path $folder 'SHA256SUMS.txt') -Encoding UTF8) {
    if ($line -notmatch '^[0-9a-f]{64}  .+$') { throw 'Invalid internal checksum record' }
    $relative = $line.Substring(66)
    $file = [IO.Path]::GetFullPath((Join-Path $folder $relative))
    if (-not $file.StartsWith($folder + '\', [StringComparison]::OrdinalIgnoreCase)) { throw 'Unexpected internal file path' }
    if ((Get-FileHash -LiteralPath $file -Algorithm SHA256).Hash.ToLowerInvariant() -cne $line.Substring(0,64)) { throw "Extracted file does not match: $relative" }
    $count++
}
$pdfs = @(Get-ChildItem -LiteralPath (Join-Path $folder 'Originals') -Filter '*.pdf' -File)
if ($count -ne 646 -or $pdfs.Count -ne 641) { throw 'Extracted file counts differ from the validated package' }
Write-Host "Completed: 625 inventory records, 641 original PDFs, and 646 verified data files."
Write-Host "Workbook: $(Join-Path $folder 'IRDAI_Inventory_Batch_02.xlsx')"
Write-Host 'This is an interim review batch, not the complete IRDAI inventory or Legal/Compliance approval.'
if (-not $NoOpen) { Start-Process -FilePath explorer.exe -ArgumentList ('"' + $folder + '"') }
