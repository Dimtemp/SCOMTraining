# Chapter: Complex Configurations (optional)

Perform a reboot on the LON-DC1 before beginning this lab. This is to prevent an issue with the certificate revocation role.

## Additional Management Servers and Consoles
Perform the following step on LON-SV1:
1. Open the Windows Firewall and create a rule that allows TCP port 1433 traffic.

Perform the following step on the host server:
1. Open Hyper-V Manager and open the LON-SV2 virtual machine settings to mount the SCOM DVD from the C:\HyperV folder.

Perform the following steps on LON-SV2:
1. SCOM 2012 / R2 does not check on the existence of .NET Framework. Don’t forget to enable  .NET Framework 3.5.1 under Features in Server Manager before beginning installation!
1. You can also install the .NET Framework with PowerShell using this command:
1. Import-Module ServerManager; Add-WindowsFeature NET-Framework-Core

The Microsoft System CLR Types for Microsoft SQL Server 2012 are required before installing a second Management Server. Please download and install this from the following URL:
http://go.microsoft.com/fwlink/?LinkID=239644
1. Run Setup and from the Setup splash screen, click the large Install link to start the setup wizard.
2. Select Management server and Operations console. Click Next.
3. Accept the default installation location and click Next.
4. Setup continues with the message Verifying that your environment has the required hardware and software. If issues are found, the message The Setup wizard cannot continue appears. This means additional hardware resources or software is required to continue. In this case the Report Viewer needs to be installed. Please follow the hyperlink to download and Install the Report Viewer.
5. After resolving any prerequisite problems, click Verify Prerequisites Again. If verification is successful, click Next. 
6. At the Specify an installation option page, select Add a management server to an existing management group. Click Next. 
7. Accept the license agreement and click Next. 
8. Configure the operational database. Specify the database previously created by the setup process on the first management server:
  - Click in the server name or port number area to cause a validation process for the database server. When Setup can validate the SQL Server of the operational database, the Database name drop-down list becomes active. Select the database name, OperationsManager by default. Click Next. 
9. Configure Operations Manager accounts. Use the same accounts specified during the installation process on the first management server.
10. After clicking Next, Setup verifies whether a specified action account is a domain administrator account. A warning box will state this is not recommended for security reasons. Click OK on the warning to proceed with setup.
  - CAUTION: DO NOT GIVE SERVICE ACCOUNT DOMAIN ADMIN PRIVILEGES   While it is convenient and often seen in lab and demo environments, the authors do not recommend making OpsMgr service accounts members of the Domain Admins global security group in production scenarios. The MSAA and SDK accounts (which should not be Domain Admins in normal practice) should be made members of the local Administrators group on management servers.
11. At the Help improve System Center 2012 Operations Manager page, indicate your desire to participate in these programs. Click Next.
12. At the Installation Summary page, review your selections. To continue, press Install.
13. Setup is complete when all green checkmarks appear. If any component failed to install, it is marked with a red “X”. Check the setup log for error 1603. If this error appears then open server manager, features and remove the .NET Framework 3.5. Reboot and reinstall .NET Framework 3.5. Now setup will succeed.

## PowerShell Configuration for Agent Failover
PowerShell provides a quick way to determine the primary and failover management servers an agent is configured to use. The following command finds the primary management server for an agent:
```Get-SCOMAgent | where DisplayName -eq "LON-DC1.Adatum.com" | Select PrimaryManagementServerName```
You can also use PowerShell to configure primary and failover management servers in OpsMgr. The following PowerShell script assigns the agent to a variable, defines the primary and failover management servers as variables, and then uses the Set-SCOMParentManagementServer cmdlet to assign the primary and the failover server for the agent.
```
$SCOMAgent = Get-SCOMAgent -Name "LON-DC1.Adatum.com"
$Primary = Get-SCOMManagementServer -Name "LON-SV1.adatum.com"
$Failover = Get-SCOMManagementServer -Name "LON-SV2.adatum.com"
Set-SCOMParentManagementServer -Agent $scomAgent -PrimaryServer $Primary
Set-SCOMParentManagementServer -Agent $scomAgent -FailoverServer $Failover
```
