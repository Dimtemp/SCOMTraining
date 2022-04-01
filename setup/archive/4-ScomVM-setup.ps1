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
