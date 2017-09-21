#Extend Schema
Start-Process -Filepath ('C:\trainingfiles\Source\SCCMCB\Extract\SMSSETUP\BIN\X64\extadsch.exe') -wait 
Start-Sleep 30

#Confirm Schema Extension
$schema = [DirectoryServices.ActiveDirectory.ActiveDirectorySchema]::GetCurrentSchema()
start-sleep 5
$schema.RefreshSchema()
$schema.FindClass("mSSMSSite")