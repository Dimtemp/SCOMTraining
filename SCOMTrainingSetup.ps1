$destFolder = 'E:\Hyper-V\'
$sqlPath  = 'E:\Hyper-V\en_sql_server_2016_enterprise_with_service_pack_1_x64_dvd_9542382.iso'
$scomPath = 'E:\Hyper-V\mu_system_center_operations_manager_2019_x64_dvd_b3488f5c.iso'
$adminPassword = 'Pa55w.rd'
$timezone = 'W. Europe Standard Time'

$serverbasedisk = dir d:\ -recurse -filter 'Base17C-WS16-1607*'
$clientbasedisk = dir d:\ -recurse -filter 'Base17A-W10-1607*'
$switch = Get-VMSwitch | Select -first 1
Install-Module Dimmo   # tbv New-VMFromBaseDisk


# create client
New-VMFromBaseDisk -VMName LON-W10 -BaseDisk $clientbasedisk.fullname -VirtualSwitchName $switch.name -DestinationFolder $destFolder

# create servers
'LON-DC1', 'LON-SV1', 'LON-SV2' | foreach {
    New-VMFromBaseDisk -VMName $_ -BaseDisk $serverbasedisk.fullname -VirtualSwitchName $switch.name -DestinationFolder $destFolder -CpuCount 2 -MemoryStartupBytes 2GB
}
Get-VM LON-SV1 | Set-VMProcessor -Count 4
Get-VM LON-SV1 | Set-VMMemory -StartupBytes 8GB
Get-VM LON-SV1 | Get-VMDvdDrive | Set-VMDvdDrive -Path $scomPath

# Create unattended files
Get-VM | foreach {
    if ($_.name -match 'DC') {
        $unattend = New-UnattendXML -ComputerName $_.Name -AdminPassword $adminPassword -Timezone $timezone
    } else {
        $unattend = New-UnattendXML -ComputerName $_.Name -AdminPassword $adminPassword -Timezone $timezone -DomainName 'adatum.msft' -DomainAccount 'Administrator' -DomainPassword $adminPassword
    }

    # mount VHD and write unattend.xml
    $VHDFromVM = $_.HardDrives.Path
    Write-Verbose "Writing unattended file to $VHDFromVM"
    $DriveLetter = (Mount-VHD -Path $VHDFromVM -Passthru | Get-Disk | Get-Partition | Where-Object Size -gt 1GB).DriveLetter
    $unattend | Out-File ($DriveLetter + ':\unattend.xml') -Encoding utf8
    $unattend | Out-File ($DriveLetter + ':\unattend-original.xml') -Encoding utf8   # debug output
    Dismount-VHD $VHDFromVM
}


# start DC
Start-VM LON-DC1

break

# run the code below from the DC1
New-NetIPAddress -InterfaceAlias Ethernet -IPAddress 10.0.0.10 -AddressFamily IPv4 -PrefixLength 24 -DefaultGateway 10.0.0.1

# install ADDS + DHCP op DC1
$adminPassword = 'Pa55w.rd'
Install-WindowsFeature AD-Domain-Services, DHCP -IncludeManagementTools -IncludeAllSubFeature
Install-ADDSForest -DomainName 'adatum.msft' -SafeModeAdministratorPassword (ConvertTo-SecureString $adminPassword -AsPlainText -Force)
# DC restarts automatically

Add-DhcpServerInDC
Add-DhcpServerv4Scope -Name ‘default scope’ -StartRange 10.0.0.101 -EndRange 10.0.0.200 -SubnetMask 255.255.255.0
Set-DhcpServerv4OptionValue -DnsServer 10.0.0.10 -DnsDomain 'adatum.msft' -Router 10.0.0.1

# start SQL/SCOM VM, becomes member of domain automatically
Get-VM LON-SV1 | Start-VM

# log on to LON-SV1

# install AD Tools
Install-WindowsFeature RSAT-AD-Tools

# Extract files from SCOM DVD to C:
D:\SCOM_2019.exe

# install SQL
Get-VM LON-SV1 | Get-VMDvdDrive | Set-VMDvdDrive -Path $sqlPath
d:\setup.exe /q /ACTION=Install /FEATURES=SQLEngine,FullText,RS /INSTANCENAME=MSSQLSERVER /SQLSVCACCOUNT="adatum\administrator" /SQLSVCPASSWORD="Pa55w.rd" /SQLSYSADMINACCOUNTS="adatum\domain admins" /AGTSVCACCOUNT="NT AUTHORITY\Network Service" /IACCEPTSQLSERVERLICENSETERMS
Get-VM LON-SV1 | Get-VMDvdDrive | Set-VMDvdDrive -Path $sqlPath

<#
/FEATURES=SQLEngine,FullText	Installs the Database Engine and full-text.
/FEATURES=SQL,Tools             Installs the complete Database Engine and all tools
/SQLSVCINSTANTFILEINIT="True"
/PID   Specifies the product key for the edition of SQL Server. If this parameter is not specified, Evaluation is used.
#>




Get-VM | where name -notmatch dc | Stop-VM
Get-VM | where name -match dc | Stop-VM

Export-VM



#copy files to central storage

# niet nodig
break
Set-DnsClientServerAddress -InterfaceAlias Ethernet -ServerAddresses 10.0.0.10
Add-Domain adatum.msft
Restart-Computer



# optionally start setup procedure

$scomSetup = 'C:\System Center Operations Manager 2019\Setup.exe'

if (Test-Path $scomSetup) { Write-Host "SCOM Setup files found." } else { throw "SCOM Setup files not found! Aborting." }

New-ADOrganizationalUnit SCOM
$pw = ConvertTo-SecureString 'Pa$$w0rd' -AsPlainText -Force
'MSAA', 'SDK', 'DRA', 'DWA' | foreach {
    New-ADUser -AccountPassword $pw -Name $_ -Path 'OU=SCOM,DC=Adatum,DC=msft' -Enabled $true
}
ADD-ADGroupMember -Identity 'Domain Admins' -Members 'MSAA', 'SDK'

Get-Service SQLSERVERAGENT | Set-Service -StartupType Automatic -Passthru | Start-Service   # tbv Reporting

Start-Job {
    Start-Sleep 3   # wait for processmonitor
    Add-WindowsFeature Web-Metabase   # NLB
    Start-Process -FilePath $scomSetup -ArgumentList '/silent /install /components:OMServer,OMConsole,OMReporting /ManagementGroupName:OM1 /SRSInstance:VAN-OM1 /SqlServerInstance:VAN-OM1 /DatabaseName:OperationsManager /DWSqlServerInstance:VAN-OM1 /DWDatabaseName:OperationsManagerDW /ActionAccountUser:Adatum\MSAA /ActionAccountPassword:Pa$$w0rd /DASAccountUser:Adatum\SDK /DASAccountPassword:Pa$$w0rd /DatareaderUser:Adatum\DRA /DatareaderPassword:Pa$$w0rd /DataWriterUser:Adatum\DWA /DataWriterPassword:Pa$$w0rd /EnableErrorReporting:Always /SendODRReports:1 /SendCEIPReports:0 /UseMicrosoftUpdate:1 /AcceptEndUserLicenseAgreement:1'
}

$start = Get-Date
$p1 = gps
Do {
  Sleep 1
  $p2 = gps
  Compare $p1 $p2 -Property id -passthru | % {
    $msg = "{0} {1,5} pid {2}  {3}" -f ((Get-Date)-$start).ToString(), $_.id, $_.name, $_.path
    if ($_.sideIndicator -eq "=>") { Write-Host $msg -fore green  }
    if ($_.sideIndicator -eq "<=") { Write-Host $msg -fore yellow }
  }
  $p1 = $p2
} until ( $p2 | where { $_.name -match 'monitoringhost' } )

Write-Host -fore green 'health service started!'


