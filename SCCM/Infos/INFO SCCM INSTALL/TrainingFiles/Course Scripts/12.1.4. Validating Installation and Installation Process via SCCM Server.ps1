#note: you may need to force a update of the All System collection if there is no WKS0001 device
#Invoke-CMDeviceCollectionUpdate -Name "All Systems"
#start-sleep 60
Get-CMDevice -Name "WKS000?" | select Name, IsClient, SiteCode, ClientActiveStatus
