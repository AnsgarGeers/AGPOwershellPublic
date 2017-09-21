$SiteCode = "001"
$servername = "SRV0002.classroom.intranet"

#Open Report
Invoke-CMReport -ReportPath "Software Distribution - Content/Application content distribution status" -SiteCode "$SiteCode" -SrsServerName "$servername"
