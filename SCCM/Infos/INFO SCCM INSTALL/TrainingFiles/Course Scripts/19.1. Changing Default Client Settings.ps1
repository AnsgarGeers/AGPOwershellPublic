$SiteCode = "001"
$servername = "SRV0002.classroom.intranet"
 
$ClientSettingsName = "Default Client Agent Settings"
Set-CMClientSetting -ComputerAgentSettings -Name "$ClientSettingsName" -AddPortalToTrustedSiteList $True -AllowPortalToHaveElevatedTrust $True -PortalUrl "http://srv0002/CMApplicationCatalog"
Set-CMClientSetting -Name "$ClientSettingsName" -UserDeviceAffinitySettings -AllowUserAffinity $True -AutoApproveAffinity $True
