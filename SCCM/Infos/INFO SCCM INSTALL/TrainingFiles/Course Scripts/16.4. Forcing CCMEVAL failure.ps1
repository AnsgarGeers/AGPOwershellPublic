#On SRV0001
Get-ADComputer WKS0002 | Move-ADObject -TargetPath 'OU=Disabled,OU=Workstations,OU=Classroom,DC=classroom,DC=intranet'

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
