# Define the URLs
$ProgressPreference = 'SilentlyContinue'
if (-not (Get-Command -ErrorAction Ignore -Type Cmdlet Start-ThreadJob)) {
    Write-Verbose "Installing module 'ThreadJob' on demand..."
    Install-Module -Name ThreadJob -ErrorAction Stop -Scope CurrentUser -Force
}


$urls = @(
    "https://thunderstore.io/c/lethal-company/p/BepInEx/BepInExPack/"
    "https://thunderstore.io/c/lethal-company/p/notnotnotswipez/MoreCompany/",
    "https://thunderstore.io/c/lethal-company/p/Sligili/More_Emotes/",
    "https://thunderstore.io/c/lethal-company/p/x753/More_Suits/",
    "https://thunderstore.io/c/lethal-company/p/Verity/TooManySuits/",
    "https://thunderstore.io/c/lethal-company/p/Dwarggo/Fashion_Company/",
    "https://thunderstore.io/c/lethal-company/p/TeamClark/SCP_Foundation_Suit/",
    "https://thunderstore.io/c/lethal-company/p/akkowo/More_suit_colors_for_more_suits/",
    "https://thunderstore.io/c/lethal-company/p/Norman/GlowStickSuits/",
    "https://thunderstore.io/c/lethal-company/p/anormaltwig/LateCompany/",
    "https://thunderstore.io/c/lethal-company/p/RugbugRedfern/Skinwalkers/",
    "https://thunderstore.io/c/lethal-company/p/Sligili/HDLethalCompany/",
    "https://thunderstore.io/c/lethal-company/p/Midge/PushCompany/",
    "https://thunderstore.io/c/lethal-company/p/sunnobunno/LandMineFartReverb/",
    "https://thunderstore.io/c/lethal-company/p/Nips/Brutal_Company_Plus/",
    "https://thunderstore.io/c/lethal-company/p/Stoneman/LethalProgression/",
    "https://thunderstore.io/c/lethal-company/p/EliteMasterEric/Coroner/",
    "https://thunderstore.io/c/lethal-company/p/Evaisa/LethalThings/",
    "https://thunderstore.io/c/lethal-company/p/FlipMods/ReservedWalkieSlot/",
    "https://thunderstore.io/c/lethal-company/p/FlipMods/ReservedFlashlightSlot/",
    "https://thunderstore.io/c/lethal-company/p/FlipMods/ReservedItemSlotCore/",
    "https://thunderstore.io/c/lethal-company/p/TwinDimensionalProductions/CoilHeadStare/",
    "https://thunderstore.io/c/lethal-company/p/Evaisa/LethalLib/",
    "https://thunderstore.io/c/lethal-company/p/Evaisa/HookGenPatcher/",
    "https://thunderstore.io/c/lethal-company/p/MetalPipeSFX/HornMoan/",
    "https://thunderstore.io/c/lethal-company/p/OrtonLongGaming/FreddyBracken/",
    "https://thunderstore.io/c/lethal-company/p/x753/Mimics/",
    "https://thunderstore.io/c/lethal-company/p/steven4547466/YoutubeBoombox/",
    "https://thunderstore.io/c/lethal-company/p/AllToasters/QuickRestart/",
    "https://thunderstore.io/c/lethal-company/p/quackandcheese/MirrorDecor/",
    "https://thunderstore.io/c/lethal-company/p/EliteMasterEric/WackyCosmetics/",
    "https://thunderstore.io/c/lethal-company/p/happyfrosty/FrostySuits/",
    "https://thunderstore.io/c/lethal-company/p/NiaNation/AbsasCosmetics/",
    "https://thunderstore.io/c/lethal-company/p/sfDesat/Aquatis/",
    "https://thunderstore.io/c/lethal-company/p/Isbjorn52/MetalPipe/",
    "https://thunderstore.io/c/lethal-company/p/bandaidroo/BandaidsMegaCosmetics/",
    "https://thunderstore.io/c/lethal-company/p/FlipMods/FasterItemDropship/",
    "https://thunderstore.io/c/lethal-company/p/sfDesat/Orion/",
    "https://thunderstore.io/c/lethal-company/p/2018/LC_API/",
    "https://thunderstore.io/c/lethal-company/p/HolographicWings/LethalExpansion/",
    "https://thunderstore.io/c/lethal-company/p/Gemumoddo/LethalEmotesAPI/",
    "https://thunderstore.io/c/lethal-company/p/Rune580/LethalCompany_InputUtils/",
    "https://thunderstore.io/c/lethal-company/p/Gemumoddo/BadAssCompany/",
    "https://thunderstore.io/c/lethal-company/p/AinaVT/LethalConfig/"
)

$savedModsFileName = "saved_mods.txt"
# $directoryPaths = @("./BepInEx/plugins/Modules", "./BepInEx/config")
# # Create the directory if it doesn't exist
# foreach ($directoryPath in $directoryPaths) {
#     if (-not (Test-Path -Path $directoryPath)) {
#         New-Item -Path $directoryPath -ItemType Directory -Force
#     }
# }


# # Create the directory if it doesn't exist
# if (-not (Test-Path -Path $directoryPath)) {
#     New-Item -Path $directoryPath -ItemType Directory
# }

# Define the savedMods
try {
    $savedMods = Get-Content -Path $savedModsFileName -ErrorAction Stop
    # Process $content here
}
catch {
    $savedMods = ""
}
$result = [hashtable]::Synchronized(@{ 
    Value = ""
})
$savedModsAsArray = $savedMods -split "---"
$jobs = @()
# Initialize the hashtable
$extractedPackages = [hashtable]::Synchronized(@{ 
    Value = @()
})
foreach ($url in $urls) {
    $jobs += Start-ThreadJob -Name $url -ScriptBlock {
        $url = $using:url
        $result = $using:result
        $extractedPackages = $using:extractedPackages
        $savedModsAsArray = $using:savedModsAsArray
        $savedMods = $using:savedMods
        $htmlString = Invoke-RestMethod -Uri $url
        $downloadLink = [regex]::Match($htmlString, 'https://thunderstore\.io/package/download/[^\""]+').Value
        $tempUrlWithoutVersion = $downloadLink -replace "/(\d|\.)+/", ""
        $needNewVersionDownload = $true
        if ($savedModsAsArray.Length -eq 0) {
            $result.Value += $downloadLink
            $result.Value += "---"
        } else {
            for ($i=0; $i -lt $savedModsAsArray.Length; $i++){
                $savedMod = $savedModsAsArray[$i]
                if ($savedMod -eq $downloadLink) {
                    $result.Value += $savedMod
                    $result.Value += "---"
                    $needNewVersionDownload = $false
                    break
                }
                $tempSavedModWithoutVersion = $savedMod -replace "/(\d|\.)+/", ""
                if ($tempUrlWithoutVersion -eq $tempSavedModWithoutVersion -or ($tempUrlWithoutVersion -ne $tempSavedModWithoutVersion -and $i -eq ($savedModsAsArray.Length - 1))) {
                    # update package by downloading
                    $result.Value += $downloadLink
                    $result.Value += "---"
                    break
                }
            }
        }
        if ($needNewVersionDownload -eq $true) {
            $randomNumber = Get-Random -Minimum 0 -Maximum 10000
            $randomNumber = [math]::Round($randomNumber)
            $packageName = "package" + $randomNumber
            $packageZipName = $packageName + ".zip"
            Invoke-WebRequest $downloadLink -OutFile $packageZipName
            Expand-Archive $packageZipName -DestinationPath $packageName -Force
            $extractedPackages.Value += $packageName
            Remove-Item -Path $packageZipName -Recurse -Force
        }
    }
}

Write-Host "Downloads started..."
Wait-Job -Job $jobs

foreach ($job in $jobs) {
    Receive-Job -Job $job
}

# Define the path to the parent folder
$parentFolderPath = "."

# Iterate through each folder in the $extractedPackages list
$knownFolderPaths = @('BepInEx\config', 'BepInEx\plugins\Modules', 'BepInEx\plugins')
foreach ($folderNameBase in $extractedPackages.Value) {
    # Check if "BepInExPack" folder exists
    $folderPath = "$parentFolderPath\$folderNameBase"

    # First loop to check if any of the folders exist and set a value indicating their existence

    $allFolders = Get-ChildItem -Path $folderPath -Directory
    $folderExistence = @{}
    foreach ($folder in $allFolders) {
        $folderExistence[$folder.Name] = $true
    }
        
    if (-not $folderExistence.BepInEx) {
        New-Item -Path "$folderPath\BepInEx" -ItemType Directory -Force
    }
    $folderExistence.Remove("BepInEx")


    if (-not $folderExistence.plugins) {
        New-Item -Path "$folderPath\BepInEx\plugins" -ItemType Directory -Force
        New-Item -Path "$folderPath\BepInEx\plugins\Modules" -ItemType Directory -Force
    } else {
        Move-Item -Path "$folderPath\plugins" -Destination "$folderPath\BepInEx\plugins"
        if (Test-Path -Path "$folderPath\BepInEx\plugins\Modules") {
        } else {
            New-Item -Path "$folderPath\BepInEx\plugins\Modules" -ItemType Directory -Force
        }
    }
    $folderExistence.Remove("plugins")

    if (-not $folderExistence.patchers) {
        New-Item -Path "$folderPath\BepInEx\patchers" -ItemType Directory -Force
    } else {
        Move-Item -Path "$folderPath\patchers" -Destination "$folderPath\BepInEx\patchers"
    }

    if (-not $folderExistence.config) {
        New-Item -Path "$folderPath\BepInEx\config" -ItemType Directory -Force
    } else {
        Move-Item -Path "$folderPath\config" -Destination "$folderPath\BepInEx\config"
    }
    $folderExistence.Remove("config")

    try {
        Remove-Item "$folderPath\*" -Include icon.png, manifest.json, README.md, CHANGELOG.MD
    } catch {

    }
    $filesToMove = Get-ChildItem -Path $folderPath -File
    foreach ($fileToMove in $filesToMove) {
        if ($fileToMove.Extension -eq ".lem" -and $fileToMove.Name.ToLower() -ne "lethalexpansion.lem") {
            Move-Item -Path $fileToMove.FullName -Destination "$folderPath\BepInEx\plugins\Modules" 
        } else {
            Move-Item -Path $fileToMove.FullName -Destination "$folderPath\BepInEx\plugins" 
        }
    }
        
    $allFolders = Get-ChildItem -Path $folderPath -Directory

    if ($folderExistence.Modules -eq $true) {
        Move-Item -Path "$folderPath\Modules\*" -Destination "$folderPath\BepInEx\plugins\Modules"
    }
    $folderExistence.Remove("Modules")
    
    if ($folderExistence.BepInExPack -eq $true) {
        $foldersOfBepInExPack = Get-ChildItem -Path "$folderPath\BepInExPack\BepInEx" -Directory
        foreach ($folder in $foldersOfBepInExPack) {
            if (Test-Path -Path "$folderPath\BepInEx\$($folder.Name)") {
            } else {
                New-Item -Path "$folderPath\BepInEx\$($folder.Name)" -ItemType Directory -Force
            }
            Move-Item -Path "$($folder.FullName)\*" -Destination "$folderPath\BepInEx\$($folder.Name)" -Force
        }
        # Move-Item -Path "$folderPath\BepInExPack\BepInEx\*" -Destination "$folderPath\BepInEx"
        $filesToMove = Get-ChildItem -Path "$folderPath\BepInExPack" -File
        foreach ($file in $filesToMove) {
            Move-Item -Path $file.FullName -Destination $folderPath -Force
        }
        Remove-Item "$folderPath\BepInExPack" -Recurse -Force
    }
    $folderExistence.Remove("BepInExPack")
    
    foreach ($key in $folderExistence.Keys) {
        Write-Host $key
        Move-Item -Path "$folderPath\$key" -Destination "$folderPath\BepInEx\plugins"
    }
    Compress-Archive -Path "$folderPath\*" -DestinationPath "$folderPath\temp.zip"
    Expand-Archive -Path "$folderPath\temp.zip" -DestinationPath $parentFolderPath -Force
    Remove-Item -Path $folderPath -Recurse -Force
}
Set-Content -Path $savedModsFileName -Value $result.Value