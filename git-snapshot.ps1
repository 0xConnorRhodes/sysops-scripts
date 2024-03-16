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

$newFiles = ($status.Staged | ? ChangeType -eq 'newfile').Path | % { Remove-LeadingEscapedChar($_) }

$modifiedFiles = ($status.Staged | ? ChangeType -eq 'modified').Path | % { Remove-LeadingEscapedChar($_) }

$deletedFiles = ($status.Staged | ? ChangeType -eq 'deleted').Path | % { Remove-LeadingEscapedChar($_) }


$commitMessage = ""
if ($deletedFiles) {
	$commitMessage += "D: " + ($deletedFiles -join ",") + " "
}

if ($newFiles) {
	$commitMessage = $commitMessage +  "A: " + ($newFiles -join ",") + " "
}

if ($modifiedFiles) {
	$commitMessage = $commitMessage + "M: " + ($modifiedFiles -join ',')
}

git commit -m "$commitMessage"
git push
