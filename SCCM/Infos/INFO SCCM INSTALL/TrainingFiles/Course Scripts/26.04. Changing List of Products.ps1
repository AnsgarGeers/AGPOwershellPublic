$SiteCode = "001"
$dkserver = "SRV0002.classroom.intranet"

Set-CMSoftwareUpdatePointComponent -SiteCode $SiteCode -AddProduct @('Windows 8.1', 'Windows 10')
Start-Sleep 5
Sync-CMSoftwareUpdate -FullSync $True
Start-Sleep 30
while ($true)
{
	$return = gwmi -Class SMS_SupSyncStatus -Namespace "root\sms\site_$SiteCode" | select LastSyncErrorCode, LastSyncState
	Write-Output $return
	if ($return.LastSyncState -ne 6702) {start-sleep 10 } else { break }
}
