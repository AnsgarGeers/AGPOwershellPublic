cd $PSScriptRoot;
$proc = (Start-Process -FilePath "msiexec.exe" -ArgumentList "/i `"CMMap.msi`" /qb! ALLUSERS=2" -Wait -PassThru);$proc.WaitForExit();$ExitCode = $proc.ExitCode
Exit($($ExitCode))
