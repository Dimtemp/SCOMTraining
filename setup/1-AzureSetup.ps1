# student and VM names
$students = 'student1', 'student2'

# check input files
$sourceFiles = 'Q:\Images\Parent\Base17A-W10-1607.vhd', 'Q:\Images\Parent\Base17C-WS16-1607.vhd', 'Q:\Software\Microsoft\SQL\en_sql_server_2016_enterprise_with_service_pack_1_x64_dvd_9542382.iso', 'Q:\Software\Microsoft\System Center 2019\mu_system_center_operations_manager_2019_x64_dvd_b3488f5c.iso'
$sourceFiles | Test-Path

# check for AzCopy existence
Get-Command AzCopy.exe

# create storage account
UITWERKEN

# generate SAS
UITWERKEN
$blobSas = 'https://scomtraining.blob.core.windows.net/files?sp=acw&st=2021-04-20T15:01:29Z&se=2022-04-20T23:01:29Z&spr=https&sv=2020-02-10&sr=c&sig=7scTOHooh25UtcCgGlyCZXuE1ib0eCojIDiBCOI0wTQ%3D'

# upload files to storage account
$sourceFiles | Foreach { AzCopy copy $_ $blobSas }

# create VM in Azure for each student
UITWERKEN
$students | foreach { New-AzVM -Resourcegroup $_  -VMName $_ -location 'westeurope' -vmsize 'Standard D4s v3' }
