Add-Type -AssemblyName System.Windows.Forms
$RULENAME = "Overwatch-BlockEastCoast"

$firewall_enabaled = ((Get-NetFirewallProfile | select name,enabled) | where { $_.Enabled -eq $True } | measure ).Count -eq 3
if (!($firewall_enabaled)) {
    $decision = $Host.UI.PromptForChoice('enable firewall', 'Windows firewall must be enabled. Would you like to turn it on?', @('&Yes'; '&No'), 1)
    if ($decision -eq 1) {
        exit
    }
    else {
        Set-NetFirewallProfile -Profile Domain,Public,Private -Enabled True
        [System.Windows.Forms.MessageBox]::Show("Windows Firewall enabled.")
    }
}

$rule_exists = Get-NetFirewallRule -DisplayName "$RULENAME" 2>$null
if (!($rule_exists)) {
    $FileBrowser = New-Object System.Windows.Forms.OpenFileDialog -Property @{
	    Filter = 'Overwatch Executable|Overwatch.exe' # Specified file types
    }
    [void]$FileBrowser.ShowDialog()
    $file = $FileBrowser.FileName;

    If($FileBrowser.FileNames -like "*\*") {
	    New-NetFirewallRule -DisplayName "$RULENAME" `
        -Program "$file" `
        -RemoteAddress "24.105.40.0-24.105.47.255" `
        -Action Block `
        -Description "Blocks all connections from Overwatch.exe to East Coast blizzard servers" `
        -Direction Outbound `
        -Enabled False

        [System.Windows.Forms.MessageBox]::Show("Firewall Rule <$RULENAME> Created")
    }
    else {
        exit
    }
}

Get-NetFirewallRule -DisplayName "$RULENAME"
Write-Host (Get-NetFirewallRule -DisplayName "$RULENAME").Enabled


$rule_enabled = (Get-NetFirewallRule -DisplayName "$RULENAME").Enabled

if ($rule_enabled -eq "True") {
    Set-NetFirewallRule -DisplayName "$RULENAME" -Enabled False
    [System.Windows.Forms.MessageBox]::Show("STOPPED Blocking east coast OW servers")
}
else {
    Set-NetFirewallRule -DisplayName "$RULENAME" -Enabled True
    [System.Windows.Forms.MessageBox]::Show("STARTED Blocking east coast OW servers")
}

