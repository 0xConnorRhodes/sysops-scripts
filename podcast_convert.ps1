#!/usr/bin/env pwsh
# Script for pre-processing podcast audio files.

# CONFIG
$silent_speed = '20'
$vol_adjust = '0.08'
$inputDir = '/media/podcasts/ashelf_casts/podcast_originals'
$outputDir = '/media/podcasts/ashelf_casts/podcast_audioadjust'

$existingFiles = gci -Path $outputDir -File -Filter *.mp3 -Recurse
$newFiles = gci -Path $inputDir -File -Filter *.mp3 -Recurse |
    ? Name -NotLike "*_FINAL.mp3" |
    ? Name -NotLike "*_ALTERED.mp3" |
    ? Name -NotIn $existingFiles.Name

foreach ($file in $newFiles) {
    $filenameAltered = $file.Name -replace '\.mp3$', '_ALTERED.mp3'
    $filenameFinal = $file.Name -replace '\.mp3$', '_FINAL.mp3'

    docker exec -it auto-editor auto-editor --no-open -s $silent_speed $file
    ffmpeg -i $file -vn -filter:a "volume=$vol_adjust" "$($file.DirectoryName)/$filenameFinal"
    Remove-Item -Path "$($file.DirectoryName)/$filenameAltered"
    Move-Item -Path "$($file.DirectoryName)/$filenameFinal" -Destination "$outputDir/$($file.Directory.Name)/$($file.Name)"
}
