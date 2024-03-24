#!/usr/bin/env pwsh
# Script for pre-processing podcast audio files.

# CONFIG
$silent_speed = '20'
$vol_adjust = '0.07'
$inputDir = '/zstore/media/podcasts/podgrab'
$outputDir = '/zstore/media/podcasts/ashelf_podcasts'

$existingFiles = gci -Path $outputDir -File -Filter *.mp3 -Recurse
$inputFiles = gci -Path $inputDir -File -Filter *.mp3 -Recurse | 
    ? Name -NotLike *_ALTERED.mp3 |
    ? Name -NotLike *_FINAL.mp3 |
    ? Name -NotIn $existingFiles.Name


foreach ($file in $inputFiles) {
    # CALCULATE ARGS
    $filenameAltered = $file.Name -replace '\.mp3$', '_ALTERED.mp3'
    $filenameFinal = $file.Name -replace '\.mp3$', '_FINAL.mp3'
    $finalFilePath = "$($file.DirectoryName)/$filenameFinal"
    $finalFileDestination = "$outputDir/$($file.Directory.Name)/$($file.Name)"

    # RUN COMMANDS
    auto-editor --no-open -s $silent_speed $file
    ffmpeg -i $file -vn -filter:a "volume=$vol_adjust" "$($file.DirectoryName)/$filenameFinal"
    Move-Item -Path $finalFilePath -Destination $finalFileDestination
    Remove-Item -Path "$($file.DirectoryName)/$filenameAltered"
}
