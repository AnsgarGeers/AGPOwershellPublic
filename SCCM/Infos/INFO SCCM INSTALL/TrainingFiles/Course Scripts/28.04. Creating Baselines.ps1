New-CMBaseline -Name "Workstation Baseline" 

$ci1 = Get-CMConfigurationItem -name "Internet Explorer Default Start Page"
$ci2 = Get-CMConfigurationItem -name "Validate Mozalla Firefox Version"
Set-CMBaseline -Name "Workstation Baseline" -AddOSConfigurationItem $ci1.CI_ID -AddRequiredConfigurationItem $ci2.CI_ID