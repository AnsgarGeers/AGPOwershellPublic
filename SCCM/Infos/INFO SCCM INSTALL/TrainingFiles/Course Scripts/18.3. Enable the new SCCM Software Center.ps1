$ClientSettingsName = "Default Client Agent Settings"
Set-CMClientSetting -Name "$ClientSettingsName" -ComputerAgent -UseNewSoftwareCenter $true
