$SiteCode = "001"
$servername = "SRV0002.classroom.intranet"

#Open Report
Invoke-CMReport -ReportPath "Software Updates - A Compliance/Compliance 4 - Updates by vendor month year" -SiteCode "$SiteCode" -SrsServerName "$servername"
