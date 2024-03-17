#!/usr/bin/env pwsh
# Script to move note attachments to my static file server 
# and embed a secure access link in the original note

$notesDir = '/zstore/data/zk_notes/zk_notes'
$attachmentsDir = '/zstore/data/zk_notes/zk_notes/zattachments'
$staticFilesDir = '/zstore/static_files/nats'

$existingAttachmentHashes = @()
foreach ($file in Get-ChildItem $staticFilesDir -File) {
    $existingAttachmentHashes += Get-FileHash $file -Algorithm MD5
}

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
    }
    else {
        $newName = $fileName -replace ' ', '-'
    }
    $newName
}