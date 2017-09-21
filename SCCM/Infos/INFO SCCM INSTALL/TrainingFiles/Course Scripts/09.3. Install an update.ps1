$SiteCode = "001"
$servername = "SRV0002.classroom.intranet"

while ($true)
{
	$SiteUpdate = gwmi -Namespace "root\SMS\site_$($SiteCode)" -query "select * from SMS_CM_UpdatePackages where Name like 'Configuration Manager 1610%' AND UpdateType = 0"
	if ($SiteUpdate -ne $null) {
		if ($SiteUpdate.State -ne 131074) {
			Write-Host "Pre-Check is still happening..."
			Start-Sleep 30
		} else {
			Write-Host "Pre-Req done, starting update"
			#https://msdn.microsoft.com/en-us/library/mt762101(v=cmsdk.16).aspx
			$SiteUpdate.UpdatePrereqAndStateFlags(2,2)
			Get-Process -Name Microsoft.ConfigurationManagement | Stop-Process
			break
		}
	} 
}

while ($true)
{
	$SiteUpdate = gwmi -Namespace "root\SMS\site_$($SiteCode)" -query "select * from SMS_CM_UpdatePackages where Name like 'Configuration Manager 1610%' AND UpdateType = 0" -ErrorAction SilentlyContinue
	if ($SiteUpdate -ne $null) {
		if ($SiteUpdate.State -ne 196612) {
			Write-Host "Installation is still happening..."
			Start-Sleep 30
		} else {
			Write-Host "Installation done"
			Start-Process -Filepath ("C:\ConfigMgr\AdminConsole\bin\Microsoft.ConfigurationManagement.exe")
			break
		}
	} else {
		Write-Host "Installation is still happening..."
		Start-Sleep 30
	}
}