# Install the report server

## Confirming Installation Readiness of the Reporting Server
Verify that Reporting Services is configured correctly and running before attempting to install the OpsMgr Reporting server feature. Spending several minutes confirming readiness can save a significant amount of time recovering from a setup failure. Follow these steps to install a reporting server running SQL Server Reporting Services:
1. Open a PowerShell console and run this command:
```PowerShell
> Get-Service SQLSERVERAGENT | Set-Service -StartupType Automatic -Passthru | Start-Service
```
1. Open Services from the Administrative Tools.
1. Verify that the SQL Server Agent Service is running and set to automatic.
1. Click Start -> Programs -> Microsoft SQL Server -> Configuration Tools -> Reporting Services Configuration Manager. Connect to the instance on which you installed Reporting Services (LON-SV1).
1. Confirm the Report Service Status is Started in the central pane. In the navigation pane, select Report Manager URL. This displays the Report Server virtual directory Uniform Resource Locator (URL) as a hyperlink in the central pane.
1. Click on the Report Manager URL hyperlink such as http://LON-SV1:80/Reports. You may be prompted to enter your domain credentials again to open the Report Manager web page.
1. If you are able to view an empty but functional Reporting Services home page, you are ready to install the OpsMgr Reporting service role.


## Install the Operations Manager Reporting Server
After confirming readiness of the local Reporting Services instance, perform the following steps from the Operations Manager Setup.
1. Open Windows Explorer.
1. Navigate to C:\System Center Operations Manager 2019.
1. Run setup.exe
1. From the splash screen click the large Install link to start a setup wizard.
2. In the Select features to install dialog box, select Reporting server. Click Next.
3. Accept the default installation location and click Next.
1. Setup continues with the message Verifying that your environment has the required hardware and software. If there are issues, the message The Setup wizard cannot continue appears. This means additional hardware resources or software is required to continue.
1. After resolving any prerequisite problems, click Verify Prerequisites Again. If verification is successful, click Next.
1. At the Specify a Management server page, enter the name of a management server to be used by the reporting features only: in this case LON-SV1. The specified server will handle data associated with specific management servers or management groups. Normally, this is either the name of the first OpsMgr management server you installed, or if you are using a load-balanced management server pool, specify the virtual server name of the pool. Click Next.
1. At the SQL Server instance for Reporting Services page, select the SQL Server instance on which you want to host Reporting Services. In the SQL Server instance drop-down box, select LON-SV1. Click Next.
1. Configure Operations Manager accounts as discussed.
  1. Select to use a domain account for the Data Reader account. This account is used to deploy reports, is used by Reporting Services to run queries against the data warehouse, and is the Reporting Services Internet Information Services (IIS) Application Pool account that connects to a management server.
1. At the Help improve System Center Operations Manager page, indicate if you want to participate in Operational Data Reporting (ODR).
  1. Operational data reports summarize how Operations Manager is running in your management group and help Microsoft determine which features its customers are using. The ODR report folder is installed automatically in every management group, even if you elect not to consent to send the data to Microsoft.
  1. You can preview the information Microsoft can see, such as the names of management packs and overrides loaded, by running the ODR reports manually in the Reporting space of the Operations console after installing OpsMgr reporting.
  1. If you agree to send operational data reports to Microsoft, ODR reports are generated weekly from the data in the Operations Manager data warehouse and the information sent to Microsoft. Select Yes to participate anonymously and automatically send your operational data reports, or No to not participate. Click Next.
1. At the Installation Summary page, review your selections for the feature you are installing. To continue, press Install.
1. Setup is complete when all green checkmarks appear in the left column. Any component that failed to install is marked with a red “X.”


## Confirming Successful Deployment of the Reporting Server
1, After the reporting server is deployed, it can take up to 30 minutes for reports to appear in the Reporting space of the Operations console. You also must close and reopen each open instance of the console to expose the Reporting button in the navigation pane of the console.
1. After waiting a short while, close and reopen the Operations console and navigate to the Reporting space. Select the Microsoft ODR Report Library report folder in the navigation pane, and then double-click on any of the ODR reports in the central pane, such as Management Packs. The selected report is generated and displayed in a new window. Close the report window when done.

