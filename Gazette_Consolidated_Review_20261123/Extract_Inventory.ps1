param([string]$Destination=$PSScriptRoot,[switch]$NoLaunch)
$ErrorActionPreference='Stop'
$manifest=Get-Content -LiteralPath (Join-Path $PSScriptRoot 'Transfer_Manifest.json') -Raw -Encoding UTF8|ConvertFrom-Json
if($manifest.root_folder -notmatch '^(IRDAI|Gazette|UIDAI)_Reviewed$'){throw 'Unexpected package root'}
$parent=[IO.Path]::GetFullPath($Destination)
if(-not (Test-Path -LiteralPath $parent -PathType Container)){throw 'Select an existing short destination folder'}
$target=[IO.Path]::GetFullPath((Join-Path $parent $manifest.root_folder))
if((Split-Path -Parent $target) -cne $parent -or (Test-Path -LiteralPath $target)){throw 'Destination already exists or is invalid. Select a new empty destination; nothing has been overwritten.'}
$stage=[IO.Path]::GetFullPath((Join-Path $parent ('Extract_'+[guid]::NewGuid().ToString('N'))))
if((Split-Path -Parent $stage) -cne $parent -or $stage.Length -gt 140){throw 'Use a shorter destination folder'}
$seen=@{}
Add-Type -AssemblyName System.IO.Compression.FileSystem
foreach($package in $manifest.packages){
    if($package.file -notmatch '^(IRDAI|Gazette|UIDAI)_Reviewed_\d+\.zip$'){throw 'Unexpected archive name'}
    $zip=Join-Path $PSScriptRoot $package.file
    if((Get-Item -LiteralPath $zip).Length -ne $package.bytes -or (Get-FileHash -LiteralPath $zip -Algorithm SHA256).Hash.ToLowerInvariant() -cne $package.sha256){throw ('Missing or changed ZIP: '+$package.file)}
    $archive=[IO.Compression.ZipFile]::OpenRead($zip)
    try{
        foreach($entry in $archive.Entries){
            $name=$entry.FullName
            if(-not $name.StartsWith($manifest.root_folder+'/',[StringComparison]::Ordinal) -or $name.Contains('\') -or $name.Contains(':') -or $name.Split('/') -contains '..' -or $seen.ContainsKey($name)){throw 'Unsafe or repeated archive member'}
            $relative=$name.Substring($manifest.root_folder.Length+1)
            $expected=$manifest.expected_payload_files.PSObject.Properties[$relative]
            if(-not $expected -or $entry.Length -ne $expected.Value.bytes){throw 'Unknown archive member or wrong length'}
            $seen[$name]=$true
        }
    }finally{$archive.Dispose()}
}
if($seen.Count -ne @($manifest.expected_payload_files.PSObject.Properties).Count){throw 'Incomplete archive member set'}
New-Item -ItemType Directory -Path $stage|Out-Null
foreach($package in $manifest.packages){
    Write-Host ('Extracting '+$package.file)
    Expand-Archive -LiteralPath (Join-Path $PSScriptRoot $package.file) -DestinationPath $stage
}
$root=[IO.Path]::GetFullPath((Join-Path $stage $manifest.root_folder))
foreach($item in $manifest.expected_payload_files.PSObject.Properties){
    $file=[IO.Path]::GetFullPath((Join-Path $root $item.Name))
    if(-not $file.StartsWith($root+'\',[StringComparison]::OrdinalIgnoreCase) -or $file.Length -gt 245){throw 'Invalid or overlong extracted path'}
    if((Get-Item -LiteralPath $file).Length -ne $item.Value.bytes -or (Get-FileHash -LiteralPath $file -Algorithm SHA256).Hash.ToLowerInvariant() -cne $item.Value.sha256){throw ('Extracted file differs: '+$item.Name)}
}
if((Split-Path -Parent $root) -cne $stage -or (Split-Path -Parent $target) -cne $parent -or (Test-Path -LiteralPath $target)){throw 'Destination changed during extraction. Validated staging files have been preserved.'}
Move-Item -LiteralPath $root -Destination $target
Write-Host ('Completed. Open '+(Join-Path $target $manifest.workbook))
if(-not $NoLaunch){Start-Process -FilePath explorer.exe -ArgumentList ('"'+$target+'"')}
