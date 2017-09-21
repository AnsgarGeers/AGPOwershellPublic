$SiteCode = "001"
$servername = "SRV0002.classroom.intranet"

#Open Report
Invoke-CMReport -ReportPath "Software Metering/Users that have run a specific metered software program" -SiteCode "$SiteCode" -SrsServerName "$servername"
