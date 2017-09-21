$SiteCode = "001"
$dkserver = "SRV0002.classroom.intranet"

Set-CMSoftwareUpdatePointComponent -SiteCode $SiteCode -ImmediatelyExpireSupersedence $True -AddUpdateClassification "Definition Updates"
Start-Sleep 5
Set-CMSoftwareUpdatePointComponent -SiteCode $SiteCode -AddProduct @('Forefront Endpoint Protection 2010', 'Windows Defender')
Start-Sleep 5
Sync-CMSoftwareUpdate -FullSync $True
Start-sleep 30

while ($true)
{
	$return = gwmi -Class SMS_SupSyncStatus -Namespace "root\sms\site_$SiteCode" | select LastSyncErrorCode, LastSyncState
	Write-Output $return
	if ($return.LastSyncState -ne 6702) {start-sleep 10 } else { break }
}
