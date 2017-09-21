$SiteCode = "001"
$servername = "SRV0002.classroom.intranet"
 
New-CMBoundaryGroup -Name "Training Lab" -DefaultSiteCode $SiteCode
Add-CMBoundaryToGroup -BoundaryGroupName "Training Lab" -BoundaryName "Training Lab Boundary"
$boundarygroup = gwmi -Namespace ("root\sms\site_$SiteCode") -query ('select * from SMS_BoundaryGroup where Name="Training Lab"')
$Flag = 0 #0=fast, 1=slow
$NALPath = "[""Display=\\" +  $ServerName + "\""]MSWNET:[""SMS_SITE=$SiteCode""]\\" + $ServerName + "\"

if ($boundarygroup -ne $null) { $boundarygroup.AddSiteSystem($NALPath, $Flag) }
