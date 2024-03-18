#!/usr/bin/env pwsh
# Script to move note attachments to my static file server 
# and embed a secure access link in the original note

$ErrorActionPreference = "Stop"

$notesDir = '/zstore/data/zk_notes/zk_notes'
$attachmentsDir = '/zstore/data/zk_notes/zk_notes/zattachments'
$staticFilesDir = '/zstore/static_files/nats'
$staticServer = Get-Content -Path ".sfsToken.json" | ConvertFrom-Json
$Url = $staticServer.Url
$Token = $staticServer.Token

$existingAttachmentHashes = @()
foreach ($file in Get-ChildItem $staticFilesDir -File) {
    $existingAttachmentHashes += Get-FileHash $file -Algorithm MD5
}

# TODO: for each existing attachment, generate secure link to existing attachment, insert into note, and remove local file

$newAttachments = Get-ChildItem $attachmentsDir
$newAttachmentsMap = @{}
foreach ($file in $newAttachments) {
    if ((Get-FileHash $file -Algorithm MD5).Hash -in $existingAttachmentHashes.Hash) {
        continue
    }

    Get-ChildItem -Path $notesDir -Filter *.md -Recurse | ForEach-Object {
        $fileContent = Get-Content $_.FullName
        if ($fileContent -match $file.Name) {
            $newAttachmentsMap["$($file.Name)"] = $($_.FullName)
        }
    }
}

$existingAttachments = Get-ChildItem -Recurse -File $staticFilesDir
foreach ($fileName in $newAttachmentsMap.Keys) {
    if ($fileName -in $existingAttachments.Name) {
        $count = 1
        $fileName = $fileName -split "\.(?=[^.]+$)"
        $newName = $fileName[0] + '-' + $count + '.' + $fileName[1]

        while ($newName -in $existingAttachments.Name) {
            $count += 1
            $newName = $fileName[0] + '-' + $count + '.' + $fileName[1]
        }
        $newName = $newName -replace ' ', '-'
    }
    else {
        $newName = $fileName -replace ' ', '-'
    }
    Move-Item -Path $attachmentsDir/$fileName -Destination $staticFilesDir/$newName

    $attachmentLink = $Url + '/nats/' + $newName + '?' + $Token

    $noteFile = Get-Content $newAttachmentsMap[$fileName]

    $noteFile.Replace("![[$fileName]]", "![]($attachmentLink)") | Set-Content $newAttachmentsMap[$fileName]
}

# NOTE: must handle the case of the same attachment being attached to multiple notes (or the same note twice) before this script is run
# TODO: add ping to pushover if there is an error. save error output to log file