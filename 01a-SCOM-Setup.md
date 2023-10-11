# Chapter: Installing System Center Operations Manager

## Prepare environment
1. Open Hyper-V Manager.
1. Verify the LON-SV1 VM has at least 8 GB of RAM. If it has less the open the **Settings* for the VM, select Memory, and specify at least 8 GB of RAM.
1. Start the LON-DC1 VM and wait for the boot procedure.
1. Start the LON-SV1 VM and wait for the boot procedure.
1. On the host, click Start and click Windows PowerShell ISE.
1. Click View, click Show Script pane.
1. Run these commands:
```PowerShell
Get-VM|Enable-VMIntegrationService -Name 'Guest Service Interface'
dir C:\Hyper-V\ *.msi -Recurse | foreach { Copy-VMFile -name LON-SV1 -SourcePath $_.FullName -DestinationPath C:\ -FileSource Host }
```
1. Open Hyper-V Manager, rightclick LON-SV1 and click Connect.
1. Make sure you enable a full screen resolution.
1. Log on as ADATUM\Administrator with the password **Pa55w.rd**
1. **Note!** If you're required to change your password, make sure you note down the new password somewhere! You're required to update a service with this password later.


## Prepare Active Directory
1. When logged on to the LON-SV1, click Start and click Windows PowerShell.
1. Run this command: ```ping LON-DC1 -t```
1. It is advised to keep this window running for the rest of the training.
1. Start and click Windows PowerShell ISE.
1. Click View, click Show Script pane.
1. Run these commands:
```PowerShell
  New-ADOrganizationalUnit SCOM
  $pw = ConvertTo-SecureString 'Pa55w.rd' -AsPlainText -Force
  'MSAA', 'SDK', 'DRA', 'DWA' | foreach { New-ADUser -AccountPassword $pw -Name $_ -Path 'OU=SCOM,DC=ADATUM,DC=msft' -Enabled $true }
  ADD-ADGroupMember -Identity 'Domain Admins' -Members 'MSAA', 'SDK'
```
1. Leave the PowerShell window open.
1. Open Active Directory Users and Computers from the Administrative Tools.
1. Verify the four service accounts you just created using PowerShell.
1. Return to the PowerShell window and execute this command to verify the SQL Server evaluation expiration date: ```sqlcmd -Q "SELECT CREATE_DATE INSTALLDATE, DATEADD(DD, 180, CREATE_DATE) AS EXPIRYDATE FROM SYS.SERVER_PRINCIPALS WHERE SID = 0X010100000000000512000000"```


## Run the Operations Manager setup
1. Navigate to C:\System Center Operations Manager.
1. Run setup.exe.
1. From the splash screen click the large Install link to start the setup wizard.
1. Select Management server and Operations console. Click Next.
1. On the next screen, select Installation location. Accept the default, and click Next.
1. Setup continues with the message "Verifying that your environment has the required hardware and software".  If there are issues, the message The Setup wizard cannot continue appears. This means additional hardware resources or software is required to continue.
1. Resolve any prerequisite issues.
1. After resolving any prerequisite problems, click Verify Prerequisites Again. If the verification is successful, click Next. 
1. At the Specify an installation option page, create the first management server in a new management group. Type this name for management group: **OMGRP**. After you create a management group, you cannot change its name without reinstalling the management group.
1. Click Next.
1. Accept the license agreement and click Next. 
1. Configure the operational database. Type the server name (**LON-SV1**) of the SQL Server to be used for the operational database.
1. Click again in the server name or port number area to cause a validation process for the database server.
1. If there is an error validating the SQL Server, a red “X” icon appears to the left of the server name. Hover over the icon to read the details on the database error. 
1. Leave the default database name of OperationsManager and size of 1000MB. Click Next. 
1. Type the **server name and instance name** of the SQL Server to be used for the data warehouse database: **LON-SV1**.
1. Click in the port number area to initiate a validation process for the database server.
1. If there is an error validating the SQL Server, a red “X” icon appears to the left of the server name. Hover over the icon to read the details on the database error. 
1. Leave the default database name of OperationsManagerDW and size of 1000MB. Click Next.
1. Configure the Operations Manager accounts. Use the service accounts you have previously created. You can copy and paste the following usernames:
  1. adatum\MSAA
  1. adatum\SDK
  1. adatum\DRA
  1. adatum\DWA
  1. All service accounts use the following password: Pa55w.rd
1. **NOTE.** In practice, it is not advised to re-use the same password for all services. For sake of simplicity we use just one password.
1. The management server action account is typically a named domain user account. This account is used to gather operational data from providers and perform actions such as installing and uninstalling agents on managed computers. This example uses MSAA as the management server action account, which must be a member of the local Administrators group on the management server.
1. The System Center Configuration service and System Center Data Access service account can run as Local System if the SQL Server for the operational and data warehouse databases is installed locally on the management server (a single server deployment). This credential reads and updates information in the operational database and is assigned the sdk_user role in this database. This example uses SDK as the System Center Configuration service and System Center Data Access service account. Like the management server action account (MSAA), this account must be a member of the local Administrators group on the management server.
1. The Data Reader and Data Writer accounts must be named domain user accounts. The Data Reader account is used to deploy reports; it is the user account Reporting Services uses to run queries against the data warehouse. The Data Reader account is also used as the Reporting Services IIS Application Pool account that connects to a management server.
1. The Data Writer account reads data from the operational database and writes data from a management server to the data warehouse database.
1. After clicking Next, Setup verifies whether a specified action account is a domain administrator account. If this is the case, click OK on the warning to proceed with the setup.
1. Turn Microsoft Update **Off**. Click Next.
1. At the Management Server Installation Summary page, review your selections for the features you are installing. To continue, select Install.


# Main activities that occur during setup
1. An Installation progress page provides status on components as they are installed and configured.
1. The operational and data warehouse databases are created in their respective SQL instances. SQL security roles such as apm_datareader and sdk_users are created in the operational database, and roles OpsMgrReader and OpsMgrWriter in the data warehouse database.
1. Primary management packs are imported into both databases.
1. The Operations console and Operations Manager Shell user applications are installed and the management server services are installed and started. Here are the new services created during management server installation, and a description of the purpose of each:
  1.  Microsoft Monitoring Agent (Automatic start): The System Center Management service monitors the health of the computer and possibly other computers in addition to the computer it is running on (management servers, gateway servers, and computers running distributed applications may proxy management traffic to other computers).
  1. Microsoft Monitoring Agent Audit Forwarding (Disabled): Sends events to an ACS collector for storage in a SQL database.  
  1. Microsoft Monitoring Agent APM (Disabled): Monitors the health of .NET applications on this computer.
  1. System Center Data Access Service (Automatic start) : Reads and writes to the SQL Server databases.
  1. System Center Management Configuration (Automatic start) : Maintains the configuration of the management group for all management servers.


### TIP: CHECK OUT THE ONLINE RELEASE NOTES DURING SETUP
During setup (which may take some time), click the link to review the online release notes:
https://learn.microsoft.com/en-us/system-center/scom/release-notes-om
1. Setup is complete when all green checkmarks appear in the left column. Any component that failed to install is marked with a red "X".
1. Make sure you don’t install updates. Click Close to complete the wizard.


## Create a checkpoint.
1. Now would be a great time to create a checkpoint (snapshot) of your virtual machines, so you can revert to the current situation in case of an emergency.
1. Minimize all Virtual Machine Connection sessions.
1. Open Hyper-V Manager, select both the LON-DC1 and LON-SV1 VM. Click Action and click Checkpoint.
1. Verify that a snapshot has been created from these two machines.
