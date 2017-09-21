$SiteCode = "001"
 
$Secure = 'Pa$$w0rd'| ConvertTo-SecureString -AsPlainText -Force
$account = "CLASSROOM\svc_sccmpush"
New-CMAccount -Name "$account" -Password $Secure -SiteCode "$SiteCode"

Set-CMClientPushInstallation -ChosenAccount "$account" -EnableAutomaticClientPushInstallation $False -EnableSystemTypeConfigurationManager $False -EnableSystemTypeServer $True -EnableSystemTypeWorkstation $True -InstallationProperty "SMSSITECODE=$($SiteCode) FSP=$($servername)" -InstallClientToDomainController $False -SiteCode "$($SiteCode)"
