# init
$students = 'student1', 'student2'
$resourceGroupName = 'SCOMTraining'
$vmsize = 'Standard_D4s_v3'
$location = 'westeurope'
$containerName = 'files3'
$secStringPassword = ConvertTo-SecureString 'Pa55w.rd1234' -AsPlainText -Force
$sourceFilesPath = 'Q:\Images\SC2019'
$sourceFiles = 'Q:\Images\Parent\Base17A-W10-1607.vhd', 'Q:\Images\Parent\Base17C-WS16-1607.vhd', 'Q:\Software\Microsoft\SQL\en_sql_server_2016_enterprise_with_service_pack_1_x64_dvd_9542382.iso', 'Q:\Software\Microsoft\System Center 2019\mu_system_center_operations_manager_2019_x64_dvd_b3488f5c.iso'


# check input files
$sourceFiles | foreach-object { if (!(Test-Path $_)) { Throw "Source file does not exist! Terminating... $_" } }
if (!(Test-Path $sourceFilesPath)) { Throw "Source file does not exist! Terminating... $_" }


# check for AzCopy existence
if (!(Get-Command AzCopy.exe)) { throw "AzCopy does not exist! Terminating." }


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
AzCopy copy $sourceFilesPath $blobSas --recursive
$sourceFiles | Foreach { AzCopy copy $_ $blobSas }


# create VM in Azure for each student
$students | Foreach-Object {
    # create credential object
    [pscredential]$cred = New-Object System.Management.Automation.PSCredential ($_, $secStringPassword)
    
    # create VM
    # extensions!!!
    # -AsJob
    New-AzVM -ResourceGroupName $_  -Name $_ -Location $location -Size $vmsize -AllocationMethod Static -Credential $cred -Image 'Win2016Datacenter'
}

