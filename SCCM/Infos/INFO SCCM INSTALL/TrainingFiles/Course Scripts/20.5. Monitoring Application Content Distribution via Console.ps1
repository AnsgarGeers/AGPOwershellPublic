$SiteCode = "001"
$servername = "SRV0002.classroom.intranet"
$AppName = "Google Chrome"

gwmi -Namespace root\sms\site_$SiteCode -ComputerName $servername -Query "SELECT * FROM SMS_ObjectContentExtraInfo" | Where-Object {$_.SoftwareName -eq $AppName } |select Targeted, NumberErrors, NumberInProgress, NumberSuccess, NumberUnknown
