$SiteCode = "001"
$servername = "SRV0002.classroom.intranet"

if ((Get-CMSiteSystemServer -SiteSystemServerName "$servername") -eq $null) { New-CMSiteSystemServer –SiteCode $SiteCode –UseSiteServerAccount –ServerName $servername }

Add-CMSoftwareUpdatePoint -SiteSystemServerName "$ServerName" -ClientConnectionType "Intranet" -SiteCode $SiteCode -WsusiisPort 8530 -WsusiissslPort 8531 -WsusSsl $false

start-sleep 90

while ($true)
{
    $component = gwmi -Namespace ("root\sms\site_$SiteCode") -query "select stmsgin.InsStrValue from SMS_StatMsg stmsg inner join SMS_StatMsgInsStrings stmsgin on stmsg.RecordID = stmsgin.RecordID where stmsg.Component = 'SMS_WSUS_CONTROL_MANAGER' and stmsg.MessageID = 1013 and stmsgin.InsStrIndex = 0 and stmsgin.SiteCode = '$SiteCode'"
    if ($component -ne $null)
    {
        Write-Host "Found SMS_WSUS_CONTROL_MANAGER 1013 id's"
        break
    } else { Start-Sleep 10 }
}

while ($true)
{
    $component = gwmi -Namespace ("root\sms\site_$SiteCode") -query "select stmsg.* from SMS_StatMsg stmsg where stmsg.Component = 'SMS_WSUS_CONTROL_MANAGER' and stmsg.MessageID = 1014 and stmsg.SiteCode = '$SiteCode'"
    if ($component -ne $null)
    {
        Write-Host "Found SMS_WSUS_CONTROL_MANAGER 1014 id's"
        break
    } else { Start-Sleep 10 }
}

while ($true)
{
    $component = gwmi -Namespace ("root\sms\site_$SiteCode") -query "select stmsg.* from SMS_StatMsg stmsg where stmsg.Component = 'SMS_WSUS_CONTROL_MANAGER' and stmsg.MessageID = 1015 and stmsg.SiteCode = '$SiteCode'"
    if ($component -ne $null)
    {
        Write-Host "Found SMS_WSUS_CONTROL_MANAGER 1015 id's"
        break
    } else { Start-Sleep 10 }
}

while ($true)
{
    $component = gwmi -Namespace ("root\sms\site_$SiteCode") -query "select stmsg.* from SMS_StatMsg stmsg where stmsg.Component = 'SMS_WSUS_CONTROL_MANAGER' and stmsg.MessageID = 500 and stmsg.SiteCode = '$SiteCode'"
    if ($component -ne $null)
    {
        Write-Host "Found SMS_WSUS_CONTROL_MANAGER 500 id's"
        break
    } else { Start-Sleep 10 }
}

$component = gwmi -Namespace ("root\sms\site_$SiteCode") -query "select stmsg.* from SMS_StatMsg stmsg where stmsg.Component = 'SMS_WSUS_CONTROL_MANAGER' and stmsg.MessageID = 6600 and stmsg.SiteCode = '$SiteCode'"
if ($component -ne $null)
{
    Write-Host "ERROR: Found SMS_WSUS_CONTROL_MANAGER 6600 id's" -ForegroundColor Red
}

while ($true)
{
    $component = gwmi -Namespace ("root\sms\site_$SiteCode") -query "select stmsg.* from SMS_StatMsg stmsg where stmsg.Component = 'SMS_WSUS_CONTROL_MANAGER' and stmsg.MessageID = 4629 and stmsg.SiteCode = '$SiteCode'"
    if ($component -ne $null)
    {
        Write-Host "Found SMS_WSUS_CONTROL_MANAGER 4629 id's"
        break
    } else { Start-Sleep 10 }
}

while ($true)
{
    $component = gwmi -Namespace ("root\sms\site_$SiteCode") -query "select stmsg.* from SMS_StatMsg stmsg where stmsg.Component = 'SMS_WSUS_SYNC_MANAGER' and stmsg.MessageID = 4629 and stmsg.SiteCode = '$SiteCode'"
    if ($component -ne $null)
    {
        Write-Host "Found SMS_WSUS_SYNC_MANAGER 4629 id's"
        break
    } else { Start-Sleep 10 }
}

while ($true)
{
    $component = gwmi -Namespace ("root\sms\site_$SiteCode") -query "select stmsg.* from SMS_StatMsg stmsg where stmsg.Component = 'SMS_WSUS_CONFIGURATION_MANAGER' and stmsg.MessageID = 4629 and stmsg.SiteCode = '$SiteCode'"
    if ($component -ne $null)
    {
        Write-Host "Found SMS_WSUS_CONFIGURATION_MANAGER 4629 id's"
        break
    } else { Start-Sleep 10 }
}

$Languages = @("Chinese (Simplified, China)", "French", "German", "Japanese", "Russian") 
$schedule = New-CMSchedule -RecurCount 1 -RecurInterval Days
#remove all classifications from sync
Set-CMSoftwareUpdatePointComponent -SiteCode $SiteCode -ImmediatelyExpireSupersedence $True -RemoveUpdateClassification @("Security Updates", "Service Packs", "Update Rollups") -RemoveLanguageSummaryDetail $Languages -RemoveLanguageUpdateFile $Languages
start-sleep 5
#Add critical updates only
Set-CMSoftwareUpdatePointComponent -SiteCode $SiteCode -AddUpdateClassification "Critical Updates"
#remove all products and classifications from sync (there is no option to remove products from sync)
$wmiList = Get-WmiObject -Namespace "Root\SMS\Site_$SiteCode" SMS_UpdateCategoryInstance -Filter "IsSubscribed = 'True'"
foreach ($wmiItem in $wmiList)
{
	$wmiItem.IsSubscribed = $false
	$wmiItem.Put() | out-null
}
Start-Sleep 5

Set-CMSoftwareUpdatePointComponent -EnableSynchronization $True -Schedule $Schedule -SiteCode $SiteCode -SynchronizeAction SynchronizeFromMicrosoftUpdate
