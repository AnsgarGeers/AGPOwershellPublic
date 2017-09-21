$ClientSettingsName = "Default Client Agent Settings"
Set-CMClientSetting -EndpointProtection -Name "$ClientSettingsName" -Enable $True -InstallEndpointProtectionClient $true -DisableFirstSignatureUpdate $False 
