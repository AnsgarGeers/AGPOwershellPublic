$logpath = "$($env:windir)\temp\CreateVMs.ps1.log"
$rootFolder = "D:\TrainingFiles"
$Edition = "ServerStandardEval"
#$Edition = "ServerStandard"
$CreateVM = $true
# Load (aka "dot-source) the Function 
. .\Convert-WindowsImage.ps1 

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

##Create Virtual Networks
$Ethernet = Get-NetAdapter -Physical 
if ((Get-VMSwitch -Name "CLASSROOM-EXTERNAL" -ErrorAction SilentlyContinue) -eq $null)
{
	Write-log -message "Creating VMSwitch CLASSROOM-EXTERNAL" -severity 1
	New-VMSwitch -Name "CLASSROOM-EXTERNAL" -NetAdapterName $Ethernet[0].Name -AllowManagementOS $true -Notes "Allow internet for VM's"
} else {
	Write-log -message "VMSwitch CLASSROOM-EXTERNAL already exist, ignoring it" -severity 2
}

if ((Get-VMSwitch -Name "CLASSROOM-INTERNAL" -ErrorAction SilentlyContinue) -eq $null)
{
	Write-log -message "Creating VMSwitch CLASSROOM-INTERNAL" -severity 1
	New-VMSwitch -Name "CLASSROOM-INTERNAL" -SwitchType Private
} else {
	Write-log -message "VMSwitch CLASSROOM-INTERNAL already exist, ignoring it" -severity 2
}

Set-VMHost -EnableEnhancedSessionMode $true -Passthru

if ((get-vm -Name "CLASSROOM-ROUTER01" -ErrorAction SilentlyContinue) -ne $null)
{
	Write-log -message "VM CLASSROOM-ROUTER01 already exist, ignoring it" -severity 2
} else {
	##CREATE ROUTER01 VHDX file
	try
	{
		Write-log -message "Create ROUTER01 VHDX file" -severity 1
		New-VHD -Path "$($rootFolder)\VHDX\router01.vhdx" -SizeBytes (2 * 1024 * 1024 * 1024)
		start-sleep 5
	}
	catch
	{
		Write-log -message "Error: $_" -severity 3
	}

	##create ROUTER01 VM
	try
	{
		Write-log -message "create ROUTER01 VM" -severity 1
		New-VM -Name "CLASSROOM-ROUTER01" -VHDPath "$($rootFolder)\VHDX\router01.vhdx" -MemoryStartupBytes (512 * 1024 * 1024) -SwitchName "CLASSROOM-EXTERNAL" -Generation 1 -Path "$($rootFolder)\VHDX"
		Add-VMNetworkAdapter -VMName "CLASSROOM-ROUTER01" -SwitchName "CLASSROOM-INTERNAL"
		Enable-VMIntegrationService -Name "Guest Service Interface" -VMName "CLASSROOM-ROUTER01"
		Set-VMDvdDrive -VMName "CLASSROOM-ROUTER01" -ControllerNumber 1 -Path "$($rootFolder)\isos\vyos-1.1.3-amd64.iso"
	}
	catch
	{
		Write-log -message "Error: $_" -severity 3
	}
}

if ((get-vm -Name "CLASSROOM-SRV0001" -ErrorAction SilentlyContinue) -ne $null)
{
	Write-log -message "VM CLASSROOM-SRV0001 already exist, ignoring it" -severity 2
} else {
	##Create SRV0001 VHDX file
	try
	{
		Write-log -message "Create SRV0001 VHDX file" -severity 1
		Convert-WindowsImage -WIM "$($rootFolder)\source\WS2016\sources\install.wim" -VHDFormat VHDX -SizeBytes 127GB -VHDPath "$($rootFolder)\VHDX\srv0001.vhdx" -Edition $Edition -VHDPartitionStyle GPT
		Mount-DiskImage -ImagePath "$($rootFolder)\VHDX\srv0001.vhdx"
		$DriveLetter = (Get-Volume | Where-Object { $_.FileSystemLabel -eq "" }).DriveLetter | select-object -last 1
		Copy-Item "$($rootFolder)\GPO" "$($DriveLetter):\trainingfiles\GPO" -Force -Recurse
		Copy-Item "$($rootFolder)\OSCaptured" "$($DriveLetter):\trainingfiles\OSCaptured" -Force -Recurse
		Copy-Item "$($rootFolder)\Scripts" "$($DriveLetter):\trainingfiles\Scripts" -Force -Recurse
		Copy-Item "$($rootFolder)\Source" "$($DriveLetter):\trainingfiles\Source" -Force -Recurse
		New-Item "$($DriveLetter):\Windows\Panther" -type directory -force | out-null
		$answerfile = gc "$($rootFolder)\AnswerFiles\SRV0001.xml"
		$answerfile | Out-File -FilePath "$($DriveLetter):\Windows\Panther\unattend.xml" -NoClobber -Encoding default
		start-sleep 5
		Dismount-DiskImage -ImagePath "$($rootFolder)\VHDX\srv0001.vhdx"
		start-sleep 5
	}
	catch
	{
		Write-log -message "Error: $_" -severity 3
	}

	##create SRV0001 VM
	try
	{
		if ($CreateVM) {
			Write-log -message "create SRV0001 VM" -severity 1
			New-VM -Name "CLASSROOM-SRV0001" -VHDPath "$($rootFolder)\VHDX\srv0001.vhdx" -MemoryStartupBytes (2048 * 1024 * 1024) -SwitchName "CLASSROOM-INTERNAL" -Generation 2 -Path "$($rootFolder)\VHDX"
			Enable-VMIntegrationService -Name "Guest Service Interface" -VMName "CLASSROOM-SRV0001"
		}
	}
	catch
	{
		Write-log -message "Error: $_" -severity 3
	}
}

if ((get-vm -Name "CLASSROOM-SRV0002" -ErrorAction SilentlyContinue) -ne $null)
{
	Write-log -message "VM CLASSROOM-SRV0002 already exist, ignoring it" -severity 2
}
else
{
	##Create SRV0002 VHDX file
	try
	{
		Write-log -message "Create SRV0002 VHDX file" -severity 1
		Convert-WindowsImage -WIM "$($rootFolder)\source\WS2016\sources\install.wim" -VHDFormat VHDX -SizeBytes 127GB -VHDPath "$($rootFolder)\VHDX\srv0002.vhdx" -Edition $Edition -VHDPartitionStyle GPT
		Mount-DiskImage -ImagePath "$($rootFolder)\VHDX\srv0002.vhdx"
		$DriveLetter = (Get-Volume | Where-Object { $_.FileSystemLabel -eq "" }).DriveLetter | select-object -last 1
		New-Item "$($DriveLetter):\Windows\Panther" -type directory -force | out-null
		$answerfile = gc "$($rootFolder)\AnswerFiles\SRV0002.xml"
		$answerfile | Out-File -FilePath "$($DriveLetter):\Windows\Panther\unattend.xml" -NoClobber -Encoding default
		Copy-Item "$($rootFolder)\Scripts" "$($DriveLetter):\trainingfiles\Scripts" -Force -Recurse
		start-sleep 5
		Dismount-DiskImage -ImagePath "$($rootFolder)\VHDX\srv0002.vhdx"
		start-sleep 5
	}
	catch
	{
		Write-log -message "Error: $_" -severity 3
	}

	##create SRV0002 VM
	try
	{
		if ($CreateVM) {
			Write-log -message "create SRV0002 VM" -severity 1
			New-VM -Name "CLASSROOM-SRV0002" -VHDPath "$($rootFolder)\VHDX\srv0002.vhdx" -MemoryStartupBytes (8 * 1024 * 1024 * 1024) -SwitchName "CLASSROOM-INTERNAL" -Generation 2 -Path "$($rootFolder)\VHDX"
			Enable-VMIntegrationService -Name "Guest Service Interface" -VMName "CLASSROOM-SRV0002"
		}
	}
	catch
	{
		Write-log -message "Error: $_" -severity 3
	}
}

if ((get-vm -Name "CLASSROOM-SRV0003" -ErrorAction SilentlyContinue) -ne $null)
{
	Write-log -message "VM CLASSROOM-SRV0003 already exist, ignoring it" -severity 2
}
else
{
	##CREATE SRV0003 VHDX file
	try
	{
		Write-log -message "Create SRV0003 VHDX file" -severity 1
		New-VHD -Path "$($rootFolder)\VHDX\srv0003.vhdx" -SizeBytes (127 * 1024 * 1024 * 1024)
		start-sleep 5
	}
	catch
	{
		Write-log -message "Error: $_" -severity 3
	}

	##create SRV0003 VM
	try
	{
		if ($CreateVM) {
			Write-log -message "create SRV0003 VM" -severity 1
			New-VM -Name "CLASSROOM-SRV0003" -VHDPath "$($rootFolder)\VHDX\srv0003.vhdx" -MemoryStartupBytes (1024 * 1024 * 1024) -SwitchName "CLASSROOM-INTERNAL" -Generation 1 -Path "$($rootFolder)\VHDX"
			Enable-VMIntegrationService -Name "Guest Service Interface" -VMName "CLASSROOM-SRV0003"	
			Set-VMDvdDrive -VMName "CLASSROOM-SRV0003" -ControllerNumber 1 -Path "$($rootFolder)\isos\CentOS-7-x86_64-Everything.iso"
		}
	}
	catch
	{
		Write-log -message "Error: $_" -severity 3
	}
}

if ((get-vm -Name "CLASSROOM-WKS0001" -ErrorAction SilentlyContinue) -ne $null)
{
	Write-log -message "VM CLASSROOM-WKS0001 already exist, ignoring it" -severity 2
}
else
{
	##Create WKS0001 VHDX file
	try
	{
		Write-log -message "Create WKS0001 VHDX file" -severity 1
		Convert-WindowsImage -WIM "$($rootFolder)\source\W10EE\sources\install.wim" -VHDFormat VHDX -SizeBytes 127GB -VHDPath "$($rootFolder)\VHDX\wks0001.vhdx" -VHDPartitionStyle GPT
		Mount-DiskImage -ImagePath "$($rootFolder)\VHDX\wks0001.vhdx"
		$DriveLetter = (Get-Volume | Where-Object { $_.FileSystemLabel -eq "" }).DriveLetter | select-object -last 1
		New-Item "$($DriveLetter):\Windows\Panther" -type directory -force | out-null
		$answerfile = gc "$($rootFolder)\AnswerFiles\WKS0001.xml"
		$answerfile | Out-File -FilePath "$($DriveLetter):\Windows\Panther\unattend.xml" -NoClobber -Encoding default
		Copy-Item "$($rootFolder)\Scripts" "$($DriveLetter):\trainingfiles\Scripts" -Force -Recurse
		start-sleep 5
		Dismount-DiskImage -ImagePath "$($rootFolder)\VHDX\wks0001.vhdx"
		start-sleep 5
	}
	catch
	{
		Write-log -message "Error: $_" -severity 3
	}

	##create WKS0001 VM
	try
	{
		if ($CreateVM) {
			Write-log -message "create WKS0001 VM" -severity 1
			New-VM -Name "CLASSROOM-WKS0001" -VHDPath "$($rootFolder)\VHDX\wks0001.vhdx" -MemoryStartupBytes (2 * 1024 * 1024 * 1024) -SwitchName "CLASSROOM-INTERNAL" -Generation 2 -Path "$($rootFolder)\VHDX"
			Enable-VMIntegrationService -Name "Guest Service Interface" -VMName "CLASSROOM-WKS0001"
		}
	}
	catch
	{
		Write-log -message "Error: $_" -severity 3
	}
}

if ((get-vm -Name "CLASSROOM-WKS0002" -ErrorAction SilentlyContinue) -ne $null)
{
	Write-log -message "VM CLASSROOM-WKS0002 already exist, ignoring it" -severity 2
}
else
{
	##Create WKS0002 VHDX file
	try
	{
		Write-log -message "Create WKS0002 VHDX file" -severity 1
		Convert-WindowsImage -WIM "$($rootFolder)\source\W10EE\sources\install.wim" -VHDFormat VHDX -SizeBytes 127GB -VHDPath "$($rootFolder)\VHDX\wks0002.vhdx" -VHDPartitionStyle GPT
		Mount-DiskImage -ImagePath "$($rootFolder)\VHDX\wks0002.vhdx"
		$DriveLetter = (Get-Volume | Where-Object { $_.FileSystemLabel -eq "" }).DriveLetter | select-object -last 1
		New-Item "$($DriveLetter):\Windows\Panther" -type directory -force | out-null
		$answerfile = gc "$($rootFolder)\AnswerFiles\WKS0002.xml"
		$answerfile | Out-File -FilePath "$($DriveLetter):\Windows\Panther\unattend.xml" -NoClobber -Encoding default
		Copy-Item "$($rootFolder)\Scripts" "$($DriveLetter):\trainingfiles\Scripts" -Force -Recurse
		start-sleep 5
		Dismount-DiskImage -ImagePath "$($rootFolder)\VHDX\wks0002.vhdx"
		start-sleep 5
	}
	catch
	{
		Write-log -message "Error: $_" -severity 3
	}

	##create WKS0002 VM
	try
	{
		if ($CreateVM) {
			Write-log -message "create WKS0002 VM" -severity 1
			New-VM -Name "CLASSROOM-WKS0002" -VHDPath "$($rootFolder)\VHDX\wks0002.vhdx" -MemoryStartupBytes (2 * 1024 * 1024 * 1024) -SwitchName "CLASSROOM-INTERNAL" -Generation 2 -Path "$($rootFolder)\VHDX"
			Enable-VMIntegrationService -Name "Guest Service Interface" -VMName "CLASSROOM-WKS0002"
		}
	}
	catch
	{
		Write-log -message "Error: $_" -severity 3
	}
}

if ((get-vm -Name "CLASSROOM-WKS0003" -ErrorAction SilentlyContinue) -ne $null)
{
	Write-log -message "VM CLASSROOM-WKS0003 already exist, ignoring it" -severity 2
}
else
{
	##CREATE WKS0003 VHDX file
	try
	{
		Write-log -message "Create WKS0003 VHDX file" -severity 1
		New-VHD -Path "$($rootFolder)\VHDX\WKS0003.vhdx" -SizeBytes (127 * 1024 * 1024 * 1024)
		start-sleep 5
	}
	catch
	{
		Write-log -message "Error: $_" -severity 3
	}

	##create WKS0003 VM
	try
	{
		if ($CreateVM) {
			Write-log -message "create WKS0003 VM" -severity 1
			New-VM -Name "CLASSROOM-WKS0003" -VHDPath "$($rootFolder)\VHDX\WKS0003.vhdx" -MemoryStartupBytes (1024 * 1024 * 1024) -SwitchName "CLASSROOM-INTERNAL" -Generation 1 -Path "$($rootFolder)\VHDX"
			Enable-VMIntegrationService -Name "Guest Service Interface" -VMName "CLASSROOM-WKS0003"
			Set-VMDvdDrive -VMName "CLASSROOM-WKS0003" -ControllerNumber 1 -Path "$($rootFolder)\isos\android-x86-4.4-r2.iso"
		}
	}
	catch
	{
		Write-log -message "Error: $_" -severity 3
	}
}

if ((get-vm -Name "CLASSROOM-WKS0004" -ErrorAction SilentlyContinue) -ne $null)
{
	Write-log -message "VM CLASSROOM-WKS0004 already exist, ignoring it" -severity 1
}
else
{
	##Create WKS0004 VHDX file
	try
	{
		Write-log -message "Create WKS0004 VHDX file" -severity 1
		Convert-WindowsImage -WIM "$($rootFolder)\source\W81EE\sources\install.wim" -VHDFormat VHDX -SizeBytes 127GB -VHDPath "$($rootFolder)\VHDX\wks0004.vhdx" -VHDPartitionStyle GPT
		Mount-DiskImage -ImagePath "$($rootFolder)\VHDX\wks0004.vhdx"
		$DriveLetter = (Get-Volume | Where-Object { $_.FileSystemLabel -eq "" }).DriveLetter | select-object -last 1
		New-Item "$($DriveLetter):\Windows\Panther" -type directory -force | out-null
		$answerfile = gc "$($rootFolder)\AnswerFiles\WKS0004.xml"
		$answerfile | Out-File -FilePath "$($DriveLetter):\Windows\Panther\unattend.xml" -NoClobber -Encoding default
		Copy-Item "$($rootFolder)\Scripts" "$($DriveLetter):\trainingfiles\Scripts" -Force -Recurse
		start-sleep 5
		Dismount-DiskImage -ImagePath "$($rootFolder)\VHDX\wks0004.vhdx"
		start-sleep 5
	}
	catch
	{
		Write-log -message "Error: $_" -severity 3
	}

	##create WKS0004 VM
	try
	{
		if ($CreateVM) {
			Write-log -message "create WKS0004 VM" -severity 1
			New-VM -Name "CLASSROOM-WKS0004" -VHDPath "$($rootFolder)\VHDX\wks0004.vhdx" -MemoryStartupBytes (2 * 1024 * 1024 * 1024) -SwitchName "CLASSROOM-INTERNAL" -Generation 2 -Path "$($rootFolder)\VHDX"
			Enable-VMIntegrationService -Name "Guest Service Interface" -VMName "CLASSROOM-WKS0004"
		}
	}
	catch
	{
		Write-log -message "Error: $_" -severity 3
	}
}

if ((get-vm -Name "CLASSROOM-WKS0100" -ErrorAction SilentlyContinue) -ne $null)
{
	Write-log -message "VM CLASSROOM-WKS0100 already exist, ignoring it" -severity 2
}
else
{
	##CREATE WKS0100 VHDX file
	try
	{
		Write-log -message "Create WKS0100 VHDX file" -severity 1
		New-VHD -Path "$($rootFolder)\VHDX\WKS0100.vhdx" -SizeBytes (127 * 1024 * 1024 * 1024)
		start-sleep 5
	}
	catch
	{
		Write-log -message "Error: $_" -severity 3
	}

	##create WKS0100 VM
	try
	{
		if ($CreateVM) {
			Write-log -message "create WKS0100 VM" -severity 1
			New-VM -Name "CLASSROOM-WKS0100" -VHDPath "$($rootFolder)\VHDX\WKS0100.vhdx" -MemoryStartupBytes (2 * 1024 * 1024 * 1024) -SwitchName "CLASSROOM-INTERNAL" -Generation 2 -Path "$($rootFolder)\VHDX"
			Enable-VMIntegrationService -Name "Guest Service Interface" -VMName "CLASSROOM-WKS0003"
		}
	}
	catch
	{
		Write-log -message "Error: $_" -severity 3
	}
}
