# Chapter: Complex Configurations (optional)

Perform a reboot on the LON-DC1 before beginning this lab. This is to prevent an issue with the certificate revocation role. Also, this lab requires an internet connection for the virtual machines, for the installation of the .NET Framework.

## Additional Management Servers and Consoles
### Perform the following step on the host server:
1. Open Hyper-V Manager and open the LON-SV2 virtual machine settings to mount the SCOM DVD from the **C:\Hyper-V\files** folder.

### Perform the following step on LON-SV1:
1. Open the Windows Firewall and create a rule that allows TCP port 1433 traffic.
2. If you're not sure how to create the firewall rule, just disable the firewall for all three profiles (public, private, domain). Don't worry. This is a lab environment. No one will enter your VM from the lab network.

### Perform the following steps on LON-SV2:
1. Click Start, click settings, click System, click About, click Join a domain.
2. Enter **ADATUM** as a domain name, enter **Administrator** with the supplied password. If asked select **Skip**.
3. Restart the server and log back in as **ADATUM\Administrator** after the reboot.
4. Open Windows Explorer and extract the source files by running setup from the DVD drive.
5. Choose **C:\System Center Operations Manager** as the destination.
6. After extraction, open the **C:\System Center Operations Manager** folder on the C: drive.
7. Run Setup and from the Setup splash screen, click the large Install link to start the setup wizard.
8. Select **Management server**. Click Next.
9. Accept the default installation location and click Next.
10. Setup continues with the message Verifying that your environment has the required hardware and software. If issues are found, the message The Setup wizard cannot continue appears. This means additional hardware resources or software is required to continue. You can safely ignore amy yellow warning messages.
11. After resolving any prerequisite problems, click Verify Prerequisites Again. If verification is successful, click Next. 
12. At the Specify an installation option page, select Add a management server to an existing management group. Click Next.
13. Accept the license agreement and click Next.
14. Specify the database previously created by the setup process on the first management server: **LON-SV1**
  - Click in the server name or port number area to cause a validation process for the database server.
  - When Setup can validate the SQL Server of the operational database, the Database name drop-down list becomes active. Select the database name, OperationsManager by default.
  - Click Next. 
15. Configure Operations Manager accounts. Use the same accounts specified during the installation process on the first management server.
  - ADATUM\MSAA
  - ADATUM\SDK
16. After clicking Next, Setup verifies whether a specified action account is a domain administrator account. A warning box will state this is not recommended for security reasons. Click OK on the warning to proceed with setup.
  - CAUTION: DO NOT GIVE SERVICE ACCOUNT DOMAIN ADMIN PRIVILEGES
  - While it is convenient and often seen in lab and demo environments, the authors do not recommend making OpsMgr service accounts members of the Domain Admins global security group in production scenarios. The MSAA and SDK accounts (which should not be Domain Admins in normal practice) should be made members of the local Administrators group on management servers.
17. Finish the wizard with defauult options. Set Microsoft Update to **Off**.
18. At the Installation Summary page, review your selections. To continue, press Install.
19. Setup is complete when all green checkmarks appear.
20. If any component failed to install, it is marked with a red “X”. Check the setup log for error 1603. If this error appears then open server manager, features and remove the .NET Framework 3.5. Reboot and reinstall .NET Framework 3.5. Now setup will succeed.


## PowerShell Configuration for Agent Failover
PowerShell provides a quick way to determine the primary and failover management servers an agent is configured to use. The following command finds the primary management server for an agent:
```powershell
Get-SCOMAgent | where DisplayName -eq "LON-DC1.Adatum.com" | Select PrimaryManagementServerName
```
You can also use PowerShell to configure primary and failover management servers in OpsMgr. The following PowerShell script assigns the agent to a variable, defines the primary and failover management servers as variables, and then uses the Set-SCOMParentManagementServer cmdlet to assign the primary and the failover server for the agent.
```powershell
$SCOMAgent = Get-SCOMAgent -Name "LON-DC1.Adatum.com"
$Primary = Get-SCOMManagementServer -Name "LON-SV1.adatum.com"
$Failover = Get-SCOMManagementServer -Name "LON-SV2.adatum.com"
Set-SCOMParentManagementServer -Agent $scomAgent -PrimaryServer $Primary
Set-SCOMParentManagementServer -Agent $scomAgent -FailoverServer $Failover
```


### Only required for SCOM 2012
1. The Microsoft System CLR Types for Microsoft SQL Server are required before installing a second Management Server. Please install this
2. SCOM does not check on the existence of .NET Framework. Don’t forget to enable  .NET Framework 3.5.1 before beginning installation!
3. To install .NET Framework using Server Manager, select **Add roles and features** from the Dashboard.
4. To install .NET Framework using PowerShell, enter this command: ```Install-WindowsFeature NET-Framework-Core```
