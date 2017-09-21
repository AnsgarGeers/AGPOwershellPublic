$SiteCode = "001"
$servername = "SRV0002.classroom.intranet"

$FeatureName = "Windows Store for Business Integration"
(gwmi -Namespace "root\SMS\site_$($SiteCode)" -query "select * from SMS_CM_UpdateFeatures where Name ='$FeatureName'").UpdateFeatureExposureStatus(1)

#$FeatureName = "Manage duplicate hardware identifiers"
#(gwmi -Namespace "root\SMS\site_$($SiteCode)" -query "select * from SMS_CM_UpdateFeatures where Name ='$FeatureName'").UpdateFeatureExposureStatus(1)
