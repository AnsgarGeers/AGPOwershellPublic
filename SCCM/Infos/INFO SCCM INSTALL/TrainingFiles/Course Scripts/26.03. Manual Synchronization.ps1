$SiteCode = "001"
Sync-CMSoftwareUpdate -FullSync $True
Start-Sleep 30
#6705 = In progress Database
#6704 = In progress (WSUS Server)
#6702 = Done
#6701 = Starting

while ($true)
{
	$return = gwmi -Class SMS_SupSyncStatus -Namespace "root\sms\site_$SiteCode" | select LastSyncErrorCode, LastSyncState
	Write-Output $return
	if ($return.LastSyncState -ne 6702) {start-sleep 10 } else { break }
}