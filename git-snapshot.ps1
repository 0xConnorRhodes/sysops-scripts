#!/usr/bin/env pwsh
# script to autocommit and push all changes in a local git repo

set-location $args[0]

Import-Module ugit -Force -PassThru

function Remove-LeadingEscapedChar {
    param (
        [string]$InputString
    )

    $InputString = $InputString -replace '"', ''
    $InputString = $InputString -replace '\.md$', ''

    if ($InputString.StartsWith('\')) {
        $InputString -replace '^\\.*?\s', ''
    } else {
        $InputString
    }

}

git add .

$status = git status

$newFiles = ($status.Staged | ? ChangeType -eq 'newfile').Path | foreach-object { Remove-LeadingEscapedChar($_) }

$modifiedFiles = ($status.Staged | ? ChangeType -eq 'modified').Path | ForEach-Object { Remove-LeadingEscapedChar($_) }

$deletedFiles = ($status.Staged | ? ChangeType -eq 'deleted').Path | foreach-object { Remove-LeadingEscapedChar($_) }


$commitMessage = ""
if ($deletedFiles) {
	$commitMessage += "DELETED: " + ($deletedFiles -join ",") + " "
}

if ($newFiles) {
	$commitMessage = $commitMessage +  "ADDED: " + ($newFiles -join ",") + " "
}

if ($modifiedFiles) {
	$commitMessage = $commitMessage + "CHANGED: " + ($modifiedFiles -join ',')
}

git commit -m "$commitMessage"
git push
