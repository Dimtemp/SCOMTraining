# init
$students = 'student1', 'student2'
$resourceGroupName = 'SCOMTraining'
$vmsize = 'Standard D4s v3'
$location = 'westeurope'
$containerName = 'files'
$secStringPassword = ConvertTo-SecureString 'Pa55w.rd1234' -AsPlainText -Force
$sourceFiles = 'Q:\Images\Parent\Base17A-W10-1607.vhd', 'Q:\Images\Parent\Base17C-WS16-1607.vhd', 'Q:\Software\Microsoft\SQL\en_sql_server_2016_enterprise_with_service_pack_1_x64_dvd_9542382.iso', 'Q:\Software\Microsoft\System Center 2019\mu_system_center_operations_manager_2019_x64_dvd_b3488f5c.iso'


# check input files
$sourceFiles | foreach-object { if (!(Test-Path $_)) { Throw "Source file does not exist! Terminating... $_" } }


# check for AzCopy existence
if (!(Get-Command AzCopy.exe)) { throw "AzCopy does not exist! Terminating." }


# create storage account
$sa = Get-AzStorageAccount -ResourceGroupName $resourceGroupName
if ($null -eq $sa) {
    $sa = New-AzStorageAccount -ResourceGroupName $resourceGroupName -Name "stor$(Get-Random)" -SkuName Standard_LRS -Location 'westeurope' -Kind StorageV2
    New-AzStorageContainer -Context $sa.Context -Name $containerName -Permission Container

    # generate SAS
    $StartTime = Get-Date
    $ExpiryTime = $startTime.AddDays(365)
    $blobSas = New-AzStorageContainerSASToken -Name $containerName -Permission rwd -StartTime $StartTime -ExpiryTime $ExpiryTime -context $sa.Context

    # upload files to storage account
    $sourceFiles | Foreach { AzCopy copy $_ $blobSas }
}


# create VM in Azure for each student
$students | Foreach-Object {
    # create credential object
    [pscredential]$cred = New-Object System.Management.Automation.PSCredential ($_, $secStringPassword)
    
    # create VM
    New-AzVM -ResourceGroupName $_  -Name $_ -Location $location -Size $vmsize -AllocationMethod Static -Credential $cred -Image 'Win2016Datacenter' # -OpenPorts 3389 -AsJob
}
