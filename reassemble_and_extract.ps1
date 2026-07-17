$ErrorActionPreference = "Stop"

$Root = Split-Path -Parent $MyInvocation.MyCommand.Path
$ManifestPath = Join-Path $Root "archive_manifest.json"
$PartsDir = Join-Path $Root "archive_parts"
$ArchivePath = Join-Path $Root "PDFs.7z"
$ExpectedHash = "bd94044a00b0fd1d6aa9980cbe3d5ff8bb889d6c091b64df96254584d117cc50"
$ExpectedSize = 611263661

Write-Host "India LRR PDF package rebuild started..."
Write-Host "Working folder: $Root"

if (!(Test-Path -LiteralPath $ManifestPath)) {
    throw "archive_manifest.json was not found."
}
if (!(Test-Path -LiteralPath $PartsDir)) {
    throw "archive_parts folder was not found."
}

$Manifest = Get-Content -LiteralPath $ManifestPath -Raw | ConvertFrom-Json
$Parts = @($Manifest.parts)
if ($Parts.Count -eq 0) {
    throw "No archive parts listed in archive_manifest.json."
}

Write-Host "Checking $($Parts.Count) archive parts..."
foreach ($Part in $Parts) {
    $PartPath = Join-Path $PartsDir $Part.part
    if (!(Test-Path -LiteralPath $PartPath)) {
        throw "Missing archive part: $($Part.part)"
    }
    $ActualSize = (Get-Item -LiteralPath $PartPath).Length
    if ($ActualSize -ne [int64]$Part.size_bytes) {
        throw "Archive part has wrong size: $($Part.part). Expected $($Part.size_bytes), got $ActualSize."
    }
}

if (Test-Path -LiteralPath $ArchivePath) {
    Remove-Item -LiteralPath $ArchivePath -Force
}

Write-Host "Rebuilding PDFs.7z..."
$Out = [System.IO.File]::Open($ArchivePath, [System.IO.FileMode]::CreateNew, [System.IO.FileAccess]::Write)
try {
    foreach ($Part in $Parts) {
        $PartPath = Join-Path $PartsDir $Part.part
        $In = [System.IO.File]::OpenRead($PartPath)
        try {
            $In.CopyTo($Out)
        }
        finally {
            $In.Close()
        }
    }
}
finally {
    $Out.Close()
}

$ArchiveItem = Get-Item -LiteralPath $ArchivePath
if ($ArchiveItem.Length -ne $ExpectedSize) {
    throw "Rebuilt archive has wrong size. Expected $ExpectedSize, got $($ArchiveItem.Length)."
}

$ActualHash = (Get-FileHash -Algorithm SHA256 -LiteralPath $ArchivePath).Hash.ToLowerInvariant()
if ($ActualHash -ne $ExpectedHash) {
    throw "Rebuilt archive hash does not match. Expected $ExpectedHash, got $ActualHash."
}

Write-Host "Archive rebuilt and verified successfully."

$SevenZipCandidates = @(
    "7z",
    "7za",
    "C:\Program Files\7-Zip\7z.exe",
    "C:\Program Files (x86)\7-Zip\7z.exe"
)

$Extractor = $null
foreach ($Candidate in $SevenZipCandidates) {
    try {
        $Cmd = Get-Command $Candidate -ErrorAction Stop
        $Extractor = $Cmd.Source
        break
    }
    catch {
    }
}

if ($Extractor) {
    Write-Host "Extracting PDFs.7z using 7-Zip..."
    & $Extractor x $ArchivePath "-o$Root" -y
    if ($LASTEXITCODE -ne 0) {
        throw "7-Zip extraction failed with exit code $LASTEXITCODE."
    }
}
else {
    Write-Host "7-Zip was not found. Trying Windows tar extraction..."
    $TarCmd = Get-Command tar -ErrorAction SilentlyContinue
    if ($TarCmd) {
        & $TarCmd.Source -xf $ArchivePath -C $Root
        if ($LASTEXITCODE -ne 0) {
            Write-Host "Windows tar could not extract the archive."
            Write-Host "PDFs.7z has been rebuilt successfully. Please open it manually with 7-Zip or Windows Explorer if supported."
            exit 0
        }
    }
    else {
        Write-Host "No extractor was found."
        Write-Host "PDFs.7z has been rebuilt successfully. Please open it manually with 7-Zip or Windows Explorer if supported."
        exit 0
    }
}

$PdfRoot = Join-Path $Root "PDFs"
$Folder1 = Join-Path $PdfRoot "01_PDFs_Matched_With_RBI_Dump"
$Folder2 = Join-Path $PdfRoot "02_PDFs_Not_Matched_With_RBI_Dump"
$Folder3 = Join-Path $PdfRoot "03_RBI_Dump_PDFs_Not_In_Final_KMT_Inventory"

Write-Host ""
Write-Host "Extraction check:"
foreach ($Folder in @($Folder1, $Folder2, $Folder3)) {
    if (Test-Path -LiteralPath $Folder) {
        $Count = (Get-ChildItem -LiteralPath $Folder -Filter *.pdf -File | Measure-Object).Count
        Write-Host "$([System.IO.Path]::GetFileName($Folder)): $Count PDFs"
    }
    else {
        Write-Host "$([System.IO.Path]::GetFileName($Folder)): folder not found"
    }
}

"Extraction completed on $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')" | Set-Content -LiteralPath (Join-Path $Root "EXTRACTION_COMPLETE.txt")
Write-Host ""
Write-Host "Done. Use the workbook and the PDFs folder from this same location."
