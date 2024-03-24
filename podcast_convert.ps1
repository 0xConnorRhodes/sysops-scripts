#!/usr/bin/env pwsh
# Script for pre-processing podcast audio files.

# CONFIG
$silent_speed = '20'
$vol_adjust = '0.07'
#$input_dir = '/zstore/media/podcasts/ashelf_podcasts'
$inputDir = '/zstore/media/podcasts/testdir'
$outputDir = '/zstore/media/audiobooks/audiobookshelf/podcasts'

$existingFiles = gci -Path $outputDir -File -Filter *.mp3 -Recurse
$inputFiles = gci -Path $inputDir -File -Filter *.mp3 -Recurse | 
    ? Name -NotLike *_ALTERED.mp3 |
    ? Name -NotLike *_FINAL.mp3 |
    ? Name -NotIn $existingFiles.Name


foreach ($file in $inputFiles) {
    $filenameAltered = $file.Name -replace '\.mp3$', '_ALTERED.mp3'
    auto-editor --no-open -s $silent_speed $file
    $filenameFinal = $file.Name -replace '\.mp3$', '_FINAL.mp3'
    ffmpeg -i $file -vn -filter:a "volume=$vol_adjust" "$($file.DirectoryName)/$filenameFinal"
    $outputSubdir = $file.DirectoryName -replace '.*?_original ', ''
    Move-Item -Path "$($file.DirectoryName)/$filenameFinal" -Destination "$outputDir/$outputSubdir/$($file.Name)"
    Remove-Item -Path "$($file.DirectoryName)/$filenameAltered"
}