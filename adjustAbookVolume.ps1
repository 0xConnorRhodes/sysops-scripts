#!/usr/bin/env pwsh
# Script to adjust the volume of m4b audiobook files in subdirectories of the current directory

Get-ChildItem -Directory | ForEach-Object {
    $directory = $_.FullName
    $m4bFiles = Get-ChildItem $directory -Filter "*.m4b" | Select-Object -ExpandProperty FullName

    foreach ($file in $m4bFiles) {
        $fileName = Split-Path -Path $file -Leaf
        $directoryPath = Split-Path -Path $file -Parent
    
	ffmpeg -i "$file" -an -vcodec copy ($directoryPath + 'cover.jpg')
        ffmpeg -i "$file" -vn -filter:a 'volume=0.07' ($directoryPath + '/07' + $fileName)

        Rename-Item -Path $file -NewName ($file + '.original')
    }
}
