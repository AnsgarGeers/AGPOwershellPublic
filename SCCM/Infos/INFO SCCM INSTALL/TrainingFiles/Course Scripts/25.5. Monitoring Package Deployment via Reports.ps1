$SiteCode = "001"
$servername = "SRV0002.classroom.intranet"

#Open Report
Invoke-CMReport -ReportPath "Software Distribution - Package and Program Deployment Status/Status of a specified package and program deployment" -SiteCode "$SiteCode" -SrsServerName "$servername"
