#tasks 1 to 10, follow the e-book

#sccm
#tasks 11 to 15
#update All System Client, so you can have the new client appearing
Invoke-CMDeviceCollectionUpdate -Name "All Systems"
start-sleep 60

Get-CMDevice -Name "srv0003.classroom.intranet" | Select Name, IsApproved, IsBlocked
Approve-CMDevice -DeviceName "srv0003.classroom.intranet"
Get-CMDevice -Name "srv0003.classroom.intranet" | Select Name, IsApproved, IsBlocked

#tasks 16 to 18, follow the e-book