$lastUpdate = Get-Date -Date "2000-01-01 00:00:00"
$profileUrl = "https://raw.githubusercontent.com/abhayjatindoshi/pwsh-profile/refs/heads/main/my-profile.ps1"

$customProfileName = "my-profile.ps1"
$customProfilePath = "$(Split-Path -parent $profile)\$customProfileName"

if (-not (Test-Path -Path $profile)) {
    Write-Host -ForegroundColor Gray "Didn't find default profile file, creating one..."
    New-Item -Path $profile -ItemType File -Force | Out-Null
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
    Write-Host -ForegroundColor Gray "Setting up custom profile initialization..."
    Add-Content -Path $profile -Value ". $customProfilePath"
}
    
Write-Host -ForegroundColor Blue "Custom profile updated on: $lastUpdate"

$today = Get-Date
if ($lastUpdate.AddDays(2) -lt $today) {
    Write-Host -ForegroundColor Gray "Updating custom profile..."

    if (Test-Path -Path $customProfilePath) {
        Remove-Item -Path $customProfilePath -Force
    }

    Invoke-WebRequest $profileUrl -OutFile $customProfilePath
    $customProfileScript = Get-Content $customProfilePath
    $customProfileScript[0] = "`$lastUpdate = Get-Date -Date `"$(Get-Date -Format "yyyy-MM-dd HH:mm:ss")`""
    $customProfileScript | Set-Content $customProfilePath
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
