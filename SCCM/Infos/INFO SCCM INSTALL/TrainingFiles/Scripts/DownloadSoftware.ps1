$logpath = "$($env:windir)\temp\DownloadSoftware.ps1.log"
$rootFolder = "d:\TrainingFiles"

##Functions
Function Write-Log
{
	PARAM (
		[String]$Message,
		[int]$severity = 1
	)
	$TimeZoneBias = Get-WmiObject -Query "Select Bias from Win32_TimeZone"
	$Date = Get-Date -Format "HH:mm:ss.fff"
	$Date2 = Get-Date -Format "MM-dd-yyyy"
	$type = 1
	
	if (($logpath -ne $null) -and ($logpath -ne ''))
	{
		"<![LOG[$Message]LOG]!><time=`"$date+$($TimeZoneBias.bias)`" date=`"$date2`" component=`"$component`" context=`"`" type=`"$severity`" thread=`"`" file=`"`">" | Out-File -FilePath $logpath -Append -NoClobber -Encoding default
	}
	
	switch ($severity)
	{
		3 { Write-Host $Message -ForegroundColor Red }
		2 { Write-Host $Message -ForegroundColor Yellow }
		1 { Write-Host $Message }
	}
}

function Get-File
{
	param (
		[string]$URL,
		[string]$Path,
		[string]$FileName
	)
	$FilePath = "$Path\$FileName"
	
	if (Test-Path $filePath)
	{
		Write-log -message "file $FilePath already exist, ignoring it" -severity 2
		return
	}
	
	try
	{
		Write-log -message "Downloading $URL to $FilePath" -severity 1
		$WebClient = New-Object System.Net.WebClient
		$WebClient.DownloadFile($URL, $FilePath)
	}
	catch
	{
		Write-log -message "Failed to download from [$URL]" -severity 3
		Write-log -message "Error: $_" -severity 3
	}
}

function New-Folder
{
	param (
		[string]$FolderPath
	)
	if (!(Test-Path $FolderPath))
	{
		Write-log -message "Creating folder $FolderPath" -severity 1
		New-Item ($FolderPath) -type directory -force | out-null
	}
	else
	{
		Write-log -message "folder $FolderPath already exist, ignoring it" -severity 2
	}
	
}

##Variables
$Folders1stLevel = "GPO;Isos;OSCaptured;Scripts;Source;vhdx;AnswerFiles"
$eicarString1 = 'X5O!P%@AP[4\PZX54(P^)7CC)7}$EICAR'
$eicarString2 = '-STANDARD-ANTIVIRUS-TEST-FILE!$H+H*'

$downloadFiles = @(
"7-zip;http://www.7-zip.org/a/7z1604-x64.exe;7z1604-x64.exe",
"AdobeXI;ftp://ftp.adobe.com/pub/adobe/reader/win/11.x/11.0.10/en_US/AdbeRdr11010_en_US.exe;AdbeRdr11010_en_US.exe",
"AdobeXI;ftp://ftp.adobe.com/pub/adobe/reader/win/11.x/11.0.18/misc/AdbeRdrUpd11018.msp;AdbeRdrUpd11018.msp",
"Chrome for Windows;https://dl.google.com/tag/s/appguid%3D%7B8A69D345-D564-463C-AFF1-A69D9E530F96%7D%26iid%3D%7B03FE9563-80F9-119F-DA3D-72FBBB94BC26%7D%26lang%3Den%26browser%3D4%26usagestats%3D0%26appname%3DGoogle%2520Chrome%26needsadmin%3Dprefers%26ap%3Dx64-stable/dl/chrome/install/googlechromestandaloneenterprise64.msi;googlechromestandaloneenterprise64.msi",
"Chrome for Linux;https://dl.google.com/linux/direct/google-chrome-stable_current_x86_64.rpm;google-chrome-stable_current_x86_64.rpm",
"Firefox 49;https://ftp.mozilla.org/pub/firefox/releases/49.0.1/win64/en-GB/Firefox%20Setup%2049.0.1.exe;Firefox Setup 49.0.1.exe",
"Firefox 40;https://ftp.mozilla.org/pub/firefox/releases/40.0/win32/en-US/Firefox%20Setup%2040.0.exe;Firefox Setup 40.0.exe",
"Java8;http://javadl.oracle.com/webapps/download/AutoDL?BundleId=211997;Java8.exe",
"Robocopy App-V5 Download;http://bit.ly/17h1rjP;Robocopy App-V5.zip",
"AdkW10Download;https://go.microsoft.com/fwlink/p/?LinkId=526740;adksetup.exe",
"SCCMCB;http://care.dlservice.microsoft.com/dl/download/F/B/9/FB9B10A3-4517-4E03-87E6-8949551BC313/SC_Configmgr_SCEP_1606.exe;SC_Configmgr_CB.exe",
"SCCMCB-LinuxClient;https://download.microsoft.com/download/B/8/5/B855F253-8EB6-4E4B-A6D8-E32A23D5EB8B/Config%20Mgr%20Clients%20for%20Linux.EXE;Config Mgr Clients for Linux.EXE",
"SCCMCB-Toolkit;https://download.microsoft.com/download/5/0/8/508918E1-3627-4383-B7D8-AA07B3490D21/ConfigMgrTools.msi;ConfigMgrTools.msi",
"SCUP2011;https://download.microsoft.com/download/4/4/2/442F4D26-8331-4386-98F4-C17A3A89F46C/SystemCenterUpdatesPublisher.msi;SystemCenterUpdatesPublisher.msi",
"W10MobileEmulator;https://go.microsoft.com/fwlink/p/?LinkId=822928;EmulatorSetup.exe",
"ADConnect;https://download.microsoft.com/download/B/0/0/B00291D0-5A83-4DE7-86F5-980BC00DE05A/AzureADConnect.msi;AzureADConnect.msi",
"SQLMgmt;http://go.microsoft.com/fwlink/?linkid=832812;SSMS-Setup-ENU.exe"
)

$downloadIsos = @(
"http://buildlogs.centos.org/rolling/7/isos/x86_64/CentOS-7-x86_64-Everything.iso;CentOS-7-x86_64-Everything.iso",
"http://mirror.vyos.net/iso/release/1.1.3/vyos-1.1.3-amd64.iso;vyos-1.1.3-amd64.iso",
"http://downloads.sourceforge.net/project/android-x86/Release%204.4/android-x86-4.4-r2.iso;android-x86-4.4-r2.iso"
"http://care.dlservice.microsoft.com/dl/download/B/9/9/B999286E-0A47-406D-8B3D-5B5AD7373A4A/9600.17050.WINBLUE_REFRESH.140317-1640_X64FRE_ENTERPRISE_EVAL_EN-US-IR3_CENA_X64FREE_EN-US_DV9.ISO;W81EE.iso",
"http://care.dlservice.microsoft.com/dl/download/2/5/4/254230E8-AEA5-43C5-94F6-88CE222A5846/14393.0.160715-1616.RS1_RELEASE_CLIENTENTERPRISEEVAL_OEMRET_X64FRE_EN-US.ISO;W10EE.iso",
"http://care.dlservice.microsoft.com/dl/download/1/6/F/16FA20E6-4662-482A-920B-1A45CF5AAE3C/14393.0.160715-1616.RS1_RELEASE_SERVER_EVAL_X64FRE_EN-US.ISO;WS2016.iso",
"http://download.microsoft.com/download/F/1/0/F10113F5-B750-4969-A255-274341AC6BCE/GRMSDK_EN_DVD.iso;GRMSDK_EN_DVD.iso",
"http://care.dlservice.microsoft.com/dl/download/F/E/9/FE9397FA-BFAB-4ADD-8B97-91234BC774B2/SQLServer2016-x64-ENU.iso;SQL2016.iso"
)

##Main Script
Write-log -message "Starting Script" -severity 1
Write-log -message "Root Folder is $rootFolder " -severity 1

New-Folder -FolderPath ("$rootFolder")

foreach ($folder in $Folders1stLevel.Split(";"))
{
	New-Folder -FolderPath ("$($rootFolder)\$($folder)")
}

foreach ($download in $downloadFiles)
{
	$downinfo = $download.split(";")
	New-Folder -FolderPath ("$($rootFolder)\source\$($downinfo[0])")
	Get-File -URL $downinfo[1] -Path ("$($rootFolder)\source\$($downinfo[0])") -FileName ($downinfo[2])
}

foreach ($download in $downloadIsos)
{
	$downinfo = $download.split(";")
	Get-File -URL $downinfo[0] -Path ("$($rootFolder)\isos") -FileName ($downinfo[1])
}

##Create EICAR AV Test File
try
{
	if (Test-Path "$($rootFolder)\source\Eicar\eicar test file.txt")
	{
		Write-log -message "file $($rootFolder)\source\Eicar\eicar test file.txt already exist, ignoring it" -severity 2
	}
	else
	{
		Write-log -message "Creating EICAR AV TEST File" -severity 1
		New-Folder -FolderPath ("$($rootFolder)\source\Eicar")
		"$($eicarString1)$($eicarString2)" | Out-File -FilePath "$($rootFolder)\source\Eicar\eicar test file.txt" -Encoding default
	}
}
catch
{
	Write-log -message "Error: $_" -severity 3
}

##Extract robocopy
try
{
	if (Test-Path "$($rootFolder)\source\Robocopy App-v5")
	{
		Write-log -message "Folder $($rootFolder)\source\Robocopy App-v5 already exist, ignoring it" -severity 2
	}
	else
	{
		Write-log -message "Extract robocopy" -severity 1
		[System.Reflection.Assembly]::LoadWithPartialName('System.IO.Compression.FileSystem')
		[System.IO.Compression.ZipFile]::ExtractToDirectory("$($rootFolder)\source\Robocopy App-V5 Download\Robocopy App-v5.zip", "$($rootFolder)\source")
		start-sleep 5
	}
}
catch
{
	Write-log -message "Error: $_" -severity 3
}

##Makecert
try
{
	if (Test-Path "$($rootFolder)\Source\makecert\makecert.exe")
	{
		Write-log -message "file $($rootFolder)\Source\makecert\makecert.exe already exist, ignoring it" -severity 2
	}
	else
	{
		Write-log -message "Creating makecert file" -severity 1
		New-Folder -FolderPath ("$($rootFolder)\source\makecert")
		Mount-DiskImage -ImagePath ("$($rootFolder)\Isos\GRMSDK_EN_DVD.iso")
		start-sleep 5
		$DriveLetter = (Get-Volume | Where-Object { $_.DriveType -eq "CD-ROM" }).DriveLetter
		expand "$($DriveLetter):\Setup\WinSDKTools\cab1.cab" /f:WinSDK_makecert_exe_24DFD147_3F96_47FC_B09E_5FCACE50CD4C_x86 "$($rootFolder)\Source\makecert"
		start-sleep 5
		Move-Item -Path "$($rootFolder)\Source\makecert\WinSDK_makecert_exe_24DFD147_3F96_47FC_B09E_5FCACE50CD4C_x86" -Destination "$($rootFolder)\Source\makecert\makecert.exe"
		Dismount-DiskImage -ImagePath ("$($rootFolder)\Isos\GRMSDK_EN_DVD.iso")
		start-sleep 5
	}
}
catch
{
	Write-log -message "Error: $_" -severity 3
}

##adkW10 extract files
try
{
	if (Test-Path "$($rootFolder)\source\AdkW10")
	{
		Write-log -message "Folder $($rootFolder)\source\AdkW10 already exist, ignoring it" -severity 2
	}
	else
	{
		Write-log -message "Executing adksetup" -severity 1
		New-Folder -FolderPath ("$($rootFolder)\source\adkW10")
		Start-Process -Filepath ("$($rootFolder)\source\AdkW10Download\adksetup.exe") -ArgumentList ("/layout $($rootFolder)\source\AdkW10 /quiet") -Wait
	}
} 
catch
{
	Write-log -message "Error: $_" -severity 3
}

##Extract SCCM CB Files
try
{
	if (Test-Path "$($rootFolder)\source\SCCMCB\Extract")
	{
		Write-log -message "Folder $($rootFolder)\source\SCCMCB\Extract already exist, ignoring it" -severity 2
	}
	else
	{
		Write-log -message "Extract SCCM CB Files" -severity 1
		Start-Process -Filepath ("$($rootFolder)\source\SCCMCB\SC_Configmgr_CB.exe") -ArgumentList ("/auto") -wait
		start-sleep 5
		Start-Process -FilePath ("c:\windows\system32\robocopy.exe") -ArgumentList ("C:\SC_Configmgr_SCEP_1606 $($rootFolder)\source\SCCMCB\Extract /s /e /copy:DAT /r:1 /w:1 /xj /xjd /xjf") -wait
		Remove-Item "C:\SC_Configmgr_SCEP_1606" -force -recurse
	}
}
catch
{
	Write-log -message "Error: $_" -severity 3
}



##SCCM Redist Files
try
{
	if (Test-Path "$($rootFolder)\source\SCCMCB\Redist")
	{
		Write-log -message "Folder $($rootFolder)\source\SCCMCB\Redist already exist, ignoring it" -severity 2
	}
	else
	{
		Write-log -message "SCCM Redist Files" -severity 1
		Start-Process -Filepath ("$($rootFolder)\source\SCCMCB\Extract\SMSSETUP\BIN\X64\setupdl.exe") -ArgumentList ("$($rootFolder)\source\SCCMCB\Redist") -wait
	}
}
catch
{
	Write-log -message "Error: $_" -severity 3
}

##Extract SCCM Linux Files
try
{
	if (Test-Path "$($rootFolder)\source\SCCMCB-LinuxClient\Extract")
	{
		Write-log -message "Folder $($rootFolder)\source\SCCMCB-LinuxClient\Extract already exist, ignoring it" -severity 2
	}
	else
	{
		Write-log -message "Extract SCCM Linux Files" -severity 1
		Start-Process -Filepath ("$($rootFolder)\source\SCCMCB-LinuxClient\Config Mgr Clients for Linux.EXE") -ArgumentList ("/q /C /T:$($rootFolder)\source\SCCMCB-LinuxClient\Extract") -wait
		start-sleep 5
	}
}
catch
{
	Write-log -message "Error: $_" -severity 3
}

##Extract W10 EE
try
{
	if (Test-Path "$($rootFolder)\source\W10EE")
	{
		Write-log -message "Folder $($rootFolder)\source\W10EE already exist, ignoring it" -severity 2
	}
	else
	{
		Write-log -message "Extract W10 EE" -severity 1
		Mount-DiskImage -ImagePath ("$($rootFolder)\isos\W10EE.iso")
		start-sleep 5
		$DriveLetter = (Get-Volume | Where-Object { $_.DriveType -eq "CD-ROM" }).DriveLetter
		Start-Process -FilePath ("c:\windows\system32\robocopy.exe") -ArgumentList ("$($DriveLetter):\ $($rootFolder)\source\W10EE /s /e /copy:DAT /r:1 /w:1 /xj /xjd /xjf") -wait
		Dismount-DiskImage -ImagePath ("$($rootFolder)\isos\W10EE.iso")
		start-sleep 5
	}
}
catch
{
	Write-log -message "Error: $_" -severity 3
}

##Extract W8.1 EE
try
{
	if (Test-Path "$($rootFolder)\source\W81EE")
	{
		Write-log -message "Folder $($rootFolder)\source\W81EE already exist, ignoring it" -severity 2
	}
	else
	{
		Write-log -message "Extract W8.1 EE" -severity 1
		Mount-DiskImage -ImagePath ("$($rootFolder)\isos\W81EE.iso")
		start-sleep 5
		$DriveLetter = (Get-Volume | Where-Object { $_.DriveType -eq "CD-ROM" }).DriveLetter
		Start-Process -FilePath ("c:\windows\system32\robocopy.exe") -ArgumentList ("$($DriveLetter):\ $($rootFolder)\source\W81EE /s /e /copy:DAT /r:1 /w:1 /xj /xjd /xjf") -wait
		Dismount-DiskImage -ImagePath ("$($rootFolder)\isos\W81EE.iso")
		start-sleep 5
	}
}
catch
{
	Write-log -message "Error: $_" -severity 3
}

##Extract WS2016
try
{
	if (Test-Path "$($rootFolder)\source\WS2016")
	{
		Write-log -message "Folder $($rootFolder)\source\WS2016 already exist, ignoring it" -severity 2
	}
	else
	{
		Write-log -message "Extract WS2016" -severity 1
		Mount-DiskImage -ImagePath ("$($rootFolder)\isos\WS2016.iso")
		start-sleep 5
		$DriveLetter = (Get-Volume | Where-Object { $_.DriveType -eq "CD-ROM" }).DriveLetter
		Start-Process -FilePath ("c:\windows\system32\robocopy.exe") -ArgumentList ("$($DriveLetter):\ $($rootFolder)\source\WS2016 /s /e /copy:DAT /r:1 /w:1 /xj /xjd /xjf") -wait
		Dismount-DiskImage -ImagePath ("$($rootFolder)\isos\WS2016.iso")
		start-sleep 5
	}
}
catch
{
	Write-log -message "Error: $_" -severity 3
}

##Extract SQL2016
try
{
	if (Test-Path "$($rootFolder)\source\SQL2016")
	{
		Write-log -message "Folder $($rootFolder)\source\SQL2016 already exist, ignoring it" -severity 2
	}
	else
	{
		Write-log -message "Extract WS2016" -severity 1
		Mount-DiskImage -ImagePath ("$($rootFolder)\isos\SQL2016.iso")
		start-sleep 5
		$DriveLetter = (Get-Volume | Where-Object { $_.DriveType -eq "CD-ROM" }).DriveLetter
		Start-Process -FilePath ("c:\windows\system32\robocopy.exe") -ArgumentList ("$($DriveLetter):\ $($rootFolder)\source\SQL2016 /s /e /copy:DAT /r:1 /w:1 /xj /xjd /xjf") -wait
		Dismount-DiskImage -ImagePath ("$($rootFolder)\isos\SQL2016.iso")
		start-sleep 5
	}
}
catch
{
	Write-log -message "Error: $_" -severity 3
}
