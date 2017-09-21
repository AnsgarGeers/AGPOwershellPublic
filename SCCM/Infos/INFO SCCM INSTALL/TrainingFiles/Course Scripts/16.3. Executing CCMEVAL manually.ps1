#Option 1
Get-ScheduledTask -TaskName "Configuration Manager Health Evaluation" | Start-ScheduledTask

#Option 2
Start-Process -Filepath ("c:\windows\ccm\ccmeval.exe") -wait
