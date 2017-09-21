cd $PSScriptRoot;
$proc = (Start-Process -FilePath "msiexec.exe" -ArgumentList "/x {1078E406-F5BF-4129-A9CC-8C989A0222FF} /q" -Wait -PassThru);$proc.WaitForExit();$ExitCode = $proc.ExitCode