$SiteCode = "001"
$servername = "SRV0002.classroom.intranet"

gwmi -Namespace "root\SMS\site_$($SiteCode)" -query "select * from SMS_CM_UpdatePackages where Name like 'Configuration Manager 1610%' AND UpdateType = 0"

#Force Donwload to happen now
Set-ItemProperty -Path Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\SMS\COMPONENTS\SMS_DMP_DOWNLOADER -Name EasySetupDownloadInterval -Value 1 -Force
