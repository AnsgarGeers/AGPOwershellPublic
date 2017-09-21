<#  
.SYNOPSIS  
    Dieses Skript liest aus dem Active Directory alle Computer ein und Updatet die VAMT Datenbank.
    This Script reads all Computers from Active Directory and update the Vamt Database   
.DESCRIPTION  
    Dieses SKript benutzt das VAMT Powershell Modul
    This script uses VAMT Powershell Modul.  
 
.NOTES  
    File Name  : VAMT_DISCOVER_CLIENTS_NETWORK.ps1  
    Author     : Ansgar Geers  
    Requires   : PowerShell Version 3.0 32Bit
                 VAMT Powershell Modul auf einem System mit installiertem VAMT   
                 VAMT Powershell Module on a System with installed VAMT 
.LINK  
     
.EXAMPLE  
    Eine neue Aufgabe in der Aufgabenplanung erstellen.
    Als Aktion muss die Powershell 32bit gestartet werden
    C:\Windows\SysWOW64\WindowsPowerShell\v1.0\powershell.exe
    mit den Argumenten -command "Pfad zum Skript\VAMT_DISCOVER_CLIENTS_NETWORK.ps1"
    mit hoechsten rechten / Benoetigt Recht zum Schreiben in die VAMT Datenbank /lesen auf CLients und aus dem Active Direcory

    Create a new Task in the Schedule Tasks
    For the correct Funktion this Skript need the Powershell 32Bit
    In the Action section
    Action:      C:\Windows\SysWOW64\WindowsPowerShell\v1.0\powershell.exe
    Arguments:   -command "Path to Script\VAMT_DISCOVER_CLIENTS_NETWORK.ps1"
  
#>  

#######################
##### Config Area #####

###### Variablen ######
#zum VAMT Powershell Modul
$PathtoVAMTMOD = "C:\Program Files (x86)\Windows Kits\8.1\Assessment and Deployment Kit\VAMT3\VAMT.psd1"

#Domaenennamen zur Abfrage der Computerkonten
$Domain = "XXX.XXX"

#DBConnection String (Pfad zur VAMT Datenbank)
# Auslesen aus der VAMT GUI => Ansicht => Preferences => Database Settings => Current Connection String
$DBCONSTRING = "Data Source=XXXXXXXXXX.XXX.XXX;Initial Catalog=VAMT;Integrated Security=True;MultipleActiveResultSets=True"

$LogDir  = "C:\LOGS"
$Logfile = "$LogDir" + "\" + ( get-date -f "yyyyMMddHHmmss" ) + "_VAMT Import Netzwerk.log"

###### /Variablen #####

####### Messages ######

# Meldung VAMT Modul nicht gefunden
# Message VAMT Module not Found
$MESS_ERR_VAMTMOD = "VAMT Powershell Modul nicht gefunden"

# Meldung Pfad zum VAMT Powerhsell Modul gefunden
# Message Path to the VAMT Powershell Module gefunden
$MESS_INF_VAMT = "Pfad zum VAMT Modul gefunden"

# Meldung Powershell laeuft nicht im 32bit Modus
# Message Powershell runs not in 32bit mode
$MESS_ERR_POW32BIT = "Powershell Sitzung laeuft nicht im 32bit Modus!"

# Meldung Prozessor Architektur ist 32 Bit
# Message Processor Architecture is 32bit 
$MESS_INF_ARCH = "Architektur ist 32Bit"

# Meldung VAMT CMDLETS koennen nicht im 64Bit Modus laufen
# Message VAMT CMDLETS can not run in 64Bit mode
$MESS_ERR_VAMT64Bit = "Das VAMT Powershell Modul und die cmdlets sind nicht 64Bit faehig!"

# Meldung Find-VAMT ABfrage gestartet
# Message FIND-VAMT startet
$MESS_INF_FINDVAMTSTART = "Abfrage Find-VamtManagedMachine gestartet fuer"

# Meldung Find-VAMT ABfrage beendet
# Message FIND-VAMT ends
$MESS_INF_FINDVAMTEND = "Abfrage Find-VamtManagedMachine beendet fuer"

# Meldung Active Direcory Modul geladen
# Message Active Directory Module loaded
$MESS_INF_ADMODUL = "Active-Direcory Powershell Modul geladen"

# Meldung Datenbank Update gestartet
# Message Databvase Update Startet
$MESS_INF_GETUPDATEVAMTSTART = "Update der Datenbank Informationen gestartet"

# Meldung Datenbank Update beendet
# Message Databvase Update ends
$MESS_INF_GETUPDATEVAMTEND = "Update der Datenbank Informationen beendet"
####### /Messages #####

# Meldung der Erreichbaren Computer
# Message pingable Computer
$MESS_INF_PING = "Anzahl der erreichbaren Computer: "

# Meldung nicht erreichbare COmputer
# Message not pingable COmputer
$MESS_ERR_PING = "Anzahl der nicht erreichbaren Computer: "

# Meldung deaktivierte COmputerkonten
# Message deactivated COmputeraccounts
$MESS_ERR_ACT = "Anzahl der deaktivierten Computer: "

# Meldung der Gefundenen COmputer im Active Directory
# Message of the foundes Computers in the Actzive Directory
$MESS_INF_AD = "Anzahl der gefundenene Computerkonten:"

# Zuruecksetzen der verwendeten Variablen

$Global:Deaktiviert = 0
$Global:Anzahl =0
$Global:Fehler = 0
$Global:Abgefragt = 0
$Global:Erreichbar = 0
$Global:COMP = $NULL
$Global:Control = 0

##### /Config Area ####
#######################


#########################
#Funktion-Definetion-Area

Function Load-ADModul
{
    $ADMODULE = get-module -ListAvailable | select-string ActiveDirectory
    $Global:ERR = $NULL
    IF ($ADMODule -ne $null)
    {
        import-module activedirectory
        $Global:ERR = $False
    }
    Else
    {
        $Global:ERR = $True

        Write-Host "Active Directory Powershell Modul ist nicht Verfuegbar!" -ForegroundColor red
        "Active Directory Powershell Modul ist nicht Verfuegbar!" | out-file -FilePath $Logfile -Append
        Write-Host "Ueber den Servermanager => Features => Remote-Server-Verwaltungstools" -ForegroundColor red
        "Ueber den Servermanager => Features => Remote-Server-Verwaltungstools" | out-file -FilePath $Logfile -Append
        Write-Host "Rollenverwaltungstools => ADDS und AD LDS Tools =>" -ForegroundColor red
        "Rollenverwaltungstools => ADDS und AD LDS Tools =>" |out-file -FilePath $Logfile -Append
        Write-Host "Active-Directory-Modul für Windows Powershell Nachinstallieren" -ForegroundColor red
        "Active-Directory-Modul für Windows Powershell Nachinstallieren" | out-file -FilePath $Logfile -Append
    }
}

function Test-Wmi
{
    param([Parameter(Mandatory=$true, ValueFromPipeline = $true)] [string[]]$ComputerName)
    process
    { 
    try {
            $ComputerName | foreach {$name=$_; Get-WmiObject -ComputerName $name -Class Win32_ComputerSystem -ErrorAction 'Stop' | out-null; 
            new-object psobject -property @{Test="$($myinvocation.mycommand.name)";Args="$name";Result=$true;Message=$null}}
            Write-Host "WMI Service erreichbar" -ForegroundColor Green
            ( get-date -f "dd.MM.yyyy HH:mm:ss" ) + " " + "WMI Service erreichbar" | out-file -FilePath $Logfile -Append
            $GLOBAL:WMIERGEBNIS = $TRUE
        }
    catch { new-object psobject -property @{Test="$($myinvocation.mycommand.name)";Args="$name";Result=$false;Message="$($_.ToString())"}
            Write-Host "WMI Service NICHT erreichbar" -ForegroundColor red
            ( get-date -f "dd.MM.yyyy HH:mm:ss" ) + " " + "WMI Service NICHT erreichbar" | out-file -FilePath $Logfile -Append 
            $GLOBAL:WMIERGEBNIS = $FALSE
            }
    }
} #Test-Wmi

Function Get-TimeStamp 
{
	( Get-Date -Format o | foreach {$_ -replace "\+.*$", ""} | foreach {$_ -replace "T", " "} | foreach {$_ -replace "\.", ","} | foreach {$_ -replace "-", "."} )
}#END Function Get-Timestamp

#END Funktion-Definetion-Area
#########################

#######################
######Main Area########

# Abfrage ob Powershell Sitzung 32bit ist
# Test 32Bit Modus
if($env:PROCESSOR_ARCHITECTURE -match '86')
{
    # Abfrage ob der Pfad zum Modul gefunden wird
    # Test path to VAMT Modul
    Write-host $MESS_INF_ARCH 
    ( get-date -f "dd.MM.yyyy HH:mm:ss" ) + " " + $MESS_INF_ARCH | out-file -FilePath $Logfile -Append
    If (Test-path $PathtoVAMTMOD)
    {
        Write-host $MESS_INF_VAMT -ForegroundColor Green | out-file -FilePath $Logfile -Append
        ( Get-TimeStamp ) + " " + $MESS_INF_VAMT | out-file -FilePath $Logfile -Append

        # Import VAMT Modul
        import-module $PathtoVAMTMOD

        # Test/Import ADModul
        Load-ADModul
        IF ($Global:ERR -match $False)
        {
            write-host -ForegroundColor green $MESS_INF_ADMODUL
            ( get-date -f "dd.MM.yyyy HH:mm:ss" ) + " " + $MESS_INF_ADMODUL | out-file -FilePath $Logfile -Append
            $Global:ERR -ne $Null

            #Reads all Computers from Lokal WIndows Domain
            get-adcomputer -Filter * -ResultPageSize  1024 | Foreach{$Global:Anzahl=$Global:Anzahl+1}
            $mess = $MESS_INF_AD + " " + $Anzahl 
            Write-host $mess -ForegroundColor Green
            ( get-date -f "dd.MM.yyyy HH:mm:ss" ) + " " + "$MESS_INF_AD $Anzahl" | out-file -FilePath $Logfile -Append
            Get-ADComputer -filter * -ResultPageSize 1024 | foreach-object{
				$Global:Abgefragt = $Global:Abgefragt+1
                Write-host " "
                ( get-date -f "dd.MM.yyyy HH:mm:ss" ) + " " | out-file -FilePath $Logfile -Append
                write-host -ForegroundColor green "Abfrage $Abgefragt von $Global:Anzahl"
				( get-date -f "dd.MM.yyyy HH:mm:ss" ) + " " + "Abfrage $Abgefragt von $Global:Anzahl"| out-file -FilePath $Logfile -Append
                IF($_.enabled -eq "True")
                {
                    $Global:COMP = $_.dnshostname
                    #Start-Sleep -Seconds 3

                    write-host -ForegroundColor green "$Global:COMP wird ueberprueft"
                    ( get-date -f "dd.MM.yyyy HH:mm:ss" ) + " " + "$Global:COMP wird ueberprueft" | out-file -FilePath $Logfile -Append

                    # Test Computer Alive (Ping)
                    $rtn = Test-Connection -CN $Global:COMP -Count 1 -Quiet
                    

                    IF($rtn -match 'True')
                    {
                        write-host -ForegroundColor green "$Global:COMP Verbindung (ping) besteht"
                        ( get-date -f "dd.MM.yyyy HH:mm:ss" ) + " " + "$Global:COMP Verbindung (Ping) besteht"| out-file -FilePath $Logfile -Append
                        Test-Wmi $Global:COMP

                        IF ($WMIERGEBNIS -match 'True')
                        {
                            $Global:Erreichbar = $Global:Erreichbar+1 
                            write-host -ForegroundColor green "$Global:COMP Verbindung (WMI) besteht"
                            ( get-date -f "dd.MM.yyyy HH:mm:ss" ) + " " + "$Global:COMP Verbindung (WMI) besteht"| out-file -FilePath $Logfile -Append

                            write-host -ForegroundColor green "Erreichbar: $Erreichbar von $Global:Anzahl"
                            ( get-date -f "dd.MM.yyyy HH:mm:ss" ) + " " + "Erreichbar: $Erreichbar von $Anzahl"| out-file -FilePath $Logfile -Append
                            # Abfrage Computer Netzwerk
                            # Read Computers from the Network
                            Write-host "$MESS_INF_FINDVAMTSTART $Global:COMP" -ForegroundColor Green
                            ( get-date -f "dd.MM.yyyy HH:mm:ss" ) + " " + "$MESS_INF_FINDVAMTSTART $Global:COMP"| out-file -FilePath $Logfile -Append

                            # Einlesen Computerinformationen
                            Find-VamtManagedMachine -QueryType Manual -QueryValue $Global:COMP -DbConnectionString $DBCONSTRING
                            Write-host "$MESS_INF_FINDVAMTEND $Global:COMP" -ForegroundColor Green
                            ( get-date -f "dd.MM.yyyy HH:mm:ss" ) + " " + "$MESS_INF_FINDVAMTEND $Global:COMP" | out-file -FilePath $Logfile -Append
                        }
                        ELSE
                        {
                           write-host -ForegroundColor RED "$Global:COMP Verbindung (WMI) nicht vorhanden"
                           ( get-date -f "dd.MM.yyyy HH:mm:ss" ) + " " + "$Global:COMP Verbindung (WMI) besteht"| out-file -FilePath $Logfile -Append
                           $Global:Fehler = $Global:Fehler+1
                            write-host -ForegroundColor green "Nicht Erreichbar: $Fehler von $Anzahl"
                        } 
                            
                    }
                    ELSE
                    {
                        $Global:Fehler = $Global:Fehler+1
                        write-host -ForegroundColor green "Nicht Erreichbar: $Fehler von $Anzahl"
                        ( get-date -f "dd.MM.yyyy HH:mm:ss" ) + " " + "Nicht Erreichbar: $Fehler von $Anzahl"| out-file -FilePath $Logfile -Append
                        Write-host -ForegroundColor red "$Global:COMP Nicht Erreichbar!"
                        ( get-date -f "dd.MM.yyyy HH:mm:ss" ) + " $Global:COMP Nicht Erreichbar!" | out-file -FilePath $Logfile -Append
                    }
                }
                ELSE
                {
                    $Global:Deaktiviert = $Global:Deaktiviert+1
                    write-host -ForegroundColor Yellow "Deaktiviert: $Global:Deaktiviert von $Anzahl"
                    ( get-date -f "dd.MM.yyyy HH:mm:ss" ) + " " + "Deaktiviert: $Global:Deaktiviert von $Anzahl"| out-file -FilePath $Logfile -Append
                    
                }
            }
            Write-host " "
            ( get-date -f "dd.MM.yyyy HH:mm:ss" ) + " " | out-file -FilePath $Logfile -Append
            Write-Host $MESS_INF_PING $Global:Erreichbar -ForegroundColor Green
            ( get-date -f "dd.MM.yyyy HH:mm:ss" ) + " " + "$MESS_INF_PING $Global:Erreichbar" | out-file -FilePath $Logfile -Append

            Write-host $MESS_ERR_PING $Global:Fehler -ForegroundColor Red
            ( get-date -f "dd.MM.yyyy HH:mm:ss" ) + " " + "$MESS_ERR_PING $Global:Fehler" | out-file -FilePath $Logfile -Append

            Write-host $MESS_ERR_ACT $Global:Deaktiviert -ForegroundColor Yellow
            ( get-date -f "dd.MM.yyyy HH:mm:ss" ) + " " + "$MESS_ERR_ACT $Global:Deaktiviert" | out-file -FilePath $Logfile -Append

            $Control = $Global:Erreichbar + $Global:Fehler + $Global:Deaktiviert
            Write-Host "Es wurden $control abgefragt von $Global:Anzahl" -ForegroundColor Green
            ( get-date -f "dd.MM.yyyy HH:mm:ss" ) + " Es wurden $control abgefragt von $Global:Anzahl" | out-file -FilePath $Logfile -Append

            Write-host " "
            ( get-date -f "dd.MM.yyyy HH:mm:ss" ) + " " | out-file -FilePath $Logfile -Append
            # Einlesen der VAMT Produkt(Computer) Datenbank und Aktualisieren der Daten vom Client
            Write-host $MESS_INF_GETUPDATEVAMTSTART -ForegroundColor Green
            ( get-date -f "dd.MM.yyyy HH:mm:ss" ) + " " + "$MESS_INF_GETUPDATEVAMTSTART" | out-file -FilePath $Logfile -Append
            get-vamtproduct -DbConnectionString $DBCONSTRING | update-vamtproduct -DbConnectionString $DBCONSTRING
            Write-host "$MESS_INF_GETUPDATEVAMTEND" -ForegroundColor Green
            ( get-date -f "dd.MM.yyyy HH:mm:ss" ) + " " + "$MESS_INF_GETUPDATEVAMTEND" | out-file -FilePath $Logfile -Append
        }
    }
    Else
    {
        # Fehlermeldung VAMT Modul
        # Failure Message VAMT Modul
        Write-host $MESS_ERR_VAMTMOD -ForegroundColor Red
        ( get-date -f "dd.MM.yyyy HH:mm:ss" ) + " " + $MESS_ERR_VAMTMOD | out-file -FilePath $Logfile -Append
        
    }
}
ELSE
{
    # Fehler Meldung 32 Bit Modus
    # Failure Message 32 Bit Mode
    Write-Host $MESS_ERR_POW32BIT -ForegroundColor Red
    ( get-date -f "dd.MM.yyyy HH:mm:ss" ) + " " + $MESS_ERR_VAMT64Bit | out-file -FilePath $Logfile -Append
    
} 
  
###### /Main Area #######
#########################
