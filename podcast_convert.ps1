#!/usr/bin/env pwsh
# Script for pre-processing podcast audio files.

# CONFIG
$silent_speed = '20'
$vol_adjust = '0.07'
$podcastsDir = '/zstore/media/podcasts/ashelf_podcasts'

$newFiles = gci -Path $podcastsDir -File -Filter *.mp3 -Recurse |
    ? Name -NotLike "*_FINAL.mp3" |
    ? Name -NotLike "*_ALTERED.mp3"

foreach ($file in $newFiles) {
    $filenameAltered = $file.Name -replace '\.mp3$', '_ALTERED.mp3'
    $filenameFinal = $file.Name -replace '\.mp3$', '_FINAL.mp3'

    auto-editor --no-open -s $silent_speed $file
    ffmpeg -i $file -vn -filter:a "volume=$vol_adjust" "$($file.DirectoryName)/$filenameFinal"
    Remove-Item -Path "$($file.DirectoryName)/$filenameAltered"
    Remove-Item -Path $file
    Rename-Item -Path "$($file.DirectoryName)/$filenameFinal" -NewName $file
}
