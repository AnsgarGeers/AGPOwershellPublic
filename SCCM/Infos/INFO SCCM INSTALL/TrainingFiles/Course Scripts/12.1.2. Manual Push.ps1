$SiteCode = "001"

Install-CMClient -DeviceName "WKS0001" -SiteCode "$SiteCode"
Install-CMClient -DeviceName "WKS0002" -SiteCode "$SiteCode"
Install-CMClient -DeviceName "WKS0004" -SiteCode "$SiteCode"

#Get-CMDevice -name "WKS0001" | Install-CMClient -SiteCode "$SiteCode"
#Get-CMDevice -name "WKS0002" | Install-CMClient -SiteCode "$SiteCode"
#Get-CMDevice -name "WKS0004" | Install-CMClient -SiteCode "$SiteCode"
