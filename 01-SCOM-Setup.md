# Chapter: Installing System Center Operations Manager

## Prepare environment
1. Open Hyper-V Manager.
1. Make sure the LON-DC1 VM is running. If it is not, start it and wait for the boot procedure.
1. Start LON-SV1 and log on as Adatum\Administrator.
1. Open a PowerShell console.
1. Run this command: 
1. New-ADOrganizationalUnit SCOM
1. $pw = ConvertTo-SecureString 'Pa55w.rd' -AsPlainText -Force
1. 'MSAA', 'SDK', 'DRA', 'DWA' | foreach { New-ADUser -AccountPassword $pw -Name $_ -Path 'OU=SCOM,DC=Adatum,DC=msft' -Enabled $true }
1. ADD-ADGroupMember -Identity 'Domain Admins' -Members 'MSAA', 'SDK'
1. Get-Service SQLSERVERAGENT | Set-Service -StartupType Automatic -Passthru | Start-Service   # tbv Reporting
1. Open Active Directory Users and Computers from the Administrative Tools.
1. Verify the four service accounts you just created using PowerShell.
1. Open Services from the Administrative Tools.
1. Verify that the SQL Server Agent Service is running and set to automatic.


## Run the Operations Manager setup
1. Open Windows Explorer.
1. Navigate to C:\System Center Operations Manager 2019.
1. Run setup.exe
1. Run Setup. From the splash screen click the large Install link to start the setup wizard.
1. Select Management server and Operations console. Clicking the expand arrow to the right of a feature exposes a drop-down description of the feature. Click Next.
1. On the next screen, select Installation location. Accept the default, and click Next.
1. Setup continues with the message Verifying that your environment has the required hardware and software.  If there are issues, the message The Setup wizard cannot continue appears. This means additional hardware resources or software is required to continue.
1. Resolve any prerequisite issues (for instance, follow the link to install the Report Viewer).
1. After resolving any prerequisite problems, click Verify Prerequisites Again. If the verification is successful, click Next. 
1. At the Specify an installation option page, create the first management server in a new management group. Type this name for management group: OMGRP. After you create a management group, you cannot change its name without reinstalling the management group.
1. Click Next.
1. Accept the license agreement by selecting I have read, understood, and agree with the license terms and clicking Next. 
1. Configure the operational database. The setup process creates and configures the database:
▶ Type the server name (LON-SV1) of the SQL Server to be used for the operational database.
▶ Click again in the server name or port number area to cause a validation process for the database server. Notice there is no option to use an existing database; you cannot install OpsMgr 2012 using a pre-created database.
▶ If there is an error validating the SQL Server, a red “X” icon appears to the left of the server name. Hover over the icon to read the details on the database error. 
▶ Once Setup validates the SQL Server for the operational database, the Database name section of this page becomes modifiable. Leave the default database name of OperationsManager and size of 1000MB. Click Next. 
9. Configure the data warehouse database. Unlike the operational database installation step, there is an option to use an existing data warehouse database.
▶ Type the server name and instance name of the SQL Server to be used for the data warehouse database.
▶ Click again in the server name or port number area to initiate a validation process for the database server. If you have implemented a central data warehousing solution, multiple management groups are able to share a common data warehouse database.
▶ If there is an error validating the SQL Server, a red “X” icon appears to the left of the server name. Hover over the icon to read the details on the database error. 
▶ Once Setup validates the SQL Server for the data warehouse database, the Database name section of the page becomes modifiable. For a new installation, leave the default database name of OperationsManagerDW and size of 1000MB. Click Next. 
10. Configure the Operations Manager accounts. Use the service accounts you have previously created.
▶ The management server action account is typically a named domain user account. This account is used to gather operational data from providers and perform actions such as installing and uninstalling agents on managed computers. This example uses MSAA as the management server action account, which must be a member of the local Administrators group on the management server.
▶ The System Center Configuration service and System Center Data Access service account can run as Local System if the SQL Server for the operational and data warehouse databases is installed locally on the management server (a single server deployment). This credential reads and updates information in the operational database and is assigned the sdk_user role in this database. This example uses SDK as the System Center Configuration service and System Center Data Access service account. Like the management server action account (MSAA), this account must be a member of the local Administrators group on the management server.
▶ The Data Reader and Data Writer accounts must be named domain user accounts. The Data Reader account is used to deploy reports; it is the user account Reporting Services uses to run queries against the data warehouse. The Data Reader account is also used as the Reporting Services IIS Application Pool account that connects to a management server. The Data Writer account reads data from the operational database and writes data from a management server to the data warehouse database.
After clicking Next, Setup verifies whether a specified action account is a domain administrator account. If this is the case, click OK on the warning to proceed with setup if this is your intention.
11. At the Help improve System Center 2012 Operations Manager page, indicate your desire to participate in these programs. These settings can be changed after installation in the Operations console at Administration -> Settings -> General -> Privacy.
▶ Customer Experience Improvement Program: Participating anonymously helps Microsoft collect data about your use of OpsMgr to identify possible improvements for the product. An example is which menu items get used the most, and in what order.
▶ Error Reporting: Participating anonymously helps Microsoft identify common issues with OpsMgr when an error occurs, such as Dr. Watson.
12. At the Management Server Installation Summary page, review your selections for the features you are installing. To continue, select Install. Here are the main activities that occur during setup:
▶ An Installation progress page provides status on components as they are installed and configured. If there is a fatal setup error, the wizard will halt after performing a rollback.
▶ The operational and data warehouse databases are created in their respective SQL instances. SQL security roles such as apm_datareader and sdk_users are created in the operational database, and roles OpsMgrReader and OpsMgrWriter in the data warehouse database.
▶ Default management packs are imported into both databases.
▶ The Operations console and Operations Manager Shell user applications are installed and the management server services are installed and started. Here are the new services created during management server installation, and a description of the purpose of each:
•	Microsoft Monitoring Agent (Automatic start): The System Center Management service monitors the health of the computer and possibly other computers in addition to the computer it is running on (management servers, gateway servers, and computers running distributed applications may proxy management traffic to other computers).
•	Microsoft Monitoring Agent Audit Forwarding (Disabled): Sends events to an ACS collector for storage in a SQL database.
•	Microsoft Monitoring Agent APM (Disabled): Monitors the health of .NET applications on this computer.
•	System Center Data Access Service (Automatic start) : Reads and writes to the SQL Server databases.
•	System Center Management Configuration (Automatic start) : Maintains the configuration of the management group for all management servers.
TIP: CHECK OUT THE ONLINE RELEASE NOTES DURING SETUP   During setup (which may take some time), click the link to review the online release notes (http://technet.microsoft.com/en-us/library/hh561709.aspx) for the latest information. The top portion of the release notes is an index of sections such as Installation and Management Servers—clicking on these links takes you to the portion of the release notes dealing with that subject.
14. Setup is complete when all green checkmarks appear in the left column. Any component that failed to install is marked with a red “X.”
▶ Make sure you don’t install updates and start the management console. Click Close to complete the wizard.

## Confirming Installation Readiness of the Reporting Server
Verify that Reporting Services is configured correctly and running before attempting to install the OpsMgr Reporting server feature. Spending several minutes confirming readiness can save a significant amount of time recovering from a setup failure. Follow these steps to install a reporting server running SQL Server Reporting Services:
1. Click Start -> Administrative Tools -> Services. Select SQL Server Agent and open the properties. 
a.	Set the startup type to automatic
b.	start the service SQL Server Agent service and click Ok.
2. Click Start -> Programs -> Microsoft SQL Server 2012 -> Configuration Tools -> Reporting Services Configuration Manager. Connect to the instance on which you installed Reporting Services (LON-SV1).
3. Confirm the Report Service Status is Started in the central pane. In the navigation pane, select Report Manager URL. This displays the Report Server virtual directory Uniform Resource Locator (URL) as a hyperlink in the central pane.
4. Click on the Report Manager URL hyperlink such as http://LON-SV1:80/Reports. You may be prompted to enter your domain credentials again to open the Report Manager web page.
5. If you are able to view an empty but functional Reporting Services home page, you are ready to install the OpsMgr Reporting service role.

## Install the Operations Manager Reporting Server
After confirming readiness of the local Reporting Services instance, perform the following steps from the Operations Manager DVD (from D:\):
1. Run Setup; from the splash screen click the large Install link to start a setup wizard.
2. In the Select features to install dialog box, select Reporting server. Click Next.
3. Select Installation location. The default location is %Programfiles %\System Center 2012\Operations Manager. Accept the default and click Next.
4. Setup continues with the message Verifying that your environment has the required hardware and software. If there are issues, the message The Setup wizard cannot continue appears. This means additional hardware resources or software is required to continue.
5. After resolving any prerequisite problems, click Verify Prerequisites Again. If verification is successful, click Next.
6. At the Specify a Management server page, enter the name of a management server to be used by the reporting features only. The specified server will handle data associated with specific management servers or management groups. Normally, this is either the name of the first OpsMgr 2012 management server you installed, or if you are using a load-balanced management server pool, specify the virtual server name of the pool. Click Next.
7. At the SQL Server instance for Reporting Services page, select the SQL Server instance on which you want to host Reporting Services. In the SQL Server instance drop-down box, select LON-SV1. Click Next.
8. Configure Operations Manager accounts as discussed.
Select to use a domain account for the Data Reader account. This account is used to deploy reports, is used by Reporting Services to run queries against the data warehouse, and is the Reporting Services Internet Information Services (IIS) Application Pool account that connects to a management server.
9. At the Help improve System Center 2012 Operations Manager page, indicate if you want to participate in Operational Data Reporting (ODR).
a.	Operational data reports summarize how Operations Manager is running in your management group and help Microsoft determine which features its customers are using. The ODR report folder is installed automatically in every management group, even if you elect not to consent to send the data to Microsoft.
b.	You can preview the information Microsoft can see, such as the names of management packs and overrides loaded, by running the ODR reports manually in the Reporting space of the Operations console after installing OpsMgr reporting.
c.	If you agree to send operational data reports to Microsoft, ODR reports are generated weekly from the data in the Operations Manager data warehouse and the information sent to Microsoft. Select Yes to participate anonymously and automatically send your operational data reports, or No to not participate. Click Next.
10. At the Installation Summary page, review your selections for the feature you are installing. To continue, press Install.
11. Setup is complete when all green checkmarks appear in the left column. Any component that failed to install is marked with a red “X.”

## Confirming Successful Deployment of the Reporting Server
After the reporting server is deployed, it can take up to 30 minutes for reports to appear in the Reporting space of the Operations console. You also must close and reopen each open instance of the console to expose the Reporting button in the navigation pane of the console.
After waiting a short while, close and reopen the Operations console and navigate to the Reporting space. Select the Microsoft ODR Report Library report folder in the navigation pane, and then double-click on any of the ODR reports in the central pane, such as Management Packs. The selected report is generated and displayed in a new window. Close the report window when done.

## If time permits: Install the Web console
1. On the LON-SV1 Server, open a PowerShell prompt and enter this command:
Install-WindowsFeature Web-Windows-Auth, Web-Asp-Net, Web-Request-Monitor, NET-WCF-HTTP-Activation45, Web-Mgmt-Console, Web-Metabase
1. Run Setup from the Operations Manager DVD, and from the splash screen, click the large Install link to start the setup wizard. After the Launching Operations Manager Setup splash screen, you will see the Select features to install dialog.
1. Select Web console. Click Next.
1. Select Installation location. Accept the default or specify your alternative path, and click Next.
1. Setup continues with the message Verifying that your environment has the required hardware and software. If issues are found, the message The Setup wizard cannot continue appears. This means additional hardware resources or software are required to continue.
1. After resolving any prerequisite problems, click Verify Prerequisites Again. If the verification is successful, click Next.
1. At the Specify a Management server page, enter the name of a management server to be used by the Web console only. The management server you specify will handle data associated with specific management servers or management groups. Normally, this is the name of the first installed management server, or if using a load-balanced management server pool, the virtual server name of the pool. Click Next.
1. At the Specify a web site for use with the Web console page, select an IIS web site to be used for the Web console. Select an existing web site from the available web sites on the local IIS server. The Default Web Site is the default setting.
1. At the Select an authentication mode for use with the Web console page, select Mixed authentication mode. Click Next.
Note: If you are publishing the Web console to the Internet, select Use Network Authentication. Use Mixed Authentication only if you are using the Web console in intranet scenarios. 
1. At the Web console Installation Summary page, review your selections. Take note of the Uniform Resource Locators (URLs) to be used for accessing the Web console and APM features. To continue, press Install.
1. Setup is complete when all green checkmarks appear in the left column. Any component that failed to install is marked with a red “X.” You will also want to Exit the OpsMgr installer that is still open.
1. Configure permissions inheritance for the Web console:
▶ In Windows Explorer, navigate to C:\Program Files\System Center\Operations Manager\WebConsole\MonitoringView), right-click the TempImages folder, and click Properties.
▶ On the Security tab, click Advanced.
▶ On the Permissions tab, select Change Permissions.
▶ Clear the Include inheritable permissions from this object’s parent check box.
▶ In Permission entries, click Administrators, and then click Remove. Repeat for the SYSTEM entry, and then click OK.
▶ Click OK to close Advanced Security Settings for TempImages, and then click OK to close TempImages Properties.
The first time you access the Web console with your browser, you are prompted to install or update Silverlight if needed. It may be necessary to add the website of the Web console to your browser’s trusted sites.

If the Web console is not functioning then perform this procedure.
1.	Open Windows Explorer and navigate to c:\windows\temp. Open the properties.
2.	Open Security tab and select IIS-IUSR. In the permissions list select modify in the Allow column and click Ok.
3.	Open a PowerShell prompt and enter this command: iisreset.
4.	Try to reload the Web Console.

Now would be a great time to create a checkpoint (snapshot) of your virtual machines, so you can revert to the current situation in case of an emergency. Open Hyper-V Manager, select LON-DC1 and LON-SV1 and click Checkpoint. Verify that a snapshot has been created from these two machines.
