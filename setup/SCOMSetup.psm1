<#
VirtualEnvironment module for deploying virtual labs.

Required:
- Parent VHD files.
- Source MOC files in extracted form.
- Manifest file.

Step 1: Write-VERepositoryFiles
            Creates a central repository in azure storage account once per image
Step 2: New-VEHost
            per student: create a host VM running Hyper-V (nested) in Azure
Step 3: Install-Module VirtualEnvironment; Import-VirtualEnvironment
            by students. Configures host VM, copy source files from repo, import and configure VMs
            Required: VirtualEnvironment module
#>



function VELog {
    param(
        [string]$msg
    )
    $msg = "{0}  {1}" -f (Get-Date), $msg
    Write-Host $msg -ForegroundColor Green
}




function Test-VEDeliveryDay {
    <#
    .SYNOPSIS
    Test whether a virtual environment should run today. Run this script several times per hour for best results.
    .NOTES
    To do: implement timezones!!! Now this only works for the current time zone.
    #>

    [cmdletbinding()]
    param(
        [Parameter(Mandatory=$True)]
        [string]$DateExpression
    )

    # init
    $d = Get-Date
    $r = 'NotActiveToday'

    if ($d.ToShortDateString() -match $DateExpression) {
        Write-Verbose 'today is a delivery day'
        $r = 'ActiveToday'
    }

    # object output
    $properties = @{
        'DateExpression' = $DateExpression;
        'Result'         = $r
    }
    $output = New-Object -TypeName PSObject -Property $properties
    Write-Output $output
}


function Invoke-VEVMStartStop {
    <#
    .SYNOPSIS
    This function can start or stop VMs depending on a delivery day. It only starts VMs at 05:00 in the morning. It only stops VMs on the next cycle the next day.
    .NOTES
    To do: implement: auto shutdown checking on each VM
    #>

    [cmdletbinding(SupportsShouldProcess=$true)]
    param(
        # The expression to determine an active day. Can use regex.
        [Parameter(Mandatory=$True)]
        [string]$DateExpression,

        # Hour of the day that maintenance ends. Only at this moment VMs are started.
        [string]$MaintenanceHourEnd   = '07',

        # Interval between cycles in seconds.
        [int]$SleepInterval=180,

        # Ignores hour of the day. Runs every moment of the day.
        [switch]$Force,

        # Starts the operation and returns immediately, before the operation is completed.
        [switch]$NoWait
    )

    # init
    $VMs = Get-AzVM | Out-GridView -OutputMode Multiple -Title "Please select VMs to monitor under this condition: $DateExpression"

    # loop
    do {
        $r = Test-VEDeliveryDay -DateExpression $DateExpression
        if ($r.Result -eq 'ActiveToday') {
            # active today
            $h = (Get-Date).ToShortTimeString().split(':')[0]
            VELog "Active today, current hour: $h, Date Expression: $DateExpression"

            # start any VMs at $MaintenanceHourEnd
            if ($h -eq $MaintenanceHourEnd -or $Force) {
                Write-Debug "Current hour: $h, End of maintenance hour: $MaintenanceHourEnd"
                foreach ($CurrentVM in $VMs) {
                    if ($PSCmdlet.ShouldProcess($CurrentVM.Name, 'Start-AzVM')) {
                        # PowerState can be 'VM deallocated', 'VM running', 'VM stopped', 'Info Not Available'
                        Get-AzVM -Name $CurrentVM.Name -ResourceGroupName $CurrentVM.ResourceGroupName -Status | Where-Object PowerState -ne 'VM running' | Start-AzVM
                    }
                }
            }
        } else {
            # not active today
            $h = (Get-Date).ToShortTimeString().split(':')[0]
            VELog "Not active today, current hour: $h, Date Expression: $DateExpression"

            # test if VM is not deallocated
            foreach ($CurrentVM in $VMs) {
                # do not use Get-AzVM with -ResourceGroupName AND -Name at the same time. This results in an PSVirtualMachineInstanceView, while we need PSVirtualMachineListStatus
                $VMNotDeallocated = Get-AzVM -ResourceGroupName $CurrentVM.ResourceGroupName -Status | Where-Object Name -eq $CurrentVM.Name
                if ($VMNotDeallocated | Where-Object PowerState -ne 'VM deallocated') {
                    VELog "VM not deallocated: $($VMNotDeallocated.Name)"
                    if ($PSCmdlet.ShouldProcess($CurrentVM.Name, 'Stop-AzVM')) {
                        VELog "Stopping VM: $($CurrentVM.Name)"
                        <#
                        Stop-AzVM
                        -Force: without asking for user confirmation
                        -NoWait: starts the operation and returns immediately
                        -SkipShutdown: request non-graceful VM shutdown when keeping the VM provisioned
                        -StayProvisioned: stops all the VMs ... but does not deallocate them
                        #>
                        $VMNotDeallocated | Stop-AzVM -Force
                    }
                } else {
                    VELog "VM $($VMNotDeallocated.Name) is already deallocated. Nothing to do."
                }
            }
        }
        Start-Sleep $SleepInterval
    } while (1)
}




function Write-VERepositoryFiles {
    <#
    .SYNOPSIS
    Takes a manifest file and uploads files to an Azure storage account. Optionally creates a storage account.
    #>
    [cmdletbinding()]param(

        [Parameter(Mandatory=$true)]
        [string]$ManifestFile,

        [string]$ResourceGroupName='VERepository',

        [string]$Location = 'westeurope',

        [ValidateSet('Standard_LRS','Standard_ZRS','Standard_GRS','Standard_RAGRS','Premium_LRS','Premium_ZRS','Standard_GZRS','Standard_RAGZRS')]
        [string]$SkuName = 'Standard_LRS',

        [string]$ContainerName = 'files'
    )


    # init
    $Start = Get-Date
    $ContainerName = $ContainerName.ToLower()
    $Activity = "Preparing $SkuName storage account in $Location"
    Write-Progress -Activity $Activity -CurrentOperation 'Initializing...'


    # Install AzCopy when not installed
    Install-AzCopy


    # test for manifest file existence
    if (-not (Test-Path $ManifestFile)) { throw "$ManifestFile does not exist!" }


    # read manifest
    $Manifest = Get-Content $ManifestFile | ConvertFrom-Json -ErrorAction Stop
    Write-Host "Preparing training: $($Manifest.Title)"


    # test for source path existence
    if (-not (Test-Path $Manifest.SourcePath)) { throw "Sourcepath does not exist!: $($Manifest.SourcePath)" }
    $SourcePathSize  = (Get-ChildItem -Path $Manifest.SourcePath -Recurse | Measure-Object -Sum Length).Sum


    # check for shared source files existence
    $SharedFilesSize = 0
    $Manifest | Select-Object -ExpandProperty SourceFiles -ErrorAction 0 | ForEach-Object {
        if (-not (Test-Path $_)) { throw "Sourcefile does not exist!: $_" }
        $SharedFilesSize += (Get-ChildItem -Path $_).Length
    }
    $totalSize = $SourcePathSize + $SharedFilesSize
    Write-Verbose ("Total size for environment: {0:N2} GB" -f ($totalSize/1GB))

    # determine total file size. This command uses write-host to inform user about total file size.
    $ResultFromGetVEManifestSourceFiles = Get-VEManifestSourceFiles -ManifestFile Q:\Images\20742B-Identity\20742-manifest.json

    # get, and optionally create storage account
    Write-Progress -Activity $Activity -CurrentOperation 'Retrieving storage account'
    $sa = Get-AzStorageAccount -ResourceGroupName $ResourceGroupName -ErrorAction SilentlyContinue
    if ($null -eq $sa) {
        Write-Progress -Activity $Activity -CurrentOperation 'Creating storage account'
        New-AzResourceGroup -Name $ResourceGroupName -Location $location -ErrorAction SilentlyContinue | Out-Null

        # improve: test for existence, max 23 chars?
        $saName = "$($ResourceGroupName.ToLower())$(Get-Random)".Replace('-','')
        if ($saName.Length -gt 24) { $saName = $saName.Substring(0,23) }
        Write-Verbose "Creating storage account with name $saName"
        $sa = New-AzStorageAccount -ResourceGroupName $ResourceGroupName -Name $saName -SkuName $SkuName -Location $location -Kind StorageV2
    }

    Write-Progress -Activity $Activity -CurrentOperation 'Creating storage account container'
    New-AzStorageContainer -Context $sa.Context -Permission Container -Name $ContainerName -ErrorAction SilentlyContinue | Out-Null
    Write-Verbose "Container $ContainerName created. At this moment you can deploy a host VM using the New-VEHost command."


    # generate SAS
    $HashArguments = @{
        Service = 'Blob'
        ResourceType = 'Service,Container,Object'
        Permission = 'racwdlup'
        #StartTime = (Get-Date)
        #ExpiryTime = (Get-Date).AddDays(365)
        Context = $sa.Context
        Protocol = 'HttpsOnly'
    }
    $Sas = New-AzStorageAccountSASToken @HashArguments -ErrorAction Stop
    # New-AzStorageContainerSASToken
    # https://docs.microsoft.com/en-us/rest/api/storageservices/create-account-sas

    $Sas = $sa.Context.BlobEndPoint + $ContainerName + $Sas
    Write-Verbose "SAS: $Sas"

    
    # upload files to storage account
    # copy shared source files
    $i = 0
    $Manifest.SourceFiles | ForEach-Object {
        $i++
        Write-Progress -Activity $Activity -CurrentOperation "Writing shared files $i of $($Manifest.SourceFiles.count): $_"
        Write-Verbose "Source: $_ Destination: $Sas"
    
        # test for existence not required
        #$blob = Get-AzStorageBlob -Blob $_ -Container $sSas -Context $sa.Context
        #if ($null -eq $blob) { AzCopy copy $_ $sSas --overwrite=false }
        #else { Write-Verbose "File already exists: $($_.value)" }
        AzCopy copy $_ $Sas --overwrite=false --log-level=WARNING
    }


    # copy source image, should contain manifest
    Write-Progress -Activity $Activity -CurrentOperation $SourcePath
    Write-Verbose "Writing image: $($Manifest.SourcePath) Destination: $Sas"
    AzCopy copy $Manifest.SourcePath $Sas --recursive --overwrite=false --log-level=WARNING


    # done
    Write-Verbose ("{0} Storage account created in Azure. Time taken: {1}" -f (Get-Date), (New-TimeSpan -Start $Start).ToString().Split('.'))
    Write-Progress -Activity $Activity -Completed
}




function New-VEHost {
    
    <#
    .SYNOPSIS
    This command creates a VM in Azure. It adds a script to the VM to install it as a Hyper-V host VM. It can be run during the AzCopy phase from Write-VERepositoryFiles.
    .NOTES
    To do: inform user when VM is ready. How?
    #>

    [cmdletbinding()]
    param(

        [Parameter(Mandatory=$true)]
        [ValidateLength(2,15)]
        [string]$VMName,

        [Parameter(Mandatory=$true)]
        [ValidateLength(1,20)]
        [string]$UserName,

        [Parameter(Mandatory=$true)]
        [string]$RDPFolder,

        [string]$VERepositoryResourceGroupName = 'VERepository',

        [string]$Password = 'Pa55w.rd1234',

        [string]$Location = 'westeurope',

        # Standard_D4_v3 heeft TEMP drive van 100 GB, maar TEMP overleeft geen deallocate! 
        # Get-AzVMSize -Location 'westeurope' | where NumberOfCores -le 4 | where MemoryInMB -gt 7000 | where name -match 'v3|v4' | sort MemoryInMB
        # nested virtualization is intel only, VMSize referencing AMD, e.g. D4a* cannot be used
        # Standard_D2_v4 geeft HDD ipv SSD :(
        # Standard B2ms doet WEL/NIET nested virtualization?
        # Update-AzDisk naar 
        [string]$VMSize = 'Standard_D4s_v3',  # deze werkte goed: Standard_D4s_v3

        # TO DO: not implemented?!?!?!?!?!??!?!?!?!?!??!?!?!??!
        [ValidateSet('Win10', 'Win2012R2Datacenter', 'Win2016Datacenter', 'Win2019Datacenter')]
        [string]$Image = 'Win2016Datacenter',

        # static not required because VM has a FQDN, RDP file connects to FQDN
        [ValidateSet('Dynamic', 'Static')]
        [string]$AllocationMethod = 'Dynamic'
    )

    # init
    $ResourceGroupName = $VMName
    $Start = Get-Date
    $Activity = "Creating VM in Azure, name: {0}, username: {1}, location: {2}, size {3}, image: {4}, ip: {5}" -f $VMName, $UserName, $Location, $VMSize, $Image, $AllocationMethod
    Write-Progress -Activity $Activity -CurrentOperation 'Initializing'
    # if ($null -eq $UserName) { $UserName = $VMName }

    # test RDP folder
    if (-not (Test-Path $RDPFolder)) { throw "RDP output folder does not exist: $RDPFolder" }

    # test storage account
    Write-Progress -Activity $Activity -CurrentOperation 'Retrieving storage account'
    $sa = Get-AzStorageAccount -ResourceGroupName $VERepositoryResourceGroupName
    if ($sa.count -ne 1) { throw "Required storage account not found! There must be 1 storage account in resource group $VERepositoryResourceGroupName" }

    # create credential object
    $cred = New-PSCredential -UserName $UserName -Password $Password

    # create VM
    $HashArguments = @{
        ResourceGroupName = $ResourceGroupName
        Name = $VMName
        Location = $location
        Size = $VMSize
        AllocationMethod = $AllocationMethod
        Credential = $cred
        Image = $Image
    }
    
    Write-Progress -Activity $Activity -CurrentOperation "Creating VM, name: $VMName, image: $Image, IP: $AllocationMethod"
    # Operation could not be completed as it results in exceeding approved Total Regional Cores quota. Additional details - Deployment Model: Resource Manager, Location: westeurope, Current Limit: 20, Current Usage: 20
    $vm = New-AzVM @HashArguments -ErrorAction Stop

    <#
    # nieuwe manier
    $VirtualMachine = New-AzVMConfig -VMName $VMName -VMSize $VMSize
    Set-AzVMOSDisk -VM $VirtualMachine -Name 'OsDisk' -VhdUri 'os.vhd' -Caching ReadWrite -StorageAccountType StandardSSD_LRS
    $VirtualMachine = Set-AzVMOperatingSystem -VM $VirtualMachine -Windows -ComputerName $VMName -Credential $cred
    # $VirtualMachine = Set-AzVMSourceImage -VM $VirtualMachine -PublisherName 'MicrosoftWindowsServer' -Offer 'WindowsServer' -Skus '2016-Datacenter-smalldisk' -Version 'latest'
    New-AzVM -VM $VirtualMachine -ResourceGroupName $ResourceGroupName -Location $Location 
    -AllocationMethod $AllocationMethod -ErrorAction Stop
    #>

    # create Tag in VM resource group
    Set-AzResourceGroup -Name $ResourceGroupName -Tag @{'DependsOn' = "$($sa.ResourceGroupName)/$($sa.StorageAccountName)" }  | Out-Null   # tag value is limited to 256 characters

    # Write sas to VM
    Write-Progress -Activity $Activity -CurrentOperation 'Writing SAS to VM'
    Write-VESasToAzVM -VMName $VMName -VMResourceGroupName $ResourceGroupName -StorageAccountResourceGroupName $sa.ResourceGroupName -StorageAccountName $sa.StorageAccountName | Out-Null

    <#
    What are the options to supply an OS image with Hyper-V included?

    Set-AzVMOSDisk -DiskSizeInGB x
    -StorageAccountType [Premium_LRS|StandardSSD_LRS|Standard_LRS]
    Set-AzVMOSDisk -Name vmnameOSdisk1245 -DiskSizeInGB 30 -StorageAccountType Premium_LRS -CreateOption 'fromImage'
    Set-AzVMSourceImage -PublisherName 'MicrosoftWindowsServer' -Offer "$WindowsServer" -Skus '2016-Datacenter-smalldisk' -Version 'latest'

    $VirtualMachine = New-AzVMConfig -VMName "VirtualMachine17" -VMSize "Standard_A1"
    Set-AzVMOSDisk -VM $VirtualMachine -Name "OsDisk12" -VhdUri "os.vhd" -Caching ReadWrite
    $VirtualMachine = Set-AzVMOperatingSystem -VM $VirtualMachine -Linux -ComputerName "MainComputer" -Credential (Get-Credential) 
    $VirtualMachine = Set-AzVMSourceImage -VM $VirtualMachine -PublisherName "Canonical" -Offer "UbuntuServer" -Skus "15.10" -Version "latest" -Caching ReadWrite
    $VirtualMachine = Set-AzVMOSDisk -VM $VirtualMachine -Name "osDisk.vhd" -VhdUri "https://mystorageaccount.blob.core.windows.net/disks/" -CreateOption FromImage
    New-AzVM -VM $VirtualMachine -ResouceGroupName "ResourceGroup11"


    Set-AzVMOperatingSystem
    -Customdata is only made available to the VM during first boot/initial setup, we call this 'provisioning'. custom data in the VM model cannot be updated
    -EnableAutoUpdate
    -EnableHotpatching
    -PatchMode AutomaticByPlatform|AutomaticByOS|Manual
    -TimeZone
    #>

    # install hyper-v in Azure VM and reboot
    Write-Progress -Activity $Activity -CurrentOperation 'Installing Hyper-V in the VM'
    Install-HyperVInAzVM -ResourceGroupName $ResourceGroupName -VMName $VMName | Out-Null

    # create a RDP file
    Write-Progress -Activity $Activity -CurrentOperation "Creating RDP icon in $RDPFolder"
    $RDPIcon = New-RDPIconFromAzVM -FullyQualifiedDomainName $vm.FullyQualifiedDomainName -Username $UserName -Path $RDPFolder

    # export object
    $properties = [ordered]@{
        'VMName'   = $VMName
        'Location' = $Location
        'VMSize'   = $VMSize
        'Image'    = $Image
        'UserName' = $UserName
        'FQDN'     = $vm.FullyQualifiedDomainName
        'AllocationMethod' = $AllocationMethod
        'RDPIcon'  = $RDPIcon.Path
    }
    $output = New-Object -TypeName PSObject -Property $properties
    Write-Output $output

    Write-Verbose ("{0} VM created in Azure. Time taken: {1}" -f (Get-Date), (New-TimeSpan -Start $Start).ToString().Split('.')[0])
    Write-Progress -Activity $Activity -Completed
}




function Import-VirtualEnvironment {

    <#
    .SYNOPSIS
    This command copies VM files from a central repository and imports the virtual machines.
    .DESCRIPTION
    This command executes the folowing tasks:
        Install-AzCopy
        AzCopy from StorageAccount to DestinationPath
        Configure Hyper-V: EnhancedSessionMode, VirtualHardDiskPath, VirtualMachinePath
        Connect-VhdToParent
        Create virtual switches
        Import VMs
        Rearm VM by VHD
        Create snapshot
        Enable internet access
    #>

    [cmdletbinding()]
    param(

        [string]$Destination = 'C:\Hyper-V'

    )

    # init
    $Activity = "Importing Virtual Environment to $Destination"
    Write-Progress -Activity $Activity -CurrentOperation 'Initializing'

    # Check that the script is being run with Administrator privilege
    Write-Verbose 'Verify running as administrator.'
    if (-not (Test-IsAdmin)) { Write-Error 'Please re-run this script as Administrator.' }


    # create destination folder
    if (Test-Path $Destination) {
        Write-Verbose "$Destination already exists"
    } else {
        mkdir $Destination -ErrorAction Stop | Out-Null
    }


    # disable IE ESC
    Set-InternetExplorerESC -DisableAdministrators

    # disable windows update
    # Stop-Service wuauserv -Passthru | Set-Service -StartupType Disabled


    # install AzCopy when required
    Install-AzCopy


    # Copy files from AzStorageAccount to $DestinationFolder
    $sa = Read-VESasFromDisk


    # download files from repo

    Write-Progress -Activity $Activity -CurrentOperation 'Copying files from storage account... (This might take a long time)'
    $source = $sa.endpoint + 'files' + $sa.sas
    Write-Verbose $source
    AzCopy copy $source $Destination --recursive --overwrite=false --log-level=WARNING


    # choose manifest file
    $ManifestFile = Get-ChildItem -Path $Destination -Recurse -Filter '*manifest*.json'

    if ($ManifestFile.count -eq 0) { Write-Warning "No manifest files found in $Destination. Nothing to deploy!" }
    if ($ManifestFile.count -ge 2) { $ManifestFile = $ManifestFile | Out-GridView -OutputMode Single -Title 'Select manifest' }
    Write-Verbose "Current manifest: $($ManifestFile.fullname)"

    # To do: test of hyper-v aanwezig is op host VM. Onder andere B-VMs ondersteunen dat niet.

    # Set host properties: enhanced session, vhdpath, vmpath
    Set-VMHost -EnableEnhancedSessionMode $true -VirtualHardDiskPath $Destination -VirtualMachinePath $Destination


    # pin hyper-v icon to desktop
    New-HyperVIconOnDesktop


    # connect vhd to parents
    Write-Progress -Activity $Activity -CurrentOperation 'Connecting VHD files to parents'
    Connect-VhdToParent -SearchPath $Destination


    # read manifest file
    $Manifest = Get-Content $ManifestFile.FullName | ConvertFrom-Json


    # create virtual switches
    Write-Progress -Activity $Activity -CurrentOperation 'Creating virtual switches'
    if ((Get-VMSwitch | Where-Object Name -eq $Manifest.vmswitchname).count -eq 0) {
        Write-Verbose "Creating $($Manifest.vmswitchtype) VM Switch: $($Manifest.vmswitchname)"
        New-VMSwitch -SwitchType $Manifest.vmswitchtype -Name $Manifest.vmswitchname | Out-Null
    }
    else {
        Write-Verbose "VM Switch $($Manifest.vmswitchname) already exists"
    }


    # Import VMs
    # Log -Message 'Import VMs'
    # To do: 
    #   check if filter is adequate. Don't import XML files from other apps.
    #   don't import snapshot if it exists
    #       \LON-DC1\Snapshots\06DAE58B-DD09-4319-B7DA-1D9807A4EC30.vmcx       
    #       \LON-DC1\Virtual Machines\8FECE960-60F0-44CA-BC6C-901173352A94.vmcx

    Get-ChildItem $Destination -Recurse | Where-Object Extension -match 'vmcx|xml' | Where-Object fullname -notmatch 'snapshot' | ForEach-Object {
        try {
            Write-Progress -Activity $Activity -CurrentOperation "Importing VM from $($_.FullName)"
            $vm = Import-VM -Path $_.FullName -ErrorAction Stop
            Write-Verbose "VM Imported: $($vm.name)"
        }
        catch {
            Write-Verbose "Import failed: $($_.FullName)"
        }
    }


    # rearm servers, to do: per VM, from manifest
    Write-Progress -Activity $Activity -CurrentOperation 'Rearming VMs'
    Get-VM | ForEach-Object { Invoke-RearmOnVMVHD $_.Name }


    # create snapshot
    Write-Progress -Activity $Activity -CurrentOperation 'Creating VM checkpoints'
    Get-VM | Checkpoint-VM -SnapshotName 'StartingImage'


    # optionally configure internet access
    if ($Manifest.InternetRequired) {
        $GatewayAddress, $PrefixLength = $Manifest.IP.split('/')
        Write-Progress -Activity $Activity -CurrentOperation "Configuring internet, gateway: $GatewayAddress, prefix: $PrefixLength"
        Enable-VEInternet -GatewayAddress $GatewayAddress -PrefixLength $PrefixLength
    }
    else {
        Write-Verbose 'Internet not required for this training'
    }
    Write-Progress -Activity $Activity -Completed
}




function Enable-VEInternet {

    <#
    .SYNOPSIS
    This command enabled internet access for a virtual environment.
    #>

    [cmdletbinding()]
    param(
        [string]$GatewayAddress,
        [int]$PrefixLength = 24
    )

    Write-Verbose "Configuring TCP/IP using $GatewayAddress / $PrefixLength"

    Get-NetAdapter | 
    Where-Object Name -match private | 
    Get-NetIPAddress | 
    Where-Object AddressFamily -eq 'IPv4' | 
    New-NetIPAddress $GatewayAddress -PrefixLength $PrefixLength | Out-Null
    # Select-Object ifIndex, IPAddress
    #New-NetIPAddress -IPAddress 192.168.1.1 -PrefixLength 16 -InterfaceAlias "vEthernet (NATSwitch)"
    #Get-NetAdapter | Where-Object Name -match private | New-NetIPAddress -IPAddress $GatewayAddress -PrefixLength 24 #| Out-Null
    #Get-NetAdapter | Set-DnsClientServerAddress -ServerAddresses $dnsIPAddress

    Write-Verbose 'Installing Routing, RSAT-RemoteAccess, RSAT-NPAS'
    Install-WindowsFeature Routing | Out-Null
    Install-WindowsFeature RSAT-RemoteAccess, RSAT-NPAS -IncludeAllSubFeature | Out-Null
    # write proper output
}




<#
=================================================================================================
   COMMON FUNCTIONS
=================================================================================================
#>




function Read-VESasFromDisk {
    <#
    .SYNOPSIS
    This command reads a Base64-encoded SAS file from disks and converts it to a sas object
    #>

    [cmdletbinding()]
    param(
        [string]$sasFileName = 'c:\sas.txt'
    )

    Write-Verbose "Reading: $sasFileName"
    $FileContents = Get-Content $sasFileName
    $sas = [System.Text.Encoding]::Unicode.GetString([System.Convert]::FromBase64String($FileContents))
    $sas | ConvertFrom-Json
}




function Write-VESasToAzVM {
    <#
    .SYNOPSIS
    This command writes a Blob endpoint and SAS as a Base64-encoded file to the disk of an Azure VM
    #>

    [cmdletbinding()]
    param(
        [Parameter(Mandatory=$true)]
        [string]$StorageAccountName,

        [Parameter(Mandatory=$true)]
        [string]$StorageAccountResourceGroupName,

        [Parameter(Mandatory=$true)]
        [string]$VMResourceGroupName,

        [Parameter(Mandatory=$true)]
        [string]$VMName
    )

    # create SAS
    # https://docs.microsoft.com/en-us/rest/api/storageservices/create-account-sas?redirectedfrom=MSDN
    Write-Verbose "Retrieving storage account with name $StorageAccountName in resource group $StorageAccountResourceGroupName"
    $sa = Get-AzStorageAccount -ResourceGroupName $StorageAccountResourceGroupName -Name $StorageAccountName -ErrorAction Stop
    $sas = New-AzStorageAccountSASToken -Service Blob -ResourceType Container,Object -Permission 'rl' -Context $sa.Context -ExpiryTime (Get-Date).AddDays(365)

    # prepare Base64-encoded json sas object
    $PSObject = New-Object -TypeName PSObject
    $PSObject | Add-Member -NotePropertyMembers @{endpoint=$sa.Context.BlobEndPoint;sas=$sas}
    $Text = $PSObject | ConvertTo-Json
    $Bytes = [System.Text.Encoding]::Unicode.GetBytes($Text)
    $EncodedText = [Convert]::ToBase64String($Bytes)
    Write-Verbose "Text: $Text"
    Write-Verbose "Encoded text: $EncodedText"

    $HashArguments = @{
        ResourceGroupName = $ResourceGroupName
        VMName = $VMName
        CommandText = 'param($sas); $sas | Out-File c:\sas.txt'
        Parameter = @{sas = $EncodedText} # UITWERKEN
    }
    Invoke-VEAzVMRunCommand @HashArguments
}




function Install-HyperVInAzVM {

    [cmdletbinding()]
    param(
        [Parameter(Mandatory=$true)]
        [string]$ResourceGroupName,

        [Parameter(Mandatory=$true)]
        [string]$VMName
    )

    $HashArguments = @{
        ResourceGroupName = $ResourceGroupName
        VMName = $VMName
        CommandText = 'diskperf -y; Install-WindowsFeature Hyper-V -IncludeAllSubFeature -IncludeManagementTools -Restart'
    }
    Invoke-VEAzVMRunCommand @HashArguments
}




function Invoke-VEAzVMRunCommand {
    param(
        [Parameter(Mandatory=$true)]
        [string]$ResourceGroupName,

        [Parameter(Mandatory=$true)]
        [string]$VMName,

        [Parameter(Mandatory=$true)]
        [string]$CommandText,

        $Parameter #= $null
    )

    <#
    Set-AzVMCustomScriptExtension
    DISADVANTAGE: script file needs to be present in storage account
    ADVANTAGE: storage account interaction already present thanks to VERepo
    #>

    # Invoke-AzVMRunCommand: file needs to be available locally
    $TempFilename = Join-Path $env:TEMP "$(Get-Random).ps1"

    # save file to run on VM on local disk
    try {
        $CommandText | Out-File -FilePath $TempFilename -ErrorAction Stop
        Write-Verbose "$TempFilename contents: $(Get-Content $TempFilename -ErrorAction Stop)"
    }
    catch {
        Write-Error "Error while creating $TempFilename"

    }

    # run command on Azure VM
    $HashArguments = @{
        ResourceGroupName = $ResourceGroupName
        VMName = $VMName
        CommandId = 'RunPowerShellScript'
        ScriptPath = $TempFilename
        Parameter = $Parameter  # @{sas = $EncodedText} # UITWERKEN
    }
    # output = System.Collections.Hashtable: Write-Verbose "Calling Invoke-AzVMRunCommand: $HashArguments"
    Invoke-AzVMRunCommand @HashArguments

    # remove temp file
    Remove-Item $TempFilename
}




function New-HyperVIconOnDesktop {
    <#
    .SYNOPSIS
    Pin Hyper-V icon to the user's desktop.
    #>

    [cmdletbinding()]param()

    Write-Verbose 'Creating shortcut to Hyper-V Manager on desktop.'
    $Shortcut = (New-Object -ComObject WScript.Shell).CreateShortcut($(Join-Path "$env:UserProfile\Desktop" "Hyper-V Manager.lnk"))
    $Shortcut.TargetPath = "$env:SystemRoot\System32\virtmgmt.msc"
    $Shortcut.Save()
}




function Set-InternetExplorerESC {
    <#
    .SYNOPSIS
    Enables or disables Internet Explorer Enhanced Security Configuration
    #>

    [cmdletbinding()]
    param(
        [switch]$EnableAdministrators,
        [switch]$DisableAdministrators,
        [switch]$EnableUsers,
        [switch]$DisableUsers,
        [switch]$DontKillExplorer    
    )

    $AdminKey = "HKLM:\SOFTWARE\Microsoft\Active Setup\Installed Components\{A509B1A7-37EF-4b3f-8CFC-4F3A74704073}"
    $UserKey = "HKLM:\SOFTWARE\Microsoft\Active Setup\Installed Components\{A509B1A8-37EF-4b3f-8CFC-4F3A74704073}"

    if ($EnableAdministrators)  { $Path = $AdminKey; $Value = 1 }
    if ($DisableAdministrators) { $Path = $AdminKey; $Value = 0 }
    if ($EnableUsers)           { $Path = $UserKey;  $Value = 1 }
    if ($DisableUsers)          { $Path = $UserKey;  $Value = 0 }
    Set-ItemProperty -Path $Path -Name "IsInstalled" -Value $Value
    if (-not ($DontKillExplorer)) {
        Stop-Process -Name Explorer
    }

    Write-Verbose "IE Enhanced Security Configuration (ESC) has been reconfigured."
}




Function Test-IsAdmin {
    $user = [Security.Principal.WindowsIdentity]::GetCurrent();
    (New-Object Security.Principal.WindowsPrincipal $user).IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)
    # or ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")
}




function Get-VEModuleOverview {
    <#
    .SYNOPSIS
    Displays all commands and it's synopsis from the VirtualEnvironment module
    #>
    Get-Command -Module VirtualEnvironment | Get-Help | Select-Object Name, Synopsis 
}




function Invoke-RearmOnVMVHD {
    <#
    .SYNOPSIS
    This function writes registry values to the first VHD of a specified VM
    .NOTES
    Not preferred to do this for VHD files, because those generally contain base OS images and should not be modified.
    #>

    [cmdletbinding()]
    param(
        [Parameter(Mandatory=$true)]
        [string]$VMName
    )

    Get-VM | Where-Object Name -eq $VMName | ForEach-Object {

        Write-Debug "Testing VHDs from VM: $VMName"

        # Get vDisks. IDE + SCSI. Controller location and number not required because registry path is tested
        $VHDs = $_.VMName | Get-VMHardDiskDrive -ControllerLocation 0 -ControllerNumber 0

        foreach ($VHD in $VHDs) {

            $MountedVHD = Mount-VHD -Path $VHD.Path -Passthru | Get-Disk | Get-Partition | Where-Object Size -gt 600MB   # werkt niet met meerdere partities!
            $DriveLetter = $MountedVHD.DriveLetter
            $VirtualRegPath = $DriveLetter + ':\Windows\System32\Config\SOFTWARE'

            if (Test-Path $VirtualRegPath) {

                Write-Verbose "Rearming VM: $VMName, Registry found on $DriveLetter`: on $($VHD.Path)"
                reg.exe load HKLM\VHDSYS $VirtualRegPath
                # reg.exe ipv reg
                # REG commando werkt goed op de CL* VMs van 20697-1C maar werkt niet meer bij de meeste CL* machines van 20697-1D
                # C release: alle VMs in XML formaat: commando werkt goed
                # D release: alle VMs in VMRC formaat: commando werkt niet goed, behalve bij 1 VM (CL3), waarvan het formaat XML is. Check ook de disk indeling
    
                $RegPath = 'Microsoft.PowerShell.Core\Registry::HKEY_LOCAL_MACHINE\VHDSYS\Microsoft\Windows\CurrentVersion\RunOnce'
                $RegValue = 'cmd.exe /C start /min PowerShell.exe -Command slmgr.vbs -rearm'
                Set-ItemProperty -Path $RegPath -Name 'rearm' -Value $RegValue
    
                # unload registry and dismount VHD
                [gc]::Collect()
                reg.exe unload HKLM\VHDSYS
                # to do: create proper output
            } else {
                Write-Verbose "No registry found on this drive: $($VHD.Path)"
            }
            Dismount-VHD $VHD.Path
        }
    }
}




function Get-VEManifestInventory {
    <#
    .SYNOPSIS
    This function creates an inventory of all manifest files in the images foder
    #>

    param(
        $ImageSource = 'Q:\Images'
    )

    Get-ChildItem $ImageSource -Filter manifest* -Recurse | Where-Object Extension -Match 'CSV|JSON' | ForEach-Object { 
        Write-Host ('='*80) -ForegroundColor Cyan
        Write-Host "=== $($_.fullname)"
        Write-Host ('='*80) -ForegroundColor Cyan
        Get-Content $_.fullname
    }
}




function Install-AzCopy {
    <#
    .SYNOPSIS
    This function checks for AzCopy existence and installs it when necessary.
    #>
    [cmdletbinding()]param(
        [string]$uri = 'https://aka.ms/downloadazcopy-v10-windows',
        [string]$Destination = $env:windir,
        [string]$outfile = 'AzCopy.zip',
        [switch]$force
    )

    # check for AzCopy existence
    if (Get-Command AzCopy.exe -ea 0) {

        Write-Verbose 'AzCopy already exists. Nothing to do.' 

    } else {

        # enable Tls12
        [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072

        # download AzCopy
        Invoke-WebRequest -Uri $uri -OutFile $outfile -UseBasicParsing

        # extract
        Expand-Archive $outfile

        # move to destination
        Get-ChildItem ./AzCopy/*/azcopy.exe | Move-Item -Destination $Destination

        # remove downloaded file
        Remove-Item $outfile
    }
}




function Install-HyperV {
    <#
    .SYNOPSIS
    Installs Hyper-V on a computer. Can optionally postpone the reboot.
    #>

    [cmdletbinding()]
    param(
        [switch]$NoRestart
    )

    # is hyper-v alread installed?
    # to do: improve this check
    if (Get-Module Hyper-V -ErrorAction SilentlyContinue) {
        Write-Verbose 'Hyper-V is alread installed'
    } else {
        # determine server or client OS
        if (Get-Command Install-WindowsFeature -ErrorAction SilentlyContinue) {
            # this is a server OS
            if ($NoRestart) {
                Write-Verbose 'Enabling Hyper-V for server OS without reboot'
                Install-WindowsFeature Hyper-V -IncludeAllSubFeature -IncludeManagementTools
            } else {
                Write-Verbose 'Enabling Hyper-V for server OS with reboot'
                Install-WindowsFeature Hyper-V -IncludeAllSubFeature -IncludeManagementTools -Restart
            }
        } else {
            # this is a client OS
            if ($NoRestart) {
                Write-Verbose 'Enabling Hyper-V for client OS without reboot'
                Enable-WindowsOptionalFeature -FeatureName Microsoft-Hyper-V-All -Online -NoRestart
            } else {
                Write-Verbose 'Enabling Hyper-V for client OS with reboot'
                Read-Host 'Press Enter to reboot the computer after installation of Hyper-V'
                Enable-WindowsOptionalFeature -FeatureName Microsoft-Hyper-V-All -Online
            }
        }
    }
}




function Connect-VhdToParent { 
    <#
    .SYNOPSIS
    this function can fix VHDs, pointing to correct parent disk file
    #>

    [cmdletbinding()]
    param(
        [string]$SearchPath = 'C:\Hyper-V'
    )

    Write-Debug "Traversing $SearchPath"
    $VhdFiles = Get-ChildItem -path $SearchPath -Recurse -ErrorAction SilentlyContinue | Where-Object extension -Match VHD
    Write-Debug "Vhd files found: $($VhdFiles.count) $($VhdFiles | ForEach-Object { "`n" + $_.Name })"

    foreach ($CurrentVhd in $VhdFiles) {
        Write-Debug "Testing $($CurrentVhd.fullname)"
        $TestVhdError = $null
        Test-VHD $CurrentVhd.fullname -ErrorVariable TestVhdError -ErrorAction SilentlyContinue | Out-Null
        if ($TestVhdError) {  ######################################## was .count -lt 1 write-host no errors
            # error occurred
            $missingBaseFile = $null
            $missingBaseFile = $TestVhdError.Exception.InnerException.parentpath.tolower()
            # innerexception not available on w2012
            if ($missingBaseFile) {
                # determine filename
                $BaseFilename = Split-Path $missingBaseFile -Leaf
                Write-Debug "Fixing missing base file: $BaseFilename from $($CurrentVhd.fullname)"

                # find filename in $VhdFiles
                $vhdFixed = $false
                $VhdFiles | ForEach-Object {
                    if ($_.name -eq $BaseFileName) {
                        # connect VHD to parent
                        Write-Verbose "Connecting $($CurrentVhd.fullname) to $($_.FullName)"
                        Set-VHD -Path $CurrentVhd.FullName -ParentPath $_.FullName -ErrorAction Continue
                        $vhdFixed = $true
                    }
                }
                if (-not ($vhdFixed)) { Write-Error  -Message "Base file $BaseFilename not found for `n $($CurrentVhd.fullname)" }
            }
            else {
                Write-Error "Other error! $TestVhdError"
            }
        }
    }
}




Function Get-VEManifestSourceFiles {
    <#
    .SYNOPSIS
    This function displays required parent files for a specific virtual environment.
    #>

    param(
        [Parameter(Mandatory=$true)]
        [string]$ManifestFile
    )

    $Sum = 0
    $Manifest = Get-Content $ManifestFile | ConvertFrom-Json

    # search parent files
    $Manifest | 
    Select-Object -ExpandProperty SourceFiles -ErrorAction 0 | 
    ForEach-Object {
        
        $Length = (Get-ChildItem $_).Length
        $Sum += $Length
        $props = [ordered]@{
            'ManifestFile' = $ManifestFile
            'Length' = $Length
            'Name' = $_.FullName
        }
        New-Object -TypeName PSObject -Property $props

    }

    # search source folder
    Get-ChildItem -Path $Manifest.SourcePath -Recurse -File | Foreach-object {

        $Sum += $_.Length
        $props = [ordered]@{
            'ManifestFile' = $ManifestFile
            'Length' = $_.Length
            'Name' = $_.FullName
        }
        New-Object -TypeName PSObject -Property $props

    }

    write-host "total size = $($sum/1GB -as [int]) GB"
}




function Stop-AzVMOGV {
    <#
    .SYNOPSIS
    This function stops Azure VMs after selection using out-gridview.
    #>

    Get-AzVM | 
    Out-GridView -OutputMode Multiple -Title 'Please select VMs to stop' | 
    ForEach-Object { Stop-AzVM -Name $_.Name -ResourceGroupName $_.ResourceGroupName }   # if using -AsJob then -Force might be necessary
}




function New-RDPIconFromAzVM {

    <#
    .SYNOPSIS
    Creates an RDP icon (RDP-file) from an Azure VM.
    #>

    [cmdletbinding()]
    param(
        [Parameter(ParameterSetName = 'VMName')]
        [string]$VMName,

        [Parameter(ParameterSetName = 'ResourceGroupName')]
        [string]$ResourceGroupName,

        [Parameter(ParameterSetName = 'FullyQualifiedDomainName')]
        [string]$FullyQualifiedDomainName,

        [Parameter(ParameterSetName = 'OutGridView')]
        [switch]$OutGridView,

        #[Parameter(Mandatory=$true)]
        [string]$Path = (Get-Location),

        [string]$UserName = '.\Student'

    )

    if ($ResourceGroupName) {
        Write-Verbose "Retrieving all public IP address in resource group $ResourceGroupName"
        $address = Get-AzPublicIpAddress -ResourceGroupName $ResourceGroupName
        if ($address.count -ne 1) { 
            Write-Warning "Resourcegroup $ResourceGroupName contains $($PublicIP.count) IP addresses. Using first IP address."
            $address = $address | Select-Object -First 1
        }
        $address = $address.IpAddress
    }

    if ($OutGridView) {
        $vm = Get-AzVM | Out-GridView -OutputMode Single -Title 'Please select VM to create RDP icon from'
        # prepopulate $ResourceGroupName for next section
        $ResourceGroupName = $vm.ResourceGroupName
        $VMName = $vm.Name
    }

    if ($VMName) {
        # $vm might have been provided by previous section
        if (!($vm)) { $vm = Get-AzVM -Name $VMName }
        # prepopulate $ResourceGroupName for next section
        $ResourceGroupName = $vm.ResourceGroupName
        $address = Get-AzPublicIpAddress -ResourceGroupName $ResourceGroupName
        if ($address.count -ne 1) { 
            Write-Warning "Resourcegroup $ResourceGroupName contains $($PublicIP.count) IP addresses. Using first IP address."
            $address = $address | Select-Object -First 1
        }
        $address = $address.IpAddress
    }

    if ($FullyQualifiedDomainName) {
        $address = $FullyQualifiedDomainName

    }
    
    # create RDP icon
    Write-Verbose "Creating RDP icon with address $address"
    $rdp = New-RdpIcon -FullAddress $address -Username $Username
    $FileName = $VMName
    if ($FullyQualifiedDomainName) { $FileName = $FullyQualifiedDomainName.split('.')[0] }
    $outputFile = Join-Path $Path ($FileName + '.rdp')
    $rdp | Out-File $outputFile

    # output vmname, ip address, path
    $properties = [ordered]@{
        'Address'  = $address
        'UserName' = $UserName
        'Path'     = $outputFile
    }
    $output = New-Object -TypeName PSObject -Property $properties
    Write-Output $output
}




function New-RdpIcon {

    <#
    .SYNOPSIS
    Creates an RDP icon from an network address
    .NOTES
    check: http://therightstuff.de/2009/02/13/Creating-Remote-Desktop-Connection-Files-On-The-Fly-With-PowerShell.aspx
    autoreconnection enabled:i:1
    bitmapcachepersistenable:i:1
    compression:i:1
    disable cursor setting:i:0
    disable full window drag:i:1
    disable menu anims:i:1
    disable themes:i:0
    disable wallpaper:i:0
    displayconnectionbar:i:1
    keyboardhook:i:1
    redirectclipboard:i:1
    redirectcomports:i:0
    redirectdrives:i:0
    redirectprinters:i:0
    redirectsmartcards:i:1
    session bpp:i:32
    audiomode:i:0
    screen mode id:i:2
    audiocapturemode:i:0
    videoplaybackmode:i:1
    connection type:i:7
    networkautodetect:i:1
    bandwidthautodetect:i:1
    enableworkspacereconnect:i:0
    allow font smoothing:i:0
    allow desktop composition:i:0
    redirectposdevices:i:0
    negotiate security layer:i:1
    remoteapplicationmode:i:0
    promptcredentialonce:i:0
    gatewaybrokeringtype:i:0
    use redirection server name:i:0
    $out += "screen mode id:i:1"

    [int]$resWidth = 1024,   # liever $null, dan staat ie op fullscreen?
    [int]$resHgt = 768
    $out += "desktopwidth:i:" + $resWidth
    $out += "desktopheight:i:" + $resHgt

    #>


    [OutputType([String])]
    param(
        [parameter(Mandatory=$true)]
        [string]$FullAddress,

        [string]$Username='Administrator',
        [string]$GatewayHostName=$null
    )

    $RdpTemplate = @"
full address:s:$FullAddress
username:s:$Username
prompt for credentials:i:0
promptcredentialonce:i:1
"@

    if ($GatewayHostName) {
        $RdpTemplate += @"
authentication level:i:2
gatewayhostname:s:$GatewayHostName
gatewayusagemethod:i:1
gatewaycredentialssource:i:4
gatewayprofileusagemethod:i:1
"@

    }

    Write-Output $RdpTemplate
}




function New-PSCredential {

    param(

        [Parameter(Mandatory=$true)]
        [string]$userName,

        [Parameter(Mandatory=$true)]
        [string]$password
    )

    $secStringPassword = ConvertTo-SecureString $password -AsPlainText -Force
    [pscredential](New-Object System.Management.Automation.PSCredential ($userName, $secStringPassword))
}


# Export-ModuleMember -Function * -Alias *

# Import-VirtualEnvironment -Verbose
