# Define the URLs
$ProgressPreference = 'SilentlyContinue'
if (-not (Get-Command -ErrorAction Ignore -Type Cmdlet Start-ThreadJob)) {
    Write-Verbose "Installing module 'ThreadJob' on demand..."
    Install-Module -Name ThreadJob -ErrorAction Stop -Scope CurrentUser -Force
}
$savedCodeVersionFileName = "code_version.txt"
$savedCodeVersion = ""
try {
    $savedCodeVersion = Get-Content -Path $savedCodeVersionFileName -ErrorAction Stop
    # Process $content here
}
catch {}


$modDownloadFileName = "download_mods.ps1"
$url = "https://github.com/nightmaster611/lethal-company/releases/latest"
$htmlString = Invoke-RestMethod -Uri $url
$assetLink = [regex]::Match($htmlString, 'https://github.com/nightmaster611/lethal-company/releases/expanded_assets/[^\"]+').Value
if ($assetLink -ne $savedCodeVersion) {
    $assetVersion = ($assetLink -split "/")[-1]
    # $newCodeDownloadLink = [regex]::Match($htmlString, '/nightmaster611/lethal-company/archive/refs/tags/[^\"]+').Value
    $newCodeVersionDownloadLink = "https://github.com/nightmaster611/lethal-company/archive/refs/tags/$assetVersion.zip"
    Invoke-WebRequest $newCodeVersionDownloadLink -OutFile "code.zip"
    Expand-Archive "code.zip" -DestinationPath "." -Force
    Remove-Item -Path "code.zip" -Recurse -Force
    $newCodeFolder = Get-ChildItem -Path "." -Directory -Filter "lethal-company-$assetVersion"
    if ($newCodeFolder) {
        Remove-Item $modDownloadFileName
        Move-Item "$newCodeFolder\$modDownloadFileName" -Destination '.'
    }
    Remove-Item $newCodeFolder -Force -Recurse
    Set-Content -Path $savedCodeVersionFileName -Value $assetLink
}

& .\$modDownloadFileName