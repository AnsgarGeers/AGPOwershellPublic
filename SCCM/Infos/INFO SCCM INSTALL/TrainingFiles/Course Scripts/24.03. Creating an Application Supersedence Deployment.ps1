$SiteCode = "001"
$AppName = "Firefox 49"
$CollName = "All Users"

Start-CMApplicationDeployment -CollectionName "$CollName" -Name "$AppName"
$Deployment = Get-WmiObject -Namespace "root\SMS\site_$($SiteCode)" -Class "SMS_ApplicationAssignment" | Where-Object { $_.ApplicationName -like "$AppName" -and $_.CollectionName -like "$CollName"}
$Deployment.UpdateSupersedence = "True"
$Deployment.Put()
