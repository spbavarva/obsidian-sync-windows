param(
    [Parameter(Mandatory=$true)]
    [string]$VaultPath,

    [string]$PrivateKeyPath = "$env:USERPROFILE\.ssh\id_ed25519"
)

# Create scripts folder if not present
$ScriptsPath = "$VaultPath\scripts"
if (-not (Test-Path $ScriptsPath)) {
    New-Item -ItemType Directory -Path $ScriptsPath | Out-Null
}

# --- Create sync_obsidian.ps1 (replaces .bat) ---
$SyncScriptPath = "$ScriptsPath\sync_obsidian.ps1"
@"
cd "$VaultPath"
git pull --rebase
git add .
git commit -m "Auto-sync: \$(Get-Date -Format 'dd-MM-yyyy HH:mm:ss')" | Out-Null
git branch --set-upstream-to=origin/main main 2>`$null
git push
"@ | Set-Content -Path $SyncScriptPath -Encoding UTF8

# --- Create load_ssh_key.ps1 ---
$LoadKeyScriptPath = "$ScriptsPath\load_ssh_key.ps1"
@"
Start-Sleep -Seconds 5
ssh-add "$PrivateKeyPath" | Out-Null
"@ | Set-Content -Path $LoadKeyScriptPath -Encoding UTF8

# --- Register SSH key loading task ---
$Action1 = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-ExecutionPolicy Bypass -File `"$LoadKeyScriptPath`""
$Trigger1 = New-ScheduledTaskTrigger -AtLogOn
Register-ScheduledTask -TaskName "Obsidian_Load_SSH_Key" -Action $Action1 -Trigger $Trigger1 -RunLevel Highest -User $env:USERNAME -Force

# --- Register silent sync task (no popup) ---
$Action2 = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-WindowStyle Hidden -ExecutionPolicy Bypass -File `"$SyncScriptPath`""
$Trigger2 = New-ScheduledTaskTrigger -Once -At (Get-Date).Date -RepetitionInterval (New-TimeSpan -Minutes 15) -RepetitionDuration (New-TimeSpan -Days 1)
Register-ScheduledTask -TaskName "Obsidian_Auto_Sync" -Action $Action2 -Trigger $Trigger2 -RunLevel Highest -User $env:USERNAME -Force

Write-Host ""
Write-Host "✅ Setup complete!"
Write-Host "SSH key used: $PrivateKeyPath"
Write-Host "Vault syncs silently every 15 minutes from: $VaultPath"
