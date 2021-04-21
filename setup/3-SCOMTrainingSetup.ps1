# requirements
$ParentPath = 'D:\Hyper-V\'
$sqlPath  = 'E:\Hyper-V\en_sql_server_2016_enterprise_with_service_pack_1_x64_dvd_9542382.iso'
$scomPath = 'E:\Hyper-V\mu_system_center_operations_manager_2019_x64_dvd_b3488f5c.iso'

$serverbasedisk = dir $ParentPath -recurse -filter 'Base17C-WS16-1607*'
$clientbasedisk = dir $ParentPath -recurse -filter 'Base17A-W10-1607*'


# init
$destFolder = 'E:\Hyper-V\'
$ExportPath = 'C:\Export\'
$adminPassword = 'Pa55w.rd'
$timezone = 'W. Europe Standard Time'

$switch = Get-VMSwitch | Select -first 1
if ($switch.count -lt 1) { throw 'No VMSwitch found!' }
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

# https://blogs.technet.microsoft.com/uktechnet/2016/06/08/setting-up-active-directory-via-powershell/
Add-DhcpServerInDC
Add-DhcpServerv4Scope -Name ‘default scope’ -StartRange 10.0.0.101 -EndRange 10.0.0.200 -SubnetMask 255.255.255.0
Set-DhcpServerv4OptionValue -DnsServer 10.0.0.10 -DnsDomain 'adatum.msft' -Router 10.0.0.1
Get-DhcpServerv4Lease -ScopeId 10.0.0.0
Remove-DnsServerForwarder   # remove all forwarders
# https://devblogs.microsoft.com/scripting/use-powershell-to-create-ipv4-scopes-on-your-dhcp-server/
# https://docs.microsoft.com/en-us/powershell/module/dhcpserver/set-dhcpserverv4optionvalue?view=win10-ps

# start SQL/SCOM VM, becomes member of domain automatically
Get-VM LON-SV1 | Start-VM
vmconnect.exe $env:COMPUTERNAME LON-SV1
# log on to LON-SV1

# init
diskperf -y

# Extract files from SCOM DVD to C:
D:\SCOM_2019.exe

# install AD Tools
Install-WindowsFeature RSAT-AD-Tools


# install SQL
Get-VM LON-SV1 | Get-VMDvdDrive | Set-VMDvdDrive -Path $sqlPath
taskmgr.exe
D:\Setup.exe /q /ACTION=Install /FEATURES=SQLEngine,FullText,RS /INSTANCENAME=MSSQLSERVER /SQLSVCACCOUNT="adatum\administrator" /SQLSVCPASSWORD="Pa55w.rd" /SQLSYSADMINACCOUNTS="adatum\domain admins" /AGTSVCACCOUNT="NT AUTHORITY\Network Service" /IACCEPTSQLSERVERLICENSETERMS
Get-VM LON-SV1 | Get-VMDvdDrive | Set-VMDvdDrive -Path $null

<#
/FEATURES=SQLEngine,FullText	Installs the Database Engine and full-text.
/FEATURES=SQL,Tools             Installs the complete Database Engine and all tools
/SQLSVCINSTANTFILEINIT="True"
/PID   Specifies the product key for the edition of SQL Server. If this parameter is not specified, Evaluation is used.
https://docs.microsoft.com/en-us/sql/database-engine/install-windows/install-sql-server-from-the-command-prompt?view=sql-server-2017#Feature
#>


Get-VM | where name -notmatch dc | Stop-VM
Get-VM | where name -match dc | Stop-VM

mkdir $ExportPath
Get-VM | Export-VM -Path $ExportPath

# dedup files
#dir $ExportPath, $ParentPath | group length | where count -gt 1
$dups = Get-ChildItem $ExportPath, $ParentPath -Recurse -Filter '*.vhd' | Sort-Object length -Descending | Select-Object length, name, directory, fullname | Out-GridView -OutputMode Multiple
$dups | foreach { Remove-Item $_.fullname }

#copy files to central storage

# niet nodig
break
Set-DnsClientServerAddress -InterfaceAlias Ethernet -ServerAddresses 10.0.0.10
Add-Domain adatum.msft
Restart-Computer

