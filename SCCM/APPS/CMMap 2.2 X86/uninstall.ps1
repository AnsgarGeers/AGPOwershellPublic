cd $PSScriptRoot;
$proc = (Start-Process -FilePath "msiexec.exe" -ArgumentList "/x {FFA5F1F2-8A28-45FA-BFAA-622BD2C7574A} /qb! " -PassThru);$proc.WaitForExit();$ExitCode = $proc.ExitCode