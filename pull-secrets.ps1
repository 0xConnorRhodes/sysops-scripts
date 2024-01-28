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

    # TODO: store current directory in $Folder
    # TODO: parse .gitignore and for-each file in gitignore, try invoke-webrequest ignorring 404s 

    # main request
    # Invoke-WebRequest -Uri ($Url + $Folder + $File + '?' + $Token) -OutFile $File
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