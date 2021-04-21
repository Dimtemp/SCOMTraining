# init
$students = 'student1', 'student2'
$vmsize = 'Standard D4s v3'
$location = 'westeurope'
$sourceFiles = 'Q:\Images\Parent\Base17A-W10-1607.vhd', 'Q:\Images\Parent\Base17C-WS16-1607.vhd', 'Q:\Software\Microsoft\SQL\en_sql_server_2016_enterprise_with_service_pack_1_x64_dvd_9542382.iso', 'Q:\Software\Microsoft\System Center 2019\mu_system_center_operations_manager_2019_x64_dvd_b3488f5c.iso'

# check input files
$sourceFiles | foreach-object { if (!(Test-Path $_)) { Throw "Source file does not exist! Terminating... $_" } }

# check for AzCopy existence
if (!(Get-Command AzCopy.exe)) { throw "AzCopy does not exist! Terminating." }

# create storage account
$sa = New-AzStorageAccount -ResourceGroupName SCOMTraining -Name "stor$(Get-Random)" -SkuName Standard_LRS -Location 'westeurope' -Kind StorageV2
New-AzStorageContainer -Context $sa.Context -Name 'container1' -Permission Container

# generate SAS
$StartTime = Get-Date
$EndTime = $startTime.AddDays(365)
$blobSas = New-AzStorageContainerSASToken -Name 'container1' -Permission rwd -StartTime $StartTime -ExpiryTime $EndTime -context $sa.Context


# upload files to storage account
$sourceFiles | Foreach { AzCopy copy $_ $blobSas }

# create VM in Azure for each student
UITWERKEN
$students | foreach-Object { New-AzVM -Resourcegroup $_  -VMName $_ -location $location -vmsize $vmsize }
