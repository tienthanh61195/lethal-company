# Define the URLs
$ProgressPreference = 'SilentlyContinue'
if (-not (Get-Command -ErrorAction Ignore -Type Cmdlet Start-ThreadJob)) {
    Write-Verbose "Installing module 'ThreadJob' on demand..."
    Install-Module -Name ThreadJob -ErrorAction Stop -Scope CurrentUser -Force
}

function DeepCopy-Object {
    param (
        [Parameter(Mandatory=$true)]
        [object]$Object
    )

    # Convert the object to a JSON string
    $jsonString = $Object | ConvertTo-Json -Depth 10

    # Convert the JSON string back to a PowerShell object
    $deepCopyObject = $jsonString | ConvertFrom-Json

    return $deepCopyObject
}

$urls = @(
    "https://thunderstore.io/c/lethal-company/p/BepInEx/BepInExPack/",
    "https://thunderstore.io/c/lethal-company/p/notnotnotswipez/MoreCompany/",
    # "https://thunderstore.io/c/lethal-company/p/Sligili/More_Emotes/",
    "https://thunderstore.io/c/lethal-company/p/x753/More_Suits/",
    "https://thunderstore.io/c/lethal-company/p/Verity/TooManySuits/",
    "https://thunderstore.io/c/lethal-company/p/Dwarggo/Fashion_Company/",
    "https://thunderstore.io/c/lethal-company/p/TeamClark/SCP_Foundation_Suit/",
    # "https://thunderstore.io/c/lethal-company/p/akkowo/More_suit_colors_for_more_suits/",
    "https://thunderstore.io/c/lethal-company/p/Norman/GlowStickSuits/",
    "https://thunderstore.io/c/lethal-company/p/anormaltwig/LateCompany/",
    "https://thunderstore.io/c/lethal-company/p/RugbugRedfern/Skinwalkers/",
    "https://thunderstore.io/c/lethal-company/p/Sligili/HDLethalCompany/",
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
    "https://thunderstore.io/c/lethal-company/p/OrtonLongGaming/FreddyBracken/",
    "https://thunderstore.io/c/lethal-company/p/x753/Mimics/",
    # "https://thunderstore.io/c/lethal-company/p/steven4547466/YoutubeBoombox/",
    "https://thunderstore.io/c/lethal-company/p/AllToasters/QuickRestart/",
    "https://thunderstore.io/c/lethal-company/p/quackandcheese/MirrorDecor/",
    "https://thunderstore.io/c/lethal-company/p/EliteMasterEric/WackyCosmetics/",
    "https://thunderstore.io/c/lethal-company/p/happyfrosty/FrostySuits/",
    "https://thunderstore.io/c/lethal-company/p/NiaNation/AbsasCosmetics/",
    "https://thunderstore.io/c/lethal-company/p/sfDesat/Aquatis/",
    "https://thunderstore.io/c/lethal-company/p/bandaidroo/BandaidsMegaCosmetics/",
    "https://thunderstore.io/c/lethal-company/p/FlipMods/FasterItemDropship/",
    "https://thunderstore.io/c/lethal-company/p/sfDesat/Orion/",
    "https://thunderstore.io/c/lethal-company/p/2018/LC_API/",
    "https://thunderstore.io/c/lethal-company/p/HolographicWings/LethalExpansion/",
    "https://thunderstore.io/c/lethal-company/p/Gemumoddo/LethalEmotesAPI/",
    "https://thunderstore.io/c/lethal-company/p/Rune580/LethalCompany_InputUtils/",
    "https://thunderstore.io/c/lethal-company/p/Gemumoddo/BadAssCompany/",
    "https://thunderstore.io/c/lethal-company/p/AinaVT/LethalConfig/",
    # "https://thunderstore.io/c/lethal-company/p/PotatoePet/AdvancedCompany/",
    "https://thunderstore.io/c/lethal-company/p/Jordo/NeedyCats/",
    "https://thunderstore.io/c/lethal-company/p/malco/Lategame_Upgrades/",
    "https://thunderstore.io/c/lethal-company/p/kRYstall9/FastSwitchPlayerViewInRadar/",
    "https://thunderstore.io/c/lethal-company/p/sunnobunno/YippeeMod/",
    "https://thunderstore.io/c/lethal-company/p/Chrispacito/Longnose_Anime_Suits/",
    "https://thunderstore.io/c/lethal-company/p/scoopy/Scoopys_Variety_Mod/",
    "https://thunderstore.io/c/lethal-company/p/Mhz/MoreHead/",
    "https://thunderstore.io/c/lethal-company/p/NomnomAB/RollingGiant/",
    "https://thunderstore.io/c/lethal-company/p/FlipMods/SkipToMultiplayerMenu/",
    "https://thunderstore.io/c/lethal-company/p/rafl/BonkHitSfxFixed/",
    "https://thunderstore.io/c/lethal-company/p/FlipMods/TooManyEmotes/"
    "https://thunderstore.io/c/lethal-company/p/IntegrityChaos/Diversity/",
    # "https://thunderstore.io/c/lethal-company/p/ViViKo/ViViKoCosmetics/",
    # "https://thunderstore.io/c/lethal-company/p/ViViKo/MoreMaterials/",
    # "https://thunderstore.io/c/lethal-company/p/Diversion/MaidOutfitFix/",
    "https://thunderstore.io/c/lethal-company/p/Frack9/DarkMist/",
    "https://thunderstore.io/c/lethal-company/p/Suskitech/AlwaysHearActiveWalkies/",
    "https://thunderstore.io/c/lethal-company/p/AllToasters/SpectateEnemies/",
    "https://thunderstore.io/c/lethal-company/p/IAmBatby/LethalLevelLoader/"
    # "https://thunderstore.io/c/lethal-company/p/Renegades/FlashlightToggle/",
    # "https://thunderstore.io/c/lethal-company/p/Renegades/WalkieUse/"

)


$savedModsFileName = "saved_mods.json"
$savedModsObject = @{}
# Read the JSON content from the file
$jsonContent = Get-Content -Path $savedModsFileName -Raw

# Convert the JSON content to a PowerShell object
if ($jsonContent) {
    $savedModsObject = $jsonContent | ConvertFrom-Json
}
# Define the savedMods

$jobs = @()
# Initialize the hashtable
$newSavedModsObject = [hashtable]::Synchronized(@{ 
    Value = @{}
})


foreach ($url in $urls) {
    $jobs += Start-ThreadJob -Name $url -ScriptBlock {
        $url = $using:url
        $result = $using:result
        $newSavedModsObject = $using:newSavedModsObject
        $savedModsObject = $using:savedModsObject
        $htmlString = Invoke-RestMethod -Uri $url
        $downloadLink = [regex]::Match($htmlString, 'https://thunderstore\.io/package/download/[^\""]+').Value
        $tempUrlWithoutVersion = $downloadLink -replace "/(\d|\.)+/", ""
        $needNewVersionDownload = $true
        if ($savedModsObject.Count -ne 0 -and $savedModsObject.$url.DownloadLink -eq $downloadLink) {
            $needNewVersionDownload = $false
            $newSavedModsObject.Value[$url] = $savedModsObject.$url
        }  else {
            $newSavedModsObject.Value[$url] = @{
                DownloadLink = $downloadLink        
                Path = @()
            }
        }
        # else {
        #     for ($i=0; $i -lt $savedModsAsArray.Length; $i++){
        #         $savedMod = $savedModsAsArray[$i]
        #         if ($savedMod -eq $downloadLink) {
        #             $result.Value += $savedMod
        #             $result.Value += "---"
        #             $needNewVersionDownload = $false
        #             break
        #         }
        #         $tempSavedModWithoutVersion = $savedMod -replace "/(\d|\.)+/", ""
        #         if ($tempUrlWithoutVersion -eq $tempSavedModWithoutVersion -or ($tempUrlWithoutVersion -ne $tempSavedModWithoutVersion -and $i -eq ($savedModsAsArray.Length - 1))) {
        #             # update package by downloading
        #             $result.Value += $downloadLink
        #             $result.Value += "---"
        #             break
        #         }
        #     }
        # }
        if ($needNewVersionDownload -eq $true) {
            $randomNumber = Get-Random -Minimum 0 -Maximum 10000
            $randomNumber = [math]::Round($randomNumber)
            $packageName = "package" + $randomNumber
            $packageZipName = $packageName + ".zip"
            Invoke-WebRequest $downloadLink -OutFile $packageZipName
            Expand-Archive $packageZipName -DestinationPath $packageName -Force
            Remove-Item -Path $packageZipName -Recurse -Force
            $newSavedModsObject.Value[$url].Package = $packageName
        }
    }
}

if ($jobs.Length) {
    Write-Host "Downloads started..."
    Wait-Job -Job $jobs
}

foreach ($job in $jobs) {
    Receive-Job -Job $job
}


if ($url.Length) {
    foreach ($property in $savedModsObject.PSObject.Properties) {
        $url = $property.Name
        if (-not $newSavedModsObject.Value.$url) {
            foreach ($path in $property.Value.Path) {
                if (-not ($varA -like "*config*")) {
                    try {
                        Remove-Item ".\$path" -Force
                    } catch{}
                }
        }
          
        }
    }
} else {
    foreach ($property in $savedModsObject.PSObject.Properties) {
        $url = $property.Name
        foreach ($path in $property.Value.Path) {
            Remove-Item ".\$path" -Force -Recurse
        }
    }
    Remove-Item ".\BepInEx" -Force -Recurse
}

# Define the path to the parent folder
$parentFolderPath = "."

# Iterate through each folder in the $newSavedModsObject list
# $psObject | Get-Member -MemberType Properties
$knownFolderPaths = @('BepInEx\config', 'BepInEx\plugins\Modules', 'BepInEx\plugins')
foreach ($url in $newSavedModsObject.Value.Keys) {
    if (-not $newSavedModsObject.Value[$url].Package) {continue}
    # Check if "BepInExPack" folder exists
    $folderNameBase = $newSavedModsObject.Value[$url].Package
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
        Move-Item -Path "$folderPath\$key" -Destination "$folderPath\BepInEx\plugins"
    }
    $absoluteFolderPath = Convert-Path $folderPath
    # Get all files recursively from the specified folder
    $files = Get-ChildItem -Path $absoluteFolderPath -File -Recurse
    # Output the relative paths of all files
    foreach ($file in $files) {
        # Calculate the relative path
        $relativePath = $file.FullName.Replace($absoluteFolderPath, "").TrimStart('\')
        $newSavedModsObject.Value[$url].Path += $relativePath
        $newSavedModsObject.Value[$url].Remove("Package")
    }
    Compress-Archive -Path "$folderPath\*" -DestinationPath "$folderPath\temp.zip"
    Expand-Archive -Path "$folderPath\temp.zip" -DestinationPath $parentFolderPath -Force
    Remove-Item -Path $folderPath -Recurse -Force
}
$jsonContent = $newSavedModsObject.Value | ConvertTo-Json

# Save the JSON content to a file
Set-Content -Path $savedModsFileName -Value $jsonContent