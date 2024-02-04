#!/usr/bin/env pwsh
# Script to pull secrets used in the given project from a custom static file server vault

function Get-Secrets {
    param (
    [Parameter(Mandatory = $true)]
    [string]
    $Url,
    [Parameter(Mandatory = $true)]
    [string]
    $Token
    )

    $project = (Get-Item -Path ".").Name

    $insideSecrets = $false
    $secrets = @()
    foreach ($line in Get-Content .gitignore) {
        if ($line -eq '# end secrets') {
            $insideSecrets = $false
        }
        if ($insideSecrets) {
            $secrets += $line
        }
        if ($line -eq '# begin secrets') {
            $insideSecrets = $true
        }
    }

    foreach ($file in $secrets) {
        $request = $Url + $project + '/' + $file + '?' + $Token
        Invoke-WebRequest -Uri $request -OutFile $file
    }
}

if (Test-Path -Path ".vaultsecrets.json") {
    $secrets = Get-Content -Path ".vaultsecrets.json" | ConvertFrom-Json
    $Url = $secrets.Url
    $Token = $secrets.Token

    Get-Secrets -Url $Url -Token $Token
}
else {
    Get-Secrets
    # TODO: offer to save $Url and $Token in .vaultsecrets.json
}