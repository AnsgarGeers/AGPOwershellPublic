$SiteCode = "001"
 
$ClientSettingsName = "Default Client Agent Settings"
Set-CMClientSetting -ComputerAgentSettings -Name "$ClientSettingsName" -BrandingTitle "Training Lab"

$schedule = New-CMSchedule -RecurCount 1 -RecurInterval Days
Set-CMClientSetting -HardwareInventorySettings -Name "$ClientSettingsName" -EnableHardwareInventory $True -InventorySchedule $Schedule

Set-CMClientSetting -Name "$ClientSettingsName" -SoftwareInventorySettings -EnableSoftwareInventory $True -SoftwareInventorySchedule $schedule
$settings = gwmi -Namespace "root\sms\site_$SiteCode" -Class SMS_SCI_ClientComp -Filter "FileType=2 and ItemName='Software Inventory Agent' and ItemType='Client Component' and SiteCode='$($SiteCode)'"
$values = @("*.exe", "*", "true", "true", "true")
$reg = $settings.RegMultiStringLists
for($i=0;$i -le 4; $i++)
{
    $reg[$i].ValueStrings += $values[$i]
}
$settings.RegMultiStringLists = $reg
$settings.Put()

Set-CMClientSetting -Name "$ClientSettingsName" -StateMessageSettings -StateMessagingReportingCycleMinutes 2