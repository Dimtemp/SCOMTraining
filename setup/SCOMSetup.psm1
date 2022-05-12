<#
Run these commands in order to setup a SCOM environment. Only run the last file if you want to run an unattended SCOM setup. Don't run the last file if students need to run SCOM setup themselves.

TO DO
- setup VMs + SCOM on hyper-v on local PC
- upload VHD files to Azure storage account
- mount in Azure VM
#>


###################################################################################################
#
# Internal functions used in this script.
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



function SCOMSetupFilesInAzurePhase1 {
    param(
        $resourceGroupName = 'SCOMTraining',
        $location = 'westeurope',   # centralindia   eastus2
        $containerName = 'files',
        $sourceFilesPath = 'Q:\Images\SC2019'
    )

    Write-Progress -Activity $activity -Status 'Checking prerequisites'
    $sourceFiles = 'Q:\Images\Parent\Base17A-W10-1607.vhd', 'Q:\Images\Parent\Base17C-WS16-1607.vhd', 'Q:\Software\Microsoft\SQL\en_sql_server_2016_enterprise_with_service_pack_1_x64_dvd_9542382.iso', 'Q:\Software\Microsoft\System Center 2019\mu_system_center_operations_manager_2019_x64_dvd_b3488f5c.iso'
    $activity = 'Setting up SCOM training in Azure'


    # check input files
    $sourceFiles | foreach-object { if (!(Test-Path $_)) { Throw "Source file does not exist! Terminating... $_" } }
    if (!(Test-Path $sourceFilesPath)) { Throw "Source file does not exist! Terminating... $_" }


    # check for AzCopy existence
    if (!(Get-Command AzCopy.exe)) { throw "AzCopy does not exist! Terminating." }


    # check for Azure PowerShell modules
    if (!(Get-Module Az.Resources -ListAvailable)) { throw "Az.Resources module not installed. Terminating" }
    if (!(Get-Module Az.Storage -ListAvailable)) { throw "Az.Storage module not installed. Terminating" }

    # create resource group
    # already exists?
    New-AzResourceGroup -Name $resourceGroupName -Location $location -ErrorAction Stop


    # create storage account
    $sa = Get-AzStorageAccount -ResourceGroupName $resourceGroupName
    if ($null -eq $sa) {
        $sa = New-AzStorageAccount -ResourceGroupName $resourceGroupName -Name "stor$(Get-Random)" -SkuName Standard_LRS -Location 'westeurope' -Kind StorageV2
    }

    New-AzStorageContainer -Context $sa.Context -Name $containerName -Permission Container

    # generate SAS
    $StartTime = Get-Date
    $ExpiryTime = $startTime.AddDays(365)
    $blobSas = New-AzStorageContainerSASToken -Name $containerName -Permission w -StartTime $StartTime -ExpiryTime $ExpiryTime -context $sa.Context -Protocol HttpsOnly
    $blobSas = $sa.Context.BlobEndPoint + $containerName + $blobSas
    $blobSas

    # upload files to storage account
    Write-Progress -Activity $activity -Status "Copying $sourceFilesPath"
    AzCopy copy $sourceFilesPath $blobSas --recursive  # --overwrite ifSourceNewer

    Write-Progress -Activity $activity -Status "Copying $($sourceFiles.tostring())"
    $sourceFiles | Foreach {
        AzCopy copy $_ $blobSas   # --overwrite ifSourceNewer
    }



    Write-Progress -Activity $activity -Completed
}




function AzVMSCOMHostPhase2 {

    param(
        $resourceGroupName = 'SCOMTraining',
        $location = 'westeurope',   # centralindia   eastus2
        $vmsize = 'Standard_D4s_v3',  # b-sizes mogen niet wegens gebrek aan neste virtualization
        $Password = 'Pa55w.rd1234',
        $students = 'student1b' #, 'student2'    
    )

    # check for Azure PowerShell modules
    if (!(Get-Module Az.Resources -ListAvailable)) { throw "Az.Resources module not installed. Terminating" }
    if (!(Get-Module Az.Compute -ListAvailable)) { throw "Az.Compute module not installed. Terminating" }

    $secStringPassword = ConvertTo-SecureString $Password -AsPlainText -Force

    # create VM in Azure for each student
    $students | Foreach-Object {
        Write-Progress -Activity $activity -Status "Creating VM $_"
        # create credential object
        [pscredential]$cred = New-Object System.Management.Automation.PSCredential ($_, $secStringPassword)
        
        # extensions!!! auto shut down, perform setup
        # -AsJob
        $AzVMProps = @{
            ResourceGroupName = $_
            Name = $_
            Location = $location
            Size = $vmsize
            # AllocationMethod = Static is dit reden dat public ip niet aanwezig was? Blijkbaar niet.
            Credential = $cred
            Image = 'Win2016Datacenter'
        }
        New-AzVM @AzVMProps
    }
}




function AzureHostVMSetupPhase3 {

    # or CreateSCOMHostServer
    # Run this script from the host VM
    # Set-ExecutionPolicy Bypass -Scope Process -Force

    # init
    $destinationFolder = 'C:\Hyper-V\'
    $adminPassword = 'Pa55w.rd'
    $timezone = 'W. Europe Standard Time'



    # enable Tls12
    [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072

    # Chocolatey  install
    Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
    choco.exe feature enable -n allowGlobalConfirmation

    # install Dimmo module, required for New-VMFromBaseDisk
    Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force
    Install-Module Dimmo -Force

    # Git setup, not required anymore? Include this script in PowerShell Gallery?
    choco.exe install git
    #cd $env:ProgramFiles\Git\cmd\   # git not in path after install
    #git.exe clone https://github.com/Dimtemp/SCOMTraining/
    #cd\

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
    # todo: check if virtualiation extensions are present. How?
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
    throw "sas not implemented yet"
    $blobSas = 'https://scomtraining.blob.core.windows.net/files?sp=rl&s......' # todo: retrieve SAS!!!
    AzCopy.exe copy $blobSas $destinationFolder --recursive

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
    Get-VM | ForEach-Object {

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
    # Start-VM LON-DC1

    # start SQL/SCOM VM, becomes member of domain automatically
    # Start-VM LON-SV1
    # vmconnect.exe $env:COMPUTERNAME LON-SV1
    # Get-VM LON-SV1 | Get-VMDvdDrive | Set-VMDvdDrive -Path $null

}




function DCVMSetupPhase4 {
    # run this script from the domain controller

    # init
    $domainName = 'adatum.msft'
    $adminPassword = 'Pa55w.rd'

    # set static IP
    New-NetIPAddress -InterfaceAlias Ethernet -IPAddress 10.0.0.10 -AddressFamily IPv4 -PrefixLength 24 -DefaultGateway 10.0.0.1

    # install ADDS + DHCP
    Install-WindowsFeature AD-Domain-Services, DHCP -IncludeManagementTools -IncludeAllSubFeature
    Install-ADDSForest -DomainName $domainName -SafeModeAdministratorPassword (ConvertTo-SecureString $adminPassword -AsPlainText -Force)
    # DC restarts automatically

    # https://blogs.technet.microsoft.com/uktechnet/2016/06/08/setting-up-active-directory-via-powershell/
    Add-DhcpServerInDC
    Add-DhcpServerv4Scope -Name 'default scope' -StartRange 10.0.0.101 -EndRange 10.0.0.200 -SubnetMask 255.255.255.0
    Set-DhcpServerv4OptionValue -DnsServer 10.0.0.10 -DnsDomain 'adatum.msft' -Router 10.0.0.1
    Get-DhcpServerv4Lease -ScopeId 10.0.0.0
    Remove-DnsServerForwarder   # remove all forwarders
    # https://devblogs.microsoft.com/scripting/use-powershell-to-create-ipv4-scopes-on-your-dhcp-server/
    # https://docs.microsoft.com/en-us/powershell/module/dhcpserver/set-dhcpserverv4optionvalue?view=win10-ps
}




Function SCOMVMSetupPhase5 {
    # run this script from the management server VM

    # run taskmgr and enable disk stats
    taskmgr.exe
    diskperf -y

    # Extract files from SCOM DVD
    D:\SCOM_2019.exe

    # install AD Tools
    Install-WindowsFeature RSAT-AD-Tools

    # install SQL
    D:\Setup.exe /q /ACTION=Install /FEATURES=SQLEngine,FullText,RS /INSTANCENAME=MSSQLSERVER /SQLSVCACCOUNT="adatum\administrator" /SQLSVCPASSWORD="Pa55w.rd" /SQLSYSADMINACCOUNTS="adatum\domain admins" /AGTSVCACCOUNT="NT AUTHORITY\Network Service" /IACCEPTSQLSERVERLICENSETERMS

    <#
    /FEATURES=SQLEngine,FullText	Installs the Database Engine and full-text.
    /FEATURES=SQL,Tools             Installs the complete Database Engine and all tools
    /SQLSVCINSTANTFILEINIT="True"
    /PID   Specifies the product key for the edition of SQL Server. If this parameter is not specified, Evaluation is used.
    https://docs.microsoft.com/en-us/sql/database-engine/install-windows/install-sql-server-from-the-command-prompt?view=sql-server-2017#Feature
    #>


    # niet nodig
    # Set-DnsClientServerAddress -InterfaceAlias Ethernet -ServerAddresses 10.0.0.10
    # Add-Domain adatum.msft
    # Restart-Computer
}



function MgmtserverSetupPhase6 {
    param(
        [string]$password = (ConvertTo-SecureString 'Pa55w.rd' -AsPlainText -Force)
    )

    #init
    $ADAccounts = 'MSAA', 'SDK', 'DRA', 'DWA'

    if (Test-Path $scomSetup) {
        Write-Host "SCOM Setup files found."
    } else {
        throw "SCOM Setup files not found! Aborting."
    }


    # check report viewer!
    $ReportViewerFiles = Get-ChildItem C:\Windows\Microsoft.NET\assembly\GAC_MSIL -Recurse -Filter *ReportViewer*
    if ($ReportViewerFiles.Count -eq 0) { Throw "ReportViewer not found! Please install." }


    # prepare AD
    New-ADOrganizationalUnit 'SCOM'
    $ADAccounts | foreach-object {
        New-ADUser -AccountPassword $pw -Name $_ -Path 'OU=SCOM,DC=Adatum,DC=msft' -Enabled $true
    }
    ADD-ADGroupMember -Identity 'Domain Admins' -Members 'MSAA', 'SDK'

    Get-Service SQLSERVERAGENT | Set-Service -StartupType Automatic -Passthru | Start-Service   # tbv Reporting

}


function MgmtserverSetupPhase7 {
    <#
    .SYNOPSIS
    This command performs a SCOM setup.
    #>

    param(
        [string]$scomSetup = 'C:\System Center Operations Manager 2019\Setup.exe',
        [string]$password = 'Pa55w.rd',
        [switch]$NoMonitoring
    )

    Start-Job {
        # to do: is start job neccesary? Setup is launched in separate process
        Start-Sleep 3   # wait for processmonitor
        Add-WindowsFeature Web-Metabase   # NLB
        Start-Process -FilePath $using:scomSetup -ArgumentList " /install /components:OMServer,OMConsole,OMReporting /ManagementGroupName:OM1 /SRSInstance:LON-SV1 /SqlServerInstance:LON-SV1 /DatabaseName:OperationsManager /DWSqlServerInstance:LON-SV1 /DWDatabaseName:OperationsManagerDW /ActionAccountUser:Adatum\MSAA /ActionAccountPassword:$using:password /DASAccountUser:Adatum\SDK /DASAccountPassword:$using:password /DatareaderUser:Adatum\DRA /DatareaderPassword:$using:password /DataWriterUser:Adatum\DWA /DataWriterPassword:$using:password /EnableErrorReporting:Always /SendODRReports:1 /SendCEIPReports:0 /UseMicrosoftUpdate:1 /AcceptEndUserLicenseAgreement:1"
        # /silent
        # passwords updated
        # using:
    }


    if ($NoMonitoring) {
        Write-Host 'Setup started...'
    } else {
        ProcessMonitor
    }
}




function ProcessMonitor {
    <#
    .SYNOPSIS
    This command monitors processes.
    #>

    $start = Get-Date
    $p1 = Get-Process
    Do {
        Start-Sleep 1
        $p2 = gps
        Compare-Object $p1 $p2 -Property id -passthru | % {
            $msg = "{0} {1,5} pid {2}  {3}" -f ((Get-Date)-$start).ToString(), $_.id, $_.name, $_.path
            if ($_.sideIndicator -eq "=>") { Write-Host $msg -fore green  }
            if ($_.sideIndicator -eq "<=") { Write-Host $msg -fore yellow }
        }
        $p1 = $p2
    } until ( $p2 | Where-Object { $_.name -match 'monitoringhost' } )

    Write-Host -ForegroundColor Green 'health service started!'
}

# MgmtserverSetupPhase7 -NoMonitoring

