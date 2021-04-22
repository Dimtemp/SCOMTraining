# Run this script from the host VM
# Set-ExecutionPolicy Bypass -Scope Process -Force

# init
$destinationFolder = 'C:\Hyper-V\'
$adminPassword = 'Pa55w.rd'
$timezone = 'W. Europe Standard Time'

# enable Tls12
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072

# Chocolatey  install
iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
choco feature enable -n allowGlobalConfirmation

# install Dimmo module, required for New-VMFromBaseDisk
Install-Module Dimmo -Force

# Git setup
choco install git
cd\
git clone https://github.com/Dimtemp/SCOMTraining/
git clone https://github.com/Azure/azure-devtestlab.git

# Hyper-V setup
cd \azure-devtestlab\samples\ClassroomLabs\Scripts\HyperV\
# Set-ExecutionPolicy bypass -force
.\SetupForNestedVirtualization.ps1   # No DHCP?!?!?!? Provided by LON-DC1

# download and install AzCopy
Invoke-WebRequest -Uri 'https://aka.ms/downloadazcopy-v10-windows' -OutFile AzCopy.zip -UseBasicParsing
Expand-Archive ./AzCopy.zip
Get-ChildItem ./AzCopy/*/azcopy.exe | Move-Item -Destination $env:windir

# copy files from storage account using AzCopy
mkdir $destinationFolder
AzCopy.exe copy $blobSas $destinationFolder   # blobsas!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

# required files:
# Base17C-WS16-1607
# Base17A-W10-1607
# en_sql_server_2016_enterprise_with_service_pack_1_x64_dvd_9542382.iso
# mu_system_center_operations_manager_2019_x64_dvd_b3488f5c.iso

# requirements
$sqlPath  = Join-Path $destinationFolder 'en_sql_server_2016_enterprise_with_service_pack_1_x64_dvd_9542382.iso'
$scomPath = Join-Path $destinationFolder 'mu_system_center_operations_manager_2019_x64_dvd_b3488f5c.iso'

$serverbasedisk = Get-ChildItem $destinationFolder -recurse -filter 'Base17C-WS16-1607*'
$clientbasedisk = Get-ChildItem $destinationFolder -recurse -filter 'Base17A-W10-1607*'


$switch = Get-VMSwitch | Select -first 1
if ($switch.count -lt 1) { throw 'No VMSwitch found!' }

# create client
New-VMFromBaseDisk -VMName LON-W10 -BaseDisk $clientbasedisk.fullname -VirtualSwitchName $switch.name -DestinationFolder $destFolder

# create servers
'LON-DC1', 'LON-SV1', 'LON-SV2' | foreach {
    New-VMFromBaseDisk -VMName $_ -BaseDisk $serverbasedisk.fullname -VirtualSwitchName $switch.name -DestinationFolder $destFolder -CpuCount 2 -MemoryStartupBytes 2GB
}
Get-VM LON-SV1 | Set-VMProcessor -Count 4
Get-VM LON-SV1 | Set-VMMemory -StartupBytes 8GB
Get-VM LON-SV1 | Get-VMDvdDrive | Set-VMDvdDrive -Path $sqlPath
# Get-VM LON-SV1 | Get-VMDvdDrive | Set-VMDvdDrive -Path $scomPath

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
# Start-VM LON-SV1
# vmconnect.exe $env:COMPUTERNAME LON-SV1
# Get-VM LON-SV1 | Get-VMDvdDrive | Set-VMDvdDrive -Path $null
