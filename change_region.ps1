# Get current user
$user = $env:USERNAME

# Path to Rainbow Six - Siege folder
$folderPath = "C:\Users\$user\OneDrive\Documents\My Games\Rainbow Six - Siege"

# Get all subdirectories (player profiles) in the folder
$profiles = Get-ChildItem -Path $folderPath -Directory

# Extract DataCenterHint options from the ini file
$exampleIniFile = "$folderPath\$(($profiles | Select-Object -First 1).Name)\GameSettings.ini"
$dataCenterHints = Select-String -Path $exampleIniFile -Pattern "^; +playfab/[^$]+" -AllMatches | % { $_.Matches.Value.TrimStart("; ") }

# Prompt user with available options
Write-Host "Available DataCenterHint options are:" -ForegroundColor Green
$dataCenterHints | ForEach-Object { Write-Host $_ }

# Get user input
$newDataCenterHint = Read-Host -Prompt "Enter the desired DataCenterHint from the above options"

# Iterate over each player profile and update DataCenterHint in GameSettings.ini file
foreach ($profile in $profiles) {
    $iniFilePath = "$folderPath\$($profile.Name)\GameSettings.ini"
    
    # Check if the file exists
    if (Test-Path $iniFilePath) {
        # Get the content of the ini file
        $content = Get-Content $iniFilePath -Raw
        
        # Replace the DataCenterHint value
        $updatedContent = $content -replace "(?m)(^DataCenterHint=).*", "`${1}$newDataCenterHint"
        
        # Write the updated content back to the file
        Set-Content -Path $iniFilePath -Value $updatedContent
        Write-Host "Updated $iniFilePath with DataCenterHint=$newDataCenterHint" -ForegroundColor Yellow
    } else {
        Write-Host "$iniFilePath does not exist!" -ForegroundColor Red
    }
}


