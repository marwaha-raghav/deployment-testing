# Get current user
$user = $env:USERNAME

# Path to Rainbow Six - Siege folder
$folderPath = "C:\Users\$user\Documents\My Games\Rainbow Six - Siege"

# Get all subdirectories (player profiles) in the folder
$profiles = Get-ChildItem -Path $folderPath -Directory

# Extract DataCenterHint options from an existing ini file
$exampleIniFile = "$folderPath\$(($profiles | Select-Object -First 1).Name)\GameSettings.ini"
$dataCenterHintsRaw = Select-String -Path $exampleIniFile -Pattern "^; +playfab/[^$]+" -AllMatches | % { $_.Matches.Value.TrimStart("; ") }

# Reorder: 1. westeurope, 2. eastus, 3. southeastasia
$priorityOrder = @("playfab/westeurope", "playfab/eastus", "playfab/southeastasia")
$dataCenterHints = @()
foreach ($hint in $priorityOrder) {
    if ($dataCenterHintsRaw -contains $hint) {
        $dataCenterHints += $hint
    }
}
$dataCenterHints += ($dataCenterHintsRaw | Where-Object { $priorityOrder -notcontains $_ })

# Display numbered menu
Write-Host "Available DataCenterHint options:" -ForegroundColor Green
Write-Host " 0. default" -ForegroundColor Cyan
for ($i = 0; $i -lt $dataCenterHints.Count; $i++) {
    Write-Host " $($i + 1). $($dataCenterHints[$i])"
}

# Get user selection
[int]$selection = Read-Host -Prompt "Enter the number of the desired DataCenterHint (0 - $($dataCenterHints.Count))"

# Validate input
if ($selection -lt 0 -or $selection -gt $dataCenterHints.Count) {
    Write-Host "Invalid selection. Please enter a number between 0 and $($dataCenterHints.Count)." -ForegroundColor Red
    exit
}

# Set the selected value
$newDataCenterHint = if ($selection -eq 0) { "default" } else { $dataCenterHints[$selection - 1] }

# Files to update
$targetFiles = @("GameSettings.ini", "GameSettings_TS.ini")

# Update each profile's GameSettings files
foreach ($profile in $profiles) {
    foreach ($fileName in $targetFiles) {
        $iniFilePath = "$folderPath\$($profile.Name)\$fileName"

        if (Test-Path $iniFilePath) {
            $content = Get-Content $iniFilePath -Raw

            # Replace or insert DataCenterHint
            if ($content -match "(?m)^DataCenterHint=") {
                $updatedContent = $content -replace "(?m)(^DataCenterHint=).*", "`${1}$newDataCenterHint"
            } else {
                $updatedContent = "$content`nDataCenterHint=$newDataCenterHint"
            }

            Set-Content -Path $iniFilePath -Value $updatedContent
            Write-Host "Updated $iniFilePath with DataCenterHint=$newDataCenterHint" -ForegroundColor Yellow
        } else {
            Write-Host "$iniFilePath does not exist!" -ForegroundColor Red
        }
    }
}
