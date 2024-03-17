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
foreach ($file in $newAttachments) {
    if ((Get-FileHash $file -Algorithm MD5).Hash -in $existingAttachmentHashes.Hash) {
        continue
    }

    Get-ChildItem -Path $notesDir -Filter *.md -Recurse | ForEach-Object {
        $fileContent = Get-Content $_.FullName
        if ($fileContent -match $file.Name) {
            Write-Host "Found $($file.Name) in file: $($_.FullName)"
        }
    }
}