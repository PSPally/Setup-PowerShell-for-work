# Install modules
Install-Module Az
Install-Module AzureAD

# Install RSAT (all)
Get-WindowsCapability -Name RSAT* -Online | Add-WindowsCapability -Online

# Update help
Update-Help -Force

# Schedule help to be updated automatically
$ActionParams = @{ 
    Execute  = 'PowerShell.exe' 
    Argument = '-NoProfile -ExecutionPolicy Bypass -Command Update-Help -Force' 
}
$Action      = New-ScheduledTaskAction @ActionParams
$Trigger     = New-ScheduledTaskTrigger -Weekly -DaysOfWeek Wednesday -At '9:02:00' -RandomDelay '0:03:00' 
$Principal   = New-ScheduledTaskPrincipal -GroupId 'BUILTIN\Administrators' -RunLevel Highest
$SettingsSet = New-ScheduledTaskSettingsSet -RunOnlyIfNetworkAvailable -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -StartWhenAvailable
Register-ScheduledTask -TaskName 'Update PowerShell Help' -Action $Action -Trigger $Trigger -Principal $Principal -Settings $SettingsSet

# Create transcripts folder
$TranscriptsFolder = "$env:USERPROFILE\PowerShellTranscripts"
if (-not $(Test-Path -Path $TranscriptsFolder)) {
        New-Item -Path "~" -Name PowerShellTranscripts -ItemType Directory
}

# Setup transcripts for Windows PowerShell
$TranscriptLine = "Start-Transcript -Path $TranscriptsFolder\WindowsPowerShell.`$(Get-Date -Format yyyyMMdd).txt`r`n"
$ProfilePath = "$env:USERPROFILE\Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1"
try {$ProfileContent = Get-Content -Path $ProfilePath}
    catch {$ProfileContent = ''}
if ($ProfileContent -notcontains $TranscriptLine) {
    $ProfileContent += $TranscriptLine
    Out-File -InputObject $ProfileContent -FilePath $ProfilePath
}
# Setup transcripts for PowerShell (core)
$TranscriptLine = "Start-Transcript -Path $TranscriptsFolder\PowerShell.`$(Get-Date -Format yyyyMMdd).txt`r`n"
$ProfilePath = "$env:USERPROFILE\Documents\PowerShell\Microsoft.PowerShell_profile.ps1"
try {$ProfileContent = Get-Content -Path $ProfilePath}
    catch {$ProfileContent = ''}
if ($ProfileContent -notcontains $TranscriptLine) {
    $ProfileContent += $TranscriptLine
    Out-File -InputObject $ProfileContent -FilePath $ProfilePath
}
# Setup transcripts for VS Code
$TranscriptLine = "Start-Transcript -Path $TranscriptsFolder\VSCode.`$(Get-Date -Format yyyyMMdd).txt`r`n"
$ProfilePath = "$env:USERPROFILE\Documents\WindowsPowerShell\Microsoft.VSCode_profile.ps1"
try {$ProfileContent = Get-Content -Path $ProfilePath}
    catch {$ProfileContent = ''}
if ($ProfileContent -notcontains $TranscriptLine) {
    $ProfileContent += $TranscriptLine
    Out-File -InputObject $ProfileContent -FilePath $ProfilePath
}

# Add PowerShell extension to VS Code
code --install-extension ms-vscode.powershell
