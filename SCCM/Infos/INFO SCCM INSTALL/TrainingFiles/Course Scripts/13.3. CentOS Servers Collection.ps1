$CollUpdate = New-CMSchedule -Start "01/01/2015 9:00 PM" -DayOfWeek Saturday -RecurCount 1
$Collection = New-CMDeviceCollection -Name "CentOS Servers" -LimitingCollectionName "All Systems" -RefreshSchedule $CollUpdate -RefreshType Both
Add-CMDeviceCollectionQueryMembershipRule -CollectionId $Collection.CollectionID -RuleName "CentOS Servers"  -QueryExpression "select * from SMS_R_System where OperatingSystemNameandVersion like 'CentOS Linux%'"
