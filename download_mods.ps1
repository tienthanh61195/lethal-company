# Define the URLs
$ProgressPreference = 'SilentlyContinue'
if (-not (Get-Command -ErrorAction Ignore -Type Cmdlet Start-ThreadJob)) {
    Write-Verbose "Installing module 'ThreadJob' on demand..."
    Install-Module -Name ThreadJob -ErrorAction Stop -Scope CurrentUser -Force
}


$urls = @(
    "https://thunderstore.io/c/lethal-company/p/BepInEx/BepInExPack/",
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
    "https://thunderstore.io/c/lethal-company/p/Gemumoddo/BadAssCompany/"
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
           

            
            # # Check if the 'package' folder exists
            # $packageFolderPath = Join-Path -Path $parentFolderPath -ChildPath $packageName
            # if (Test-Path $packageFolderPath -PathType Container) {
            #     # Check if 'BepInExPack' folder exists
            #     $bepInExPackFolderPath = Join-Path -Path $packageFolderPath -ChildPath "BepInExPack"
            #     if (Test-Path $bepInExPackFolderPath -PathType Container) {
            #         # Check if 'BepInEx' folder exists inside 'BepInExPack'
            #         $bepInExInsidePackFolderPath = Join-Path -Path $bepInExPackFolderPath -ChildPath "BepInEx"
            #         if (Test-Path $bepInExInsidePackFolderPath -PathType Container) {
            #             # Move 'BepInEx' folder from 'BepInExPack' to 'package'
            #             Move-Item -Path $bepInExInsidePackFolderPath -Destination $packageFolderPath
            #         }
            #     }
            #     $bepInExFolderPath = Join-Path -Path $packageFolderPath -ChildPath "BepInEx"
            #     if (Test-Path $bepInExFolderPath -PathType Container) {
            #         Write-Host "'BepInEx' folder already exists. Skipping further checks."
            #     }
            #     else {
            #         Write-Host $bepInExFolderPath
            #         # Move any folders in 'package' (excluding 'BepInEx') into 'BepInEx'
            #         New-Item $bepInExFolderPath -Type Directory
            #         $pluginFolderPath = Join-Path -Path $packageFolderPath -ChildPath "BepInEx\plugins"
            #         New-Item -Path $pluginFolderPath -Type Directory
            #         $allFolders = Get-ChildItem -Path $packageFolderPath -Directory
            #         if ($allFolders.Count -gt 0) {
            #         # Create the 'BepInEx' folder inside 'package'

            #         # Move folders into 'BepInEx'
            #             foreach ($folder in $allFolders) {
            #                 if ($folder.FullName -eq "Modules") {
            #                     Move-Item -Path $folder.FullName -Destination "$bepInExFolderPath\plugins"
            #                 }
            #                 else {
            #                     Move-Item -Path $folder.FullName -Destination $bepInExFolderPath
            #                 }
            #             }
            #         }
            #         # Check for specific files
            #         $filesToExclude = @("icon.png", "manifest.json", "README.md")
            #         $filesToInclude = Get-ChildItem -Path $packageFolderPath -Exclude $filesToExclude

            #         if ($filesToInclude.Count -gt 0) {
            #             # Create the 'BepInEx/plugin' folder inside 'package'

            #             Write-Host $filesToExclude.FullName
            #             # Move files into 'BepInEx/plugin'
            #             Move-Item -Path $filesToInclude.FullName -Destination $pluginFolderPath -Force
            #         }
            #     }
            # }
            # else {
            #     Write-Host "'package' folder does not exist. No action taken."
            # }
            # $folderPath = ".\" + $packageName + "\BepInEx"
            # $items = Get-ChildItem -Path $folderPath
            # $destinationFolder = ".\BepInEx"
            # foreach ($item in $items) {
            #     # Construct the destination path
            #     $destinationPath = Join-Path -Path $destinationFolder -ChildPath $item.Name

            #     # Move the item
            #     Move-Item -Path $item.FullName -Destination $destinationPath -Force

            #     Write-Output "Moved $($item.Name) to $destinationFolder"
            # }
            # Remove-Item -Path $packageZipName -Recurse -Force
            # Remove-Item -Path $packageName -Recurse -Force
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
# New-Item -Path "$parentFolderPath\BepInEx" -ItemType Directory -Force
# New-Item -Path "$parentFolderPath\BepInEx\plugins" -ItemType Directory -Force
# New-Item -Path "$parentFolderPath\BepInEx\plugins\Modules" -ItemType Directory -Force
# New-Item -Path "$parentFolderPath\BepInEx\config" -ItemType Directory -Force
# $bepInExRootFolderPath = "$parentFolderPath\BepInEx"

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


    if ($folderExistence.BepInExPack -eq $true) {
        Move-Item -Path "$folderPath\BepInExPack\BepInEx\*" -Destination "$folderPath\BepInEx"
        $filesToMove = Get-ChildItem -Path "$folderPath\BepInExPack" -File
        foreach ($file in $filesToMove) {
            Move-Item -Path $file.FullName -Destination $folderPath -Force
        }
        Remove-Item "$folderPath\BepInExPack" -Recurse -Force
    }
    $folderExistence.Remove("BepInExPack")

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
    foreach ($key in $folderExistence.Keys) {
        Write-Host $key
        Move-Item -Path "$folderPath\$key" -Destination "$folderPath\BepInEx\plugins"
    }
    Compress-Archive -Path "$folderPath\*" -DestinationPath "$folderPath\temp.zip"
    Expand-Archive -Path "$folderPath\temp.zip" -DestinationPath $parentFolderPath -Force
    Remove-Item -Path $folderPath -Recurse -Force
}
Set-Content -Path $savedModsFileName -Value $result.Value