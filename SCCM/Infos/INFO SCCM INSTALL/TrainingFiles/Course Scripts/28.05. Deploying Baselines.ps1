$Name = "Workstation Baseline" 
$schedule = New-CMSchedule -RecurCount 1 -RecurInterval Days
Start-CMBaselineDeployment -CollectionName "Windows 10 Workstations" -Name "$Name" -EnableEnforcement $true -Schedule $schedule
