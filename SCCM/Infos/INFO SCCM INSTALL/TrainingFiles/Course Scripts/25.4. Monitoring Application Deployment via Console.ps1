$DeploymentName = "Chrome for Linux (Install Chrome for Linux)"
Get-CMDeployment -SoftwareName "$DeploymentName" | Invoke-CMDeploymentSummarization
Start-Sleep 10
Get-CMPackageDeploymentStatus -Name "Chrome for Linux" | Get-CMDeploymentStatusDetails | select DeviceName, StatusDescription, StatusType
#for single summary, use:
#Get-CMDeployment -SoftwareName "$DeploymentName" | select ApplicationName, CollectionName, NumberErrors, NumberInProgress, NumberOther, NumberSuccess, NumberTargeted, NumberUnknown
