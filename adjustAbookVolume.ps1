#!/usr/bin/env pwsh
# Script to adjust the volume of m4b audiobook files in subdirectories of the current directory

$volAdjust = '0.08'
$outputFolder = '/zstore/media/audiobooks/audiobookshelf/audiobooks'

Get-ChildItem -Directory | ForEach-Object {
    $directory = $_.FullName
    $m4bFiles = Get-ChildItem $directory -Filter "*.m4b" | Select-Object -ExpandProperty FullName

    foreach ($file in $m4bFiles) {
        $fileName = Split-Path -Path $file -Leaf
        $directoryPath = Split-Path -Path $file -Parent
	$tempName = $directoryPath + '/q' + $fileName
    
        ffmpeg -i "$file" -vn -filter:a ('volume=' + $volAdjust) $tempName

	Remove-Item -Path $file   
	Rename-Item -Path $tempName -NewName $file
        Move-Item -Path $directoryPath -Destination $outputFolder
    }
}
