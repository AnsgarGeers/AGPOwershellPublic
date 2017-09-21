$AppName = "Google Chrome"
$ColName = "All Systems"
Start-CMApplicationDeployment -CollectionName "$ColName" -Name "$AppName" -DeployAction Install -DeployPurpose Available