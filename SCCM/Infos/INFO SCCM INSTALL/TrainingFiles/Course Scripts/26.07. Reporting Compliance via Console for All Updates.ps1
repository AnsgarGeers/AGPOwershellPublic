Invoke-CMSoftwareUpdateSummarization
Start-Sleep 10
Get-CMSoftwareUpdate -Name "*KB3173424*" -fast | select LocalizedDisplayName, NumMissing, NumNotApplicable, NumPresent, NumTotal, NumUnknown, PercentCompliant