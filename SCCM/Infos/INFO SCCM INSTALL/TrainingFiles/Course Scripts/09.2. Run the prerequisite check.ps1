$SiteCode = "001"
$servername = "SRV0002.classroom.intranet"

while ($true)
{
	$SiteUpdate = gwmi -Namespace "root\SMS\site_$($SiteCode)" -query "select * from SMS_CM_UpdatePackages where Name like 'Configuration Manager 1610%' AND UpdateType = 0"
	if ($SiteUpdate -ne $null) {
		if ($SiteUpdate.State -ne 262146) {
			Write-Host "Update is in Downloading state..."
			Start-Sleep 30
		} else {
			#Reset value to default
			Set-ItemProperty -Path Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\SMS\COMPONENTS\SMS_DMP_DOWNLOADER -Name EasySetupDownloadInterval -Value 1440 -Force

			Write-Host "Update is ready, executing pre-req"
			#https://msdn.microsoft.com/en-us/library/mt762101(v=cmsdk.16).aspx
			$SiteUpdate.UpdatePrereqAndStateFlags(1,2)
			break
		}
	} 
}