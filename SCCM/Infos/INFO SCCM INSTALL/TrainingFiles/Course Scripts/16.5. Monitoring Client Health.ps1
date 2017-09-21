#On SRV0002
$SiteCode = "001"
 
#you may need to go to the console and force a refresh client status
$Device = Get-CMDevice -Name "WKS0001"
gwmi -namespace "root\sms\site_$SiteCode" -query "select * from SMS_CH_EvalResult where ResourceID = $($Device.ResourceID)" | select HealthCheckDescription

$Device = Get-CMDevice -Name "WKS0002"
gwmi -namespace "root\sms\site_$SiteCode" -query "select * from SMS_CH_EvalResult where ResourceID = $($Device.ResourceID)" | select HealthCheckDescription

#On SRV0001
Get-ADComputer "WKS0002" | Move-ADObject -TargetPath 'OU=Enabled,OU=Workstations,OU=Classroom,DC=classroom,DC=intranet'

#On WKS0002
Start-Process -Filepath ("gpupdate") -ArgumentList ("/force") –wait
Start-sleep 10

Start-Process -Filepath ("gpupdate") -ArgumentList ("/force") –wait
Start-sleep 10

#get service information
Get-Service -Name BITS

#Option 1
Get-ScheduledTask -TaskName "Configuration Manager Health Evaluation" | Start-ScheduledTask

#Option 2
Start-Process -Filepath ("c:\windows\ccm\ccmeval.exe") -wait

#On SRV0002
$SiteCode = "001"
 
#you may need to go to the console and force a refresh client status
$Device = Get-CMDevice -Name "WKS0002"
gwmi -namespace "root\sms\site_$SiteCode" -query "select * from SMS_CH_EvalResult where ResourceID = $($Device.ResourceID)" | select HealthCheckDescription
