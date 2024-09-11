function Test-AlertSystem {
    <#
    .SYNOPSIS
    Performs different tests to determine alert functionality from for example Azure Monitor or SCOM.
    #>

    param(
        [switch]$EventLogTest,
        [switch]$DiskSpaceTest,
        [switch]$ServiceTest,
        [switch]$CPUUsageTest,
        [switch]$MemoryUsageTest
    )

    $i = 0
    if ($EventLogTest)    { $i++; Test-AlertEventLog }
    if ($DiskSpaceTest)   { $i++; Test-AlertDiskSpace }
    if ($ServiceTest)     { $i++; Test-AlertService }
    if ($CPUUsageTest)    { $i++; Test-AlertCPUUsage }
    if ($MemoryUsageTest) { $i++; Test-AlertMemoryUsage }

    if ($i -eq 0) {
        Write-Warning "No tests selected. Use -EventLogTest, -DiskSpaceTest, -ServiceTest, -CPUUsageTest or -MemoryUsageTest."
    } else {
        Write-Verbose "$i tests started."
    }
}




function Stop-AlertSystemTests {
    param(
        [string]$JobName = 'CpuTestJob*',
        [string]$DiskFile = 'c:\testfile-save-to-delete.bin',
        [string]$ServiceName = 'spooler'
    )

    Get-Job -Name $JobName | Stop-Job
    Remove-Item $DiskFile
    Start-Service $ServiceName
}




function Test-AlertEventLog {
    <#
    .SYNOPSIS
    Test EventLog by writing a number of events to the specified log.
    #>

    param(
        [int]$Count = 100,
        [string]$LogName = 'System',
        [string]$Source = 'Test',
        [string]$Message = 'this is a test event',
        [string]$EntryType = 'Error',
        [int]$EventId = 1
    )

    New-EventLog -LogName $LogName -Source $Source -ErrorAction SilentlyContinue

    0..$Count | ForEach-Object {
        Write-EventLog -LogName $LogName -Source $Source -EntryType $EntryType -EventId $EventId -Message $Message
    }
}




function Test-AlertDiskSpace {
    <#
    .SYNOPSIS
    Test low disk space alert by creating a file with a specified size.
    #>

    param(
        [string]$filename = 'c:\testfile-save-to-delete.bin',

        [int]$SpareSpace = 250MB,

        [string]$DiskName = 'C:'
    )

    $Disk = Get-CimInstance win32_logicaldisk | Where-Object { $_.name -eq $DiskName }
    $Size = $Disk.freespace - $SpareSpace
    Write-Host ("Creating file {0} with size: {1:N0} GB" -f $filename, ($Size/1GB)) -ForegroundColor Cyan
    fsutil file createnew $filename $Size
}




function Test-AlertService {
    <#
    .SYNOPSIS
    Test service alert by stopping a specified service.
    #>

    [CmdletBinding()]
    param(
        # e.g. spooler, lmhosts = TCP/IP NetBIOS Helper
        [string]$ServiceName = 'spooler'
    )

    Write-Verbose "Stopping $ServiceName service"
    Stop-Service $ServiceName
}




function Test-AlertCPUUsage {
    <#
    .SYNOPSIS
    Test CPU usage by starting a number of jobs. Jobs should eventually finish. Jobs finish when closing PowerShell.
    #>

    [CmdletBinding()]
    param(
        [string]$CpuJobName = 'CpuTestJob'
    )

    $NumberOfCores = 0
    Get-CimInstance win32_processor | ForEach-Object { 
        $NumberOfCores += $_.NumberOfLogicalProcessors 
    }

    Write-Verbose "$NumberOfCores CPU cores found."
    0..$NumberOfCores | ForEach-Object { 
        Start-Job -Name "$CpuJobName$_" -ScriptBlock {
            $result = 1
            foreach ($number in 1..2147483647) {
                $result = $result * $number
            } 
        }
    }
}




function Test-AlertMemoryUsage {
    <#
    .SYNOPSIS
    Test memory usage by creating a large array. Memory usage might remain high until the script is finished.
    #>

    [CmdletBinding()]
    param(
        $size=10MB
    )

    $proc1 = Get-Process -Id $pid

    # Create a large array
    $largeArray = New-Object System.Collections.ArrayList

    # Fill the array with data
    0..$size | ForEach-Object {
        # Add a large string to the array
        $null = $largeArray.Add([System.String]::new('a' * 1024))
    }

    $proc2 = Get-Process -Id $pid
    Write-Verbose (" VM delta: {0:N0} GB" -f (($proc2.vm - $proc1.vm)/1GB))
    Write-Verbose (" PM delta: {0:N0} GB" -f (($proc2.pm - $proc1.pm)/1GB))
    Write-Verbose ("NPM delta: {0:N0} GB" -f (($proc2.npm- $proc1.npm)/1GB))
    Write-Verbose (" WS delta: {0:N0} GB" -f (($proc2.ws - $proc1.ws)/1GB))
}





<#



fucntion Test-SCOMAgent {

    [int]$EventlogCollectionThreshold = 16 # minutes

    # init
    Write-Host "Test-SCOMAgent: performs tests to determine agent functionality" -ForegroundColor Cyan

    $laatste = Get-EventLog 'Operations Manager' | Where-Object {
        $_.eventid -eq 6022 -and $_.source -eq 'health service script' 
    } | Select-Object -first 1 -expand timegenerated

    if ((Get-Date).subtract($laatste).totalminutes -gt $EventlogCollectionThreshold) { 
        Write-Warning "Event collection check was too long ago!"
    } else {
        "Event collection checked recently." 
    }

    # overzicht met uitgevoerde taken, to do: is het een monitor die zichzelf opruimt, agent heartbeat properties
    Write-Host "Inspect SCOM Console for alerts from this computer."
    "Resolve`tInterval`tManagement Pack`tAlert Title", "auto`t15 min`tWindows Server`tLogical Disk Free Space in MBytes is low", "auto`t 1 min`tWindows Server`tTCP/IP NetBIOS Service Stopped", "auto`t15 min`tCustom`tcpu usage" |
    ForEach-Object { 
        write-host "`t* $_" 
    }
}


leuke scom test: agent stoppen en wacht op ping van management server. of: doe agent discovery en kijk of rms een ping uitvoert


 SCOM MP
- werkt: stop scom config svc: System Center Management Configuration Service Stopped, werkt altijd op mgmt server, onbekend hoe vaak deze draait
- stop scom agent op niet-management server: werkt altijd, binnen 3 minuten
Windows OS MP
- werkt: Core Windows Services: TCPIP NetBIOS (lmhosts service). Deze zijn minder goed te testen: comp browser, dhcp client, dns client, LDM, Messenger (removed since 2008?), PnP, RPC, Server, Windows Event Log, Workstation (NetLogon dependant)
- disk vol laten lopen, "Logical Disk Free Space" monitor loopt slechts elke 15 min x 4 samples!!  
- nog doen: Memory belasten
SQL MP
- stop sql agent: stop-service sqlserveragent -PassThru
- tlog full: zie voorbeeldscriptje uit SQL training
- database offline: 1x per uur!
AD MP
- AD service stoppen, welke?
- CPU belasten: geen monitor voor, behalve op DCs?

Hardware
redundant voeding
redundant NIC
switch / switchport



# event ids: 2117 & 2110 (MS), 1201 & 1210 & 21024 (agent) 
get-eventlog "operations manager" | where { $_.eventid -eq 1201 } | select -first 20 timegenerated, message

# uitsluitend op server met IIS en WAS
Write-EventLog -LogName system -Source "WAS" -EventId 5010 -EntryType Warning -Message "SCOM test"
#>
