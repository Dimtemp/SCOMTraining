# Run this script from the host VM
# Set-ExecutionPolicy Bypass -Scope Process -Force

# init
$destinationFolder = 'C:\Hyper-V\'
$adminPassword = 'Pa55w.rd'
$timezone = 'W. Europe Standard Time'


###################################################################################################
#
# Functions used in this script.
#             

<#
.SYNOPSIS
Returns true is script is running with administrator privileges and false otherwise.
#>
function Get-RunningAsAdministrator {
    [CmdletBinding()]
    param()
    
    $isAdministrator = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")
    Write-Verbose "Running with Administrator privileges (t/f): $isAdministrator"
    return $isAdministrator
}

<#
.SYNOPSIS
Returns true is current machine is a Windows Server machine and false otherwise.
#>
function Get-RunningServerOperatingSystem {
    [CmdletBinding()]
    param()

    return ($null -ne $(Get-Module -ListAvailable -Name 'servermanager') )
}

<#
.SYNOPSIS
Enables Hyper-V role, including PowerShell cmdlets for Hyper-V and management tools.
#>
function Install-HypervAndTools {
    [CmdletBinding()]
    param()

    if (Get-RunningServerOperatingSystem) {
        Install-HypervAndToolsServer
    } else
    {
        Install-HypervAndToolsClient
    }
}

<#
.SYNOPSIS
Enables Hyper-V role for server, including PowerShell cmdlets for Hyper-V and management tools.
#>
function Install-HypervAndToolsServer {
    [CmdletBinding()]
    param()

    
    if ($null -eq $(Get-WindowsFeature -Name 'Hyper-V')) {
        Write-Error "This script only applies to machines that can run Hyper-V."
    }
    else {
        $roleInstallStatus = Install-WindowsFeature -Name Hyper-V -IncludeManagementTools
        if ($roleInstallStatus.RestartNeeded -eq 'Yes') {
            Write-Error "Restart required to finish installing the Hyper-V role .  Please restart and re-run this script."
        }  
    } 

    # Install PowerShell cmdlets
    $featureStatus = Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V-Management-PowerShell
    if ($featureStatus.RestartNeeded -eq $true) {
        Write-Error "Restart required to finish installing the Hyper-V PowerShell Module.  Please restart and re-run this script."
    }
}

<#
.SYNOPSIS
Enables Hyper-V role for client (Win10), including PowerShell cmdlets for Hyper-V and management tools.
#>
function Install-HypervAndToolsClient {
    [CmdletBinding()]
    param()

    
    if ($null -eq $(Get-WindowsOptionalFeature -Online -FeatureName 'Microsoft-Hyper-V-All')) {
        Write-Error "This script only applies to machines that can run Hyper-V."
    }
    else {
        $roleInstallStatus = Enable-WindowsOptionalFeature -Online -FeatureName 'Microsoft-Hyper-V-All'
        if ($roleInstallStatus.RestartNeeded) {
            Write-Error "Restart required to finish installing the Hyper-V role .  Please restart and re-run this script."
        }

        $featureEnableStatus = Get-WmiObject -Class Win32_OptionalFeature -Filter "name='Microsoft-Hyper-V-Hypervisor'"
        if ($featureEnableStatus.InstallState -ne 1) {
            Write-Error "This script only applies to machines that can run Hyper-V."
            goto(finally)
        }

    } 
}


###################################################################################################

# enable Tls12
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072

# Chocolatey  install
iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
choco feature enable -n allowGlobalConfirmation

# install Dimmo module, required for New-VMFromBaseDisk
Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force
Install-Module Dimmo -Force

# Git setup, not required anymore? Include this script in PowerShell Gallery?
choco install git
cd\
git clone https://github.com/Dimtemp/SCOMTraining/

# git clone https://github.com/Azure/azure-devtestlab.git
# Hyper-V setup
# always includes DHCP! Maybe do this different?
# cd \azure-devtestlab\samples\ClassroomLabs\Scripts\HyperV\
# Set-ExecutionPolicy bypass -force
# .\SetupForNestedVirtualization.ps1   # No DHCP?!?!?!? Provided by LON-DC1


# Check that script is being run with Administrator privilege.
Write-Output "Verify running as administrator."
if (-not (Get-RunningAsAdministrator)) { Write-Error "Please re-run this script as Administrator." }

# Install HyperV service and client tools
Write-Output "Installing Hyper-V, if needed."
Install-HypervAndTools

# Pin Hyper-V to the user's desktop.
Write-Output "Creating shortcut to Hyper-V Manager on desktop."
$Shortcut = (New-Object -ComObject WScript.Shell).CreateShortcut($(Join-Path "$env:UserProfile\Desktop" "Hyper-V Manager.lnk"))
$Shortcut.TargetPath = "$env:SystemRoot\System32\virtmgmt.msc"
$Shortcut.Save()



# download and install AzCopy
Invoke-WebRequest -Uri 'https://aka.ms/downloadazcopy-v10-windows' -OutFile AzCopy.zip -UseBasicParsing
Expand-Archive ./AzCopy.zip
Get-ChildItem ./AzCopy/*/azcopy.exe | Move-Item -Destination $env:windir

# copy files from storage account using AzCopy
mkdir $destinationFolder
$blobSas = 'https://scomtraining.blob.core.windows.net/files?sp=rl&st=2021-04-22T13:56:59Z&se=2022-04-22T21:56:59Z&spr=https&sv=2020-02-10&sr=c&sig=F93BqRUWDH9Fvn%2FmyinE%2Bqj6%2FfQjPfLWbz39vM8MlTA%3D'
AzCopy.exe copy $blobSas $destinationFolder --recursive   # blobsas!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

# required files:
# Base17C-WS16-1607
# Base17A-W10-1607
# en_sql_server_2016_enterprise_with_service_pack_1_x64_dvd_9542382.iso
# mu_system_center_operations_manager_2019_x64_dvd_b3488f5c.iso

# requirements
$sqlIso         = Get-ChildItem $destinationFolder -recurse -filter 'en_sql_server_2016_enterprise_with_service_pack_1_x64_dvd_9542382.iso'
$scomIso        = Get-ChildItem $destinationFolder -recurse -filter 'mu_system_center_operations_manager_2019_x64_dvd_b3488f5c.iso'
$serverbasedisk = Get-ChildItem $destinationFolder -recurse -filter 'Base17C-WS16-1607*'
$clientbasedisk = Get-ChildItem $destinationFolder -recurse -filter 'Base17A-W10-1607*'



if ((Get-VMSwitch).count -lt 1) { New-VMSwitch -Name 'Switch1' -SwitchType Internal }
$switch = Get-VMSwitch | Select-Object -first 1


# create client
New-VMFromBaseDisk -VMName LON-W10 -BaseDisk $clientbasedisk.fullname -VirtualSwitchName $switch.name -DestinationFolder $destinationFolder

# create servers
'LON-DC1', 'LON-SV1', 'LON-SV2' | ForEach-Object {
    New-VMFromBaseDisk -VMName $_ -BaseDisk $serverbasedisk.fullname -VirtualSwitchName $switch.name -DestinationFolder $destinationFolder -CpuCount 2 -MemoryStartupBytes 2GB
}
Get-VM LON-SV1 | Set-VMProcessor -Count 4
Get-VM LON-SV1 | Set-VMMemory -StartupBytes 8GB
Get-VM LON-SV1 | Get-VMDvdDrive | Set-VMDvdDrive -Path $sqlIso.FullName
# Get-VM LON-SV1 | Get-VMDvdDrive | Set-VMDvdDrive -Path $scomPath

# Create unattended files
Get-VM | foreach {

    Write-Host "Processing $($_.Name)"
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

