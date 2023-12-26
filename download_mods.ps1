# Define the URLs
$urls = @(
  "https://thunderstore.io/c/lethal-company/p/BepInEx/BepInExPack/",
  "https://thunderstore.io/c/lethal-company/p/Sligili/More_Emotes/",
  "https://thunderstore.io/c/lethal-company/p/notnotnotswipez/MoreCompany/",
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
  "https://thunderstore.io/c/lethal-company/p/MassiveNewCoilers/FixCentipedeLag/"
)

$savedModsFileName = "saved_mods.txt"

# Define the savedMods
try {
    $savedMods = Get-Content -Path $savedModsFileName -ErrorAction Stop
    # Process $content here
}
catch {
    $savedMods = ""
}
try {
    $result = @()
    $savedModsAsArray = $savedMods -split "---"
    for ($u=0; $u -lt $urls.Length; $u++) {
        $url = $urls[$u]
        $htmlString = Invoke-RestMethod -Uri $url
        $downloadLink = [regex]::Match($htmlString, 'https://thunderstore\.io/package/download/[^\""]+').Value
        $tempUrlWithoutVersion = $downloadLink -replace "/(\d|\.)+/", ""
        $needNewVersionDownload = $true
        for ($i=0; $i -lt $savedModsAsArray.Length; $i++){
            $savedMod = $savedModsAsArray[$i]
            if ($savedMod -eq $downloadLink) {
                $result += $savedMod
                $needNewVersionDownload = $false
                break
            }
            $tempSavedModWithoutVersion = $savedMod -replace "/(\d|\.)+/", ""
            if ($tempUrlWithoutVersion -eq $tempSavedModWithoutVersion -or ($tempUrlWithoutVersion -ne $tempSavedModWithoutVersion -and $i -eq ($savedModsAsArray.Length - 1))) {
                # update package by downloading
                $result += $downloadLink
                break
            }
        }
        if ($needNewVersionDownload -eq $true) {
            Invoke-WebRequest $downloadLink -OutFile package.zip
            Expand-Archive package.zip -DestinationPath package -Force

            # Define the path to the parent folder
            $parentFolderPath = "."

            
            # Check if the 'package' folder exists
            $packageFolderPath = Join-Path -Path $parentFolderPath -ChildPath "package"
            if (Test-Path $packageFolderPath -PathType Container) {
                # Check if 'BepInExPack' folder exists
                $bepInExPackFolderPath = Join-Path -Path $packageFolderPath -ChildPath "BepInExPack"
                if (Test-Path $bepInExPackFolderPath -PathType Container) {
                    # Check if 'BepInEx' folder exists inside 'BepInExPack'
                    $bepInExInsidePackFolderPath = Join-Path -Path $bepInExPackFolderPath -ChildPath "BepInEx"
                    if (Test-Path $bepInExInsidePackFolderPath -PathType Container) {
                        # Move 'BepInEx' folder from 'BepInExPack' to 'package'
                        Move-Item -Path $bepInExInsidePackFolderPath -Destination $packageFolderPath
                    }
                }
                $bepInExFolderPath = Join-Path -Path $packageFolderPath -ChildPath "BepInEx"
                if (Test-Path $bepInExFolderPath -PathType Container) {
                    Write-Host "'BepInEx' folder already exists. Skipping further checks."
                }
                else {
                        # Move any folders in 'package' (excluding 'BepInEx') into 'BepInEx'
                    $allFolders = Get-ChildItem -Path $packageFolderPath -Directory | Where-Object { $_.Name -ne "BepInEx" }
                    if ($allFolders.Count -gt 0) {
                        # Create the 'BepInEx' folder inside 'package'
                        New-Item -Path $bepInExFolderPath -ItemType Directory -Force

                        # Move folders into 'BepInEx'
                        foreach ($folder in $allFolders) {
                            Move-Item -Path $folder.FullName -Destination $bepInExFolderPath
                        }
                    }
                    else {
                        Write-Host "No folder exists inside 'package'. Checking for individual files."

                        # Check for specific files
                        $filesToExclude = @("icon.png", "manifest.json", "README.md")
                        $filesToInclude = Get-ChildItem -Path $packageFolderPath -Exclude $filesToExclude

                        if ($filesToInclude.Count -gt 0) {
                            # Create the 'BepInEx/plugin' folder inside 'package'
                            $pluginFolderPath = Join-Path -Path $packageFolderPath -ChildPath "BepInEx\plugins"
                            New-Item -Path $pluginFolderPath -ItemType Directory -Force
                            # Move files into 'BepInEx/plugin'
                            Move-Item -Path $filesToInclude.FullName -Destination $pluginFolderPath -Force
                        }
                        else {
                            Write-Host "No eligible files found to create 'BepInEx/plugin'. No action taken."
                        }
                    }
                }
            }
            else {
                Write-Host "'package' folder does not exist. No action taken."
            }


            $folderPath = ".\package\BepInEx"
            $zipFilePath = "temp.zip"
            Compress-Archive -Path $folderPath -DestinationPath $zipFilePath
            Remove-Item -Path package.zip -Recurse -Force
            Remove-Item -Path package -Recurse -Force
            Expand-Archive -Path $zipFilePath -DestinationPath . -Force
            Remove-Item -Path temp.zip -Recurse -Force
        }
    }
    $result = $result -join "---"
    Set-Content -Path $savedModsFileName -Value $result
} catch {

}