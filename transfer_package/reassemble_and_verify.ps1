param(
    [string]$Folder = ".",
    [switch]$SkipExtract
)

$ErrorActionPreference = "Stop"
$folderPath = (Resolve-Path -LiteralPath $Folder).Path

$output = "verified_pdfs_only.7z"
$outputPath = Join-Path $folderPath $output
$expectedArchiveHash = "e11993ff63fcd4a92e9fda8715fdabebc0734c5b21836b790613a79a9194912c"
$expectedPdfCount = 13658
$expectedParts = [ordered]@{
    "verified_pdfs_only.7z.001" = @{ Bytes = 536870912; Sha256 = "e96801fbdcaf6ee72401c940b617e979947292b26797f7c4092e7cfa19dd23bb" }
    "verified_pdfs_only.7z.002" = @{ Bytes = 536870912; Sha256 = "a8c5cb20617b291bf89b42b1d0de34583647010ed7f3b18d19d71ecdf4c287c7" }
    "verified_pdfs_only.7z.003" = @{ Bytes = 536870912; Sha256 = "7bcb63efaf3d114b5e2902fa2b4e647cad9a709cf259a2a47ab2efac823af36b" }
    "verified_pdfs_only.7z.004" = @{ Bytes = 431234482; Sha256 = "d6070f64489a624ae54591c364a33fbf5c22c61ed886c2b22beca70af614cc7c" }
}

$parts = foreach ($name in $expectedParts.Keys) {
    Get-Item -LiteralPath (Join-Path $folderPath $name) -ErrorAction SilentlyContinue
}

if ($parts.Count -eq 0) {
    throw "No archive parts found. Expected files named verified_pdfs_only.7z.001 through verified_pdfs_only.7z.004. Use Git LFS, not GitHub Download ZIP."
}

foreach ($name in $expectedParts.Keys) {
    $part = Get-Item -LiteralPath (Join-Path $folderPath $name) -ErrorAction SilentlyContinue
    if (-not $part) {
        throw "Missing $name. All four archive parts must be in this folder."
    }

    $expected = $expectedParts[$name]
    if ($part.Length -ne $expected.Bytes) {
        throw "$name has size $($part.Length), expected $($expected.Bytes). If the file is tiny, Git LFS did not download it. Run: git lfs pull"
    }

    $hash = (Get-FileHash -LiteralPath $part.FullName -Algorithm SHA256).Hash.ToLowerInvariant()
    if ($hash -ne $expected.Sha256) {
        throw "$name failed SHA256 verification. Expected $($expected.Sha256), found $hash."
    }
}

if (Test-Path -LiteralPath $outputPath) {
    Remove-Item -LiteralPath $outputPath -Force
}

$outStream = [System.IO.File]::Open($outputPath, [System.IO.FileMode]::CreateNew)
try {
    foreach ($part in $parts) {
        Write-Host "Appending $($part.Name)"
        $inStream = [System.IO.File]::OpenRead($part.FullName)
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

Write-Host ""
Write-Host "Reassembled: $output"
Write-Host "Hash of reassembled archive:"
$archiveHash = (Get-FileHash -LiteralPath $outputPath -Algorithm SHA256).Hash.ToLowerInvariant()
Write-Host $archiveHash
if ($archiveHash -ne $expectedArchiveHash) {
    throw "Reassembled archive hash mismatch. Expected $expectedArchiveHash, found $archiveHash."
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
    Write-Host "7-Zip was not found automatically. Open verified_pdfs_only.7z with 7-Zip or an approved archive tool."
    exit 0
}

$extractFolder = "verified_pdfs_only"
$extractPath = Join-Path $folderPath $extractFolder
Write-Host ""
Write-Host "Extracting to $extractFolder using $sevenZip"
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
Write-Host "Done. Use dump_information_VERIFIED_FINAL_20_6.xlsx as the index/workbook."
