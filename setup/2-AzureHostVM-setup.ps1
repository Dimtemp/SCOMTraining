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

#Move AzCopy to the destination you want to store it
Get-ChildItem ./AzCopy/*/azcopy.exe | Move-Item -Destination $env:windir
copy base files via AzCopy vanuit storage account
mkdir C:\Hyper-V
AzCopy.exe copy $blobSas C:\Hyper-V

Base17C-WS16-1607*
Base17A-W10-1607*
E:\Hyper-V\en_sql_server_2016_enterprise_with_service_pack_1_x64_dvd_9542382.iso
E:\Hyper-V\mu_system_center_operations_manager_2019_x64_dvd_b3488f5c.iso


cd \SCOMTraining\
.\SCOMTrainingSetup.ps1
UITWERKEN

