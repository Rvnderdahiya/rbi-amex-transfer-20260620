param(
    [string]$Folder = "."
)

$ErrorActionPreference = "Stop"
$folderPath = Resolve-Path -LiteralPath $Folder
Set-Location $folderPath

$output = "verified_pdfs_only.7z"
$parts = Get-ChildItem -LiteralPath . -Filter "verified_pdfs_only.7z.part*" | Sort-Object Name
if ($parts.Count -eq 0) {
    throw "No archive parts found. Expected files like verified_pdfs_only.7z.part001"
}

if (Test-Path -LiteralPath $output) {
    Remove-Item -LiteralPath $output -Force
}

$outStream = [System.IO.File]::Open($output, [System.IO.FileMode]::CreateNew)
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
Get-FileHash -LiteralPath $output -Algorithm SHA256
Write-Host ""
Write-Host "Compare this hash with SHA256SUMS.txt before extracting."
