## If time permits: Install the report server
An installation might take 10-20 minutes at the and of this exercise. That might be a good time to take a coffee break.

## Install dotnet 4.8
1. Log on to the LON-SV1 VM as ADATUM\Admin.
1. In the LON-SV1 VM, open Windows Explorer and navigate to E:\Lib\dotnet.
1. Start the ndp48-x86-x64-allos-enu setup.
1. Use default values during setup.
1. The installation might take 1 or 2 minutes.
1. Restart the VM after setup finishes.


## Install SQL Server Reporting Services
1. In the LON-SV1 VM, open Windows Explorer and navigate to E:\Lib\SSRS.
1. Start the **SQLServerReportingServices** setup file.
1. Select Yes on the confirmation window.
1. From the setup window, click **Install Reporting Services**.
1. Finish the setup using the default values.
1. At the end of the setup, click the **Configure report server** button.
1. The Report Server Configuration Manager opens.
1. Connect to the instance on which you installed Reporting Services (LON-SV1).
1. Confirm the Report Service Status is Started.
1. Click the Database tile in the left panel.
1. Click Change Database.
1. Make sure Create a new report server database is selected, and click Next.
1. Follow the wizard using all default values.
1. Click the Web Service URL tile in the left panel and click Apply.
1. Click the Web Portal URL tile in the left panel and click Apply.


## Configuring the SQL Server Agent service
Follow these steps to configure the SQL Server Agent service, which is a requirement for the Operations Manager reporting feature:
1. Open an elevated PowerShell console (Run as Administrator) and run this command:
```PowerShell
> Get-Service SQLSERVERAGENT | Set-Service -StartupType Automatic -Passthru | Start-Service -Passthru
```
1. Verify that the SQL Server Agent Service is running. If it is not, repeat the previous PowerShell command.


## Install the Operations Manager Reporting Server
After confirming readiness of the local Reporting Services instance, perform the following steps from the Operations Manager Setup.
1. Open Windows Explorer.
1. Navigate to C:\System Center Operations Manager.
1. Run setup.exe elevated (Run as Administrator).
1. From the splash screen click the large Install link to start a setup wizard.
1. Select Add a feature.
1. In the Select features to install dialog box, select Reporting server. Click Next.
1. Setup continues with the message Verifying that your environment has the required hardware and software. If there are issues, the message The Setup wizard cannot continue appears. This means additional hardware resources or software is required to continue. The yellow Pending Restart Check can be ignored.
1. After resolving any prerequisite problems, click Verify Prerequisites Again. If verification is successful, click Next.
1. At the SQL Server instance for Reporting Services page, select the SQL Server instance on which you want to host Reporting Services. In the SQL Server instance drop-down box, select LON-SV1\SSRS. Click Next.
1. Configure Operations Manager accounts as discussed in a previous exercise:
  - ADATUM\SDK
  - ADATUM\DRA
  - The Data Reader account is used to deploy reports, is used by Reporting Services to run queries against the data warehouse, and is the Reporting Services Internet Information Services (IIS) Application Pool account that connects to a management server.
1. Turn Microsoft Update Off.
1. At the Installation Summary page, review your selections for the feature you are installing. To continue, press Install.
1. This might take 10-20 minutes (remeber to take a coffee break).
1. Setup is complete when all green checkmarks appear in the left column. Any component that failed to install is marked with a red "X".


## Confirming Successful Deployment of the Reporting Server
1. Close and reopen each Operations Manager console to expose the Reporting button in the navigation pane of the console.
1. After the reporting server is deployed, it can take up to 30 minutes for reports to appear in the Reporting space of the Operations console.
1. Select the Microsoft ODR Report Library report folder in the navigation pane, and then double-click on any of the ODR reports in the central pane, such as Management Packs. The selected report is generated and displayed in a new window. Close the report window when done.


## A bit more info on ODR
- Operational data reports summarize how Operations Manager is running in your management group and help Microsoft determine which features its customers are using. 
- The ODR report folder is installed automatically in every management group, even if you elect not to consent to send the data to Microsoft.
- You can preview the information Microsoft can see, such as the names of management packs and overrides loaded, by running the ODR reports manually in the Reporting space of the Operations console after installing OpsMgr reporting.
- If you agree to send operational data reports to Microsoft, ODR reports are generated weekly from the data in the Operations Manager data warehouse and the information sent to Microsoft. Select Yes to participate anonymously and automatically send your operational data reports, or No to not participate. Click Next.
