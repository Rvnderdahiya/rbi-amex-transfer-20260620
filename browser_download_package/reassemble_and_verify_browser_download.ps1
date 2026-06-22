param(
    [string]$Folder = ".",
    [switch]$SkipExtract
)

$ErrorActionPreference = "Stop"
$folderPath = (Resolve-Path -LiteralPath $Folder).Path
$chunkFolder = Join-Path $folderPath "chunks"
$output = "verified_pdfs_only.7z"
$outputPath = Join-Path $folderPath $output
$expectedArchiveHash = "e11993ff63fcd4a92e9fda8715fdabebc0734c5b21836b790613a79a9194912c"
$expectedArchiveBytes = 2041847218
$expectedChunkCount = 41
$expectedPdfCount = 13658

if (-not (Test-Path -LiteralPath $chunkFolder)) {
    throw "Missing chunks folder. Expected: $chunkFolder"
}

$chunks = Get-ChildItem -LiteralPath $chunkFolder -Filter "verified_pdfs_only.7z.chunk*" | Sort-Object Name
if ($chunks.Count -ne $expectedChunkCount) {
    throw "Expected $expectedChunkCount chunks, found $($chunks.Count). Re-download the GitHub ZIP and extract it fully."
}

$totalChunkBytes = ($chunks | Measure-Object Length -Sum).Sum
if ($totalChunkBytes -ne $expectedArchiveBytes) {
    throw "Chunk total is $totalChunkBytes bytes, expected $expectedArchiveBytes bytes. The ZIP download or extraction is incomplete."
}

if (Test-Path -LiteralPath $outputPath) {
    Remove-Item -LiteralPath $outputPath -Force
}

Write-Host "Reassembling archive from $expectedChunkCount chunks..."
$outStream = [System.IO.File]::Open($outputPath, [System.IO.FileMode]::CreateNew)
try {
    foreach ($chunk in $chunks) {
        Write-Host "Appending $($chunk.Name)"
        $inStream = [System.IO.File]::OpenRead($chunk.FullName)
        try {
            $inStream.CopyTo($outStream)
        }
        finally {
            $inStream.Dispose()
        }
    }
}
finally {
    $outStream.Dispose()
}

$archive = Get-Item -LiteralPath $outputPath
if ($archive.Length -ne $expectedArchiveBytes) {
    throw "Reassembled archive size is $($archive.Length), expected $expectedArchiveBytes."
}

$archiveHash = (Get-FileHash -LiteralPath $outputPath -Algorithm SHA256).Hash.ToLowerInvariant()
Write-Host ""
Write-Host "Reassembled archive:"
Write-Host $outputPath
Write-Host ""
Write-Host "SHA256:"
Write-Host $archiveHash

if ($archiveHash -ne $expectedArchiveHash) {
    throw "Archive SHA256 mismatch. Expected $expectedArchiveHash."
}

Write-Host ""
Write-Host "Archive SHA256 verified successfully."

if ($SkipExtract) {
    Write-Host "Skipping extraction because -SkipExtract was supplied."
    exit 0
}

$sevenZipCandidates = @(
    "7z.exe",
    "$env:ProgramFiles\7-Zip\7z.exe",
    "${env:ProgramFiles(x86)}\7-Zip\7z.exe"
)

$sevenZip = $null
foreach ($candidate in $sevenZipCandidates) {
    if ([string]::IsNullOrWhiteSpace($candidate)) {
        continue
    }

    $command = Get-Command $candidate -ErrorAction SilentlyContinue
    if ($command) {
        $sevenZip = $command.Source
        break
    }
}

if (-not $sevenZip) {
    Write-Host ""
    Write-Host "7-Zip was not found automatically."
    Write-Host "The verified archive has been created here:"
    Write-Host $outputPath
    Write-Host "Open this .7z file with the approved 7-Zip/archive tool and extract it into this same folder."
    exit 0
}

$extractFolder = "verified_pdfs_only"
$extractPath = Join-Path $folderPath $extractFolder
Write-Host ""
Write-Host "Extracting to $extractPath using $sevenZip"
& $sevenZip x $outputPath "-o$extractPath" -y
if ($LASTEXITCODE -ne 0) {
    throw "7-Zip extraction failed with exit code $LASTEXITCODE."
}

$actualPdfCount = (Get-ChildItem -LiteralPath $extractPath -Recurse -Filter *.pdf | Measure-Object).Count
Write-Host ""
Write-Host "Extracted PDF count: $actualPdfCount"
Write-Host "Expected PDF count:  $expectedPdfCount"
if ($actualPdfCount -ne $expectedPdfCount) {
    throw "PDF count mismatch after extraction."
}

Write-Host ""
Write-Host "Done. Use dump_information_VERIFIED_FINAL_20_6.xlsx as the index workbook."
