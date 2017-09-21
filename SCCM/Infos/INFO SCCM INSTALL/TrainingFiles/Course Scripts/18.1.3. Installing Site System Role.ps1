$SiteCode = "001"
$servername = "SRV0002.classroom.intranet"
 
if ((Get-CMSiteSystemServer -SiteSystemServerName "$servername") -eq $null) { New-CMSiteSystemServer –SiteCode $SiteCode –UseSiteServerAccount –ServerName $servername }
Add-CMApplicationCatalogWebServicePoint -SiteSystemServerName "$ServerName" -CommunicationType HTTP -PortNumber 80 -SiteCode $SiteCode

start-sleep 90

while ($true)
{
    $component = gwmi -Namespace ("root\sms\site_$SiteCode") -query "select stmsg.* from SMS_StatMsg stmsg where stmsg.Component = 'SMS_AWEBSVC_CONTROL_MANAGER' and stmsg.MessageID = 1013 and stmsg.SiteCode = '$SiteCode'"
    if ($component -ne $null)
    {
        Write-Host "Found SMS_AWEBSVC_CONTROL_MANAGER 1013 id's"
        break
    } else { Start-Sleep 10 }
}

while ($true)
{
    $component = gwmi -Namespace ("root\sms\site_$SiteCode") -query "select stmsg.* from SMS_StatMsg stmsg where stmsg.Component = 'SMS_AWEBSVC_CONTROL_MANAGER' and stmsg.MessageID = 1014 and stmsg.SiteCode = '$SiteCode'"
    if ($component -ne $null)
    {
        Write-Host "Found SMS_AWEBSVC_CONTROL_MANAGER 1014 id's"
        break
    } else { Start-Sleep 10 }
}

while ($true)
{
    $component = gwmi -Namespace ("root\sms\site_$SiteCode") -query "select stmsg.* from SMS_StatMsg stmsg where stmsg.Component = 'SMS_AWEBSVC_CONTROL_MANAGER' and stmsg.MessageID = 1015 and stmsg.SiteCode = '$SiteCode'"
    if ($component -ne $null)
    {
        Write-Host "Found SMS_AWEBSVC_CONTROL_MANAGER 1015 id's"
        break
    } else { Start-Sleep 10 }
}

while ($true)
{
    $component = gwmi -Namespace ("root\sms\site_$SiteCode") -query "select stmsg.* from SMS_StatMsg stmsg where stmsg.Component = 'SMS_AWEBSVC_CONTROL_MANAGER' and stmsg.MessageID = 500 and stmsg.SiteCode = '$SiteCode'"
    if ($component -ne $null)
    {
        Write-Host "Found SMS_AWEBSVC_CONTROL_MANAGER 500 id's"
        break
    } else { Start-Sleep 10 }
}

while ($true)
{
    $component = gwmi -Namespace ("root\sms\site_$SiteCode") -query "select stmsg.* from SMS_StatMsg stmsg where stmsg.Component = 'SMS_AWEBSVC_CONTROL_MANAGER' and stmsg.MessageID = 8102 and stmsg.SiteCode = '$SiteCode'"
    if ($component -ne $null)
    {
        Write-Host "Found SMS_AWEBSVC_CONTROL_MANAGER 8102 id's"
        break
    } else { Start-Sleep 10 }
}

$web = New-Object -ComObject msxml2.xmlhttp
$url = "http://$($servername):80/CMApplicationCatalogSvc/ApplicationOfferService.svc"
while ($true)
{
    try
    {   
        $web.open('GET', $url, $false)
		$web.send()

		if ($web.status -eq "404") { start-sleep 10 }
		if ($web.status -eq "200")
		{
				Write-Host "Found CMApplicationCatalogSvc site"
        		break
		}
    } catch {
	#
    }
}
