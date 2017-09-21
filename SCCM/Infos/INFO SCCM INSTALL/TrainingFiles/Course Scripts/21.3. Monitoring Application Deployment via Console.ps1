$AppName = "Google Chrome"
$ColName = "All Systems"

Get-CMDeployment -CollectionName "$ColName" -SoftwareName "$AppName" | Invoke-CMDeploymentSummarization
Start-Sleep 10
Get-CMDeployment -CollectionName "$ColName" -SoftwareName "$AppName" | select ApplicationName, CollectionName, NumberErrors, NumberInProgress, NumberOther, NumberSuccess, NumberTargeted, NumberUnknown
