$SiteCode = "001"
$servername = "SRV0002.classroom.intranet"

$ModulePath = $env:SMS_ADMIN_UI_PATH
if ($ModulePath -eq $null) {
	$ModulePath = (Get-ItemProperty -Path "Registry::HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Session Manager\Environment").SMS_ADMIN_UI_PATH
}

$ModulePath = $ModulePath.Replace("bin\i386","bin\resourceexplorer.exe")
#windows machine
Start-Process -Filepath ("$ModulePath") -ArgumentList ('-s -sms:ResExplrQuery="SELECT ResourceID FROM SMS_R_SYSTEM WHERE NAME = ''WKS0001''" -sms:connection=\\' + $servername + '\root\sms\site_' + $siteCode)
