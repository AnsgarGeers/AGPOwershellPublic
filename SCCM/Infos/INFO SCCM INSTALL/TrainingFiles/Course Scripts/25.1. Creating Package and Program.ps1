$SiteCode = "001"
$dkserver = "SRV0002.classroom.intranet"

$pkg = New-CMPackage -Name "Chrome for Linux" -Path "\\srv0001\trainingfiles\source\Chrome for Linux"
$prg = New-CMProgram -CommandLine "rpm -ivh google-chrome-stable_current_x86_64.rpm" -PackageName "Chrome for Linux" -StandardProgramName "Install Chrome for Linux" -ProgramRunType WhetherOrNotUserIsLoggedOn -RunMode RunWithAdministrativeRights

$prgInfo = gwmi SMS_Program -namespace root\sms\site_$SiteCode -filter "PackageID='$($pkg.PackageID)' and ProgramName='$($prg.ProgramName)'"
$prgInfo.Get()

$newOS = ([WMIClass]("\\.\root\sms\site_$($sitecode):SMS_OS_Details")).CreateInstance()
$newOS.MaxVersion = "7.99.9999.9999"
$newOS.MinVersion = "7.00.0000.0"
$newOS.Name = "CentOS"
$newOS.Platform = "x64"

$prgInfo.SupportedOperatingSystems = $newOS
if (($prgInfo.ProgramFlags -band 0x08000000) -ne 0)
{
	$prgInfo.ProgramFlags = $prgInfo.ProgramFlags -bxor 0x08000000
}
$prgInfo.Put() | out-null

Start-CMContentDistribution -PackageId $pkg.PackageID -DistributionPointGroupName "Training Lab"