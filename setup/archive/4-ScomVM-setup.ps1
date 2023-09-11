# run this script from the management server VM

# to do: test for admin
Write-Warning "This script must be run elevated on the management server VM"
Read-Host "Press ENTER to continue, or CTRL+C to quit."

# run taskmgr and enable disk stats
taskmgr.exe
diskperf -y

# to do: test for domain membership!
if ($env:COMPUTERNAME -ne 'LON-SV1') {
    Rename-Computer -NewName LON-SV1 -Restart
}


$cred = Get-Credential -UserName 'ADATUM\Admin' -Message 'Domain admin credentials'
Add-Computer -DomainName adatum -Credential $cred -Restart  #-ComputerName LON-SV1 


# Extract files from SCOM DVD
# D:\SCOM_2019.exe

# install AD Tools
Install-WindowsFeature RSAT-AD-Tools

# create SQL service account
$pw = ConvertTo-SecureString 'Pa55w.rd' -AsPlainText -Force
New-ADUser -Name SQLService -AccountPassword $pw -Enabled $true

ADD-ADGroupMember -Identity 'Domain Admins' -Members 'SQLService'

# install SQL
D:\Setup.exe /q /ACTION=Install /FEATURES=SQLEngine,FullText,RS /INSTANCENAME=MSSQLSERVER /SQLSVCACCOUNT="ADATUM\SQLService" /SQLSVCPASSWORD="Pa55w.rd" /SQLSYSADMINACCOUNTS="adatum\domain admins" /AGTSVCACCOUNT="NT AUTHORITY\Network Service" /IACCEPTSQLSERVERLICENSETERMS

<#
/FEATURES=SQLEngine,FullText	Installs the Database Engine and full-text.
/FEATURES=SQL,Tools             Installs the complete Database Engine and all tools
/SQLSVCINSTANTFILEINIT="True"
/PID   Specifies the product key for the edition of SQL Server. If this parameter is not specified, Evaluation is used.
https://docs.microsoft.com/en-us/sql/database-engine/install-windows/install-sql-server-from-the-command-prompt?view=sql-server-2017#Feature
#>


# not needed
# Set-DnsClientServerAddress -InterfaceAlias Ethernet -ServerAddresses 10.0.0.10
# Add-Domain adatum.msft
# Restart-Computer
