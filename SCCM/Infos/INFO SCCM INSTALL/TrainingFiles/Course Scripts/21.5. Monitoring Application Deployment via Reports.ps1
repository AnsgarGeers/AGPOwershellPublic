$SiteCode = "001"
$servername = "SRV0002.classroom.intranet"

#Open Report
Invoke-CMReport -ReportPath "Software Distribution - Application Monitoring/Application compliance" -SiteCode "$SiteCode" -SrsServerName "$servername"
