# Run this from Azure VM
Set-ExecutionPolicy Bypass -Scope Process -Force

# Chocolatey  install
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))

# Git setup
choco install git
cd\
git clone https://github.com/Dimtemp/SCOMTraining/blob/master/SCOMTrainingSetup.ps1
git clone https://github.com/Azure/azure-devtestlab.git

# Hyper-V setup
cd \azure-devtestlab\samples\ClassroomLabs\Scripts\HyperV\
Set-ExecutionPolicy bypass -force
.\SetupForNestedVirtualization.ps1   # No DHCP?!?!?!? Provided by LON-DC1
Invoke-WebRequest -Uri 'https://aka.ms/downloadazcopy-v10-windows' -OutFile AzCopy.zip -UseBasicParsing

#Expand Archive
Expand-Archive ./AzCopy.zip

# move AzCopy to windir
Get-ChildItem ./AzCopy/*/azcopy.exe | Move-Item -Destination $env:windir

# copy files from storage account using AzCopy
mkdir C:\Hyper-V
AzCopy.exe copy $blobSas C:\Hyper-V

#Base17C-WS16-1607*
#Base17A-W10-1607*
#E:\Hyper-V\en_sql_server_2016_enterprise_with_service_pack_1_x64_dvd_9542382.iso
#E:\Hyper-V\mu_system_center_operations_manager_2019_x64_dvd_b3488f5c.iso


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

# start SQL/SCOM VM, becomes member of domain automatically
Get-VM LON-SV1 | Start-VM
vmconnect.exe $env:COMPUTERNAME LON-SV1
Get-VM LON-SV1 | Get-VMDvdDrive | Set-VMDvdDrive -Path $sqlPath
Get-VM LON-SV1 | Get-VMDvdDrive | Set-VMDvdDrive -Path $null

