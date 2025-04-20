$lastUpdate = Get-Date -Date "2000-01-01 00:00:00"
$profileUrl = "https://raw.githubusercontent.com/abhayjatindoshi/pwsh-profile/refs/heads/main/my-profile.ps1"

$customProfileName = "my-profile.ps1"
$customProfilePath = "$(Split-Path -parent $profile)\$customProfileName"

if (-not (Test-Path -Path $profile)) {
    New-Item -Path $profile -ItemType File -Force | Out-Null
    Write-Host "Profile file created $profile"
}

$profileData = Get-Content -Path $profile
$hasCustomProfileInit = $false
foreach ($line in $profileData) {
    if ($line -eq ". $customProfilePath") {
        $hasCustomProfileInit = $true
        break
    }
}

if (-not $hasCustomProfileInit) {
    Add-Content -Path $profile -Value ". $customProfilePath"
    Write-Host "The script has been added to your profile."
}
    
$today = Get-Date
if ($lastUpdate.AddDays(2) -gt $today) {
    Write-Host "Last update: $lastUpdate"
    Write-Host "Skipping update check..."
}
else {
    Write-Host "Last update: $lastUpdate"
    Write-Host "Checking for updates..."

    if (Test-Path -Path $customProfilePath) {
        Remove-Item -Path $customProfilePath -Force
        Write-Host "Removed old profile: $customProfilePath"
    }

    Invoke-WebRequest $profileUrl -OutFile $customProfilePath
    "$lastUpdate = Get-Date -Date `"$(Get-Date)`" `n" + (Get-Content $profile | Select-Object -Skip 1) | Set-Content $profile

}

$alias = @{
    "edit"   = "open $profile"
    "reload" = ". $profile"
    ".."     = "cd .."
    "..."    = "cd ..\.."
    "...."   = "cd ..\..\.."
    "gct"    = "git commit"
    "gph"    = "git push"
    "gpl"    = "git pull"
    "gch"    = "git checkout"
    "gb"     = "git branch"
    "gbr"    = "git branch -r"
    "gst"    = "git status"
    "open"   = "start"
};

function Invoke-MyAlias {
    $callingAlias = $MyInvocation.InvocationName
    if (!$alias.ContainsKey($callingAlias)) {
        Write-Error "Alias not found.";
        return;
    }

    $command = $alias[$callingAlias]
    Invoke-Expression "$command $args" 
}

foreach ($key in $alias.Keys) {
    Set-Alias -Name $key -Value Invoke-MyAlias
}
Write-Output "Personal profile loaded - Welcome $Env:UserName!"
