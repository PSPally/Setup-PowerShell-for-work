# Needs to check that it is running elevated

# Install modules
if ((Get-Module Az) -eq $false)
{
    Install-Module Az -Force
}

# Until the AzureAD team makes the module compatible with PowerShell 7...
if ($PSVersionTable.PSVersion.Major -lt 6)
{
    Install-Module AzureAD -Force
}

# Install RSAT (all)
if ($PSVersionTable.OS -like "Microsoft Windows 10.*")
{
    Get-WindowsCapability -Name RSAT* -Online | Add-WindowsCapability -Online
}

# Update PowerShell help
Update-Help -Force

# Schedule PowerShell help to be updated automatically
$ActionParams = @{ 
    Execute  = 'PowerShell.exe' 
    Argument = '-NoProfile -ExecutionPolicy Bypass -Command Update-Help -Force' 
}
$Action      = New-ScheduledTaskAction @ActionParams
$Trigger     = New-ScheduledTaskTrigger -Weekly -DaysOfWeek Wednesday -At '9:02:00' -RandomDelay '0:03:00' 
$Principal   = New-ScheduledTaskPrincipal -GroupId 'BUILTIN\Administrators' -RunLevel Highest
$SettingsSet = New-ScheduledTaskSettingsSet -RunOnlyIfNetworkAvailable -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -StartWhenAvailable
Register-ScheduledTask -TaskName 'Update PowerShell Help' -Action $Action -Trigger $Trigger -Principal $Principal -Settings $SettingsSet

# Schedule PowerShell modules to be kept up to date
$ActionParams = @{ 
    Execute  = 'PowerShell.exe' 
    Argument = '-NoProfile -ExecutionPolicy Bypass -Command Update-Module -Force' 
}
$Action      = New-ScheduledTaskAction @ActionParams
$Trigger     = New-ScheduledTaskTrigger -Weekly -DaysOfWeek Wednesday -At '8:30:00' -RandomDelay '0:03:00' 
$Principal   = New-ScheduledTaskPrincipal -GroupId 'BUILTIN\Administrators' -RunLevel Highest
$SettingsSet = New-ScheduledTaskSettingsSet -RunOnlyIfNetworkAvailable -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -StartWhenAvailable
Register-ScheduledTask -TaskName 'Update PowerShell Modules' -Action $Action -Trigger $Trigger -Principal $Principal -Settings $SettingsSet


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
if ($ProfileContent -notcontains $TranscriptLine) 
{
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

# Add extensions to VS Code
code --install-extension eamodio.gitlens
code --install-extension hashicorp.terraform # Terraform, not PowerShell
code --install-extension hediet.vscode-drawio
code --install-extension ms-azure-devops.azure-pipelines
code --install-extension ms-azuretools.vscode-azureappservice
code --install-extension ms-azuretools.vscode-azurefunctions
code --install-extension ms-azuretools.vscode-azureresourcegroups
code --install-extension ms-azuretools.vscode-azurestorage
code --install-extension ms-azuretools.vscode-azurevirtualmachines
code --install-extension ms-azuretools.vscode-cosmosdb
code --install-extension ms-azuretools.vscode-docker
code --install-extension ms-dotnettools.vscode-dotnet-runtime
code --install-extension ms-vscode.azure-account
code --install-extension ms-vscode.azurecli
code --install-extension ms-vscode.powershell
code --install-extension ms-vscode.vscode-node-azure-pack
code --install-extension msazurermtools.azurerm-vscode-tools
