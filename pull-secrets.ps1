#!/usr/bin/env pwsh
# Script to pull secrets used in the given project from a custom static file server vault

param (
    [Parameter(Mandatory = $true)]
    [string]
    $Token
)

Write-Host $Token