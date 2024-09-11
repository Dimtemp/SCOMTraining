## Installing ACS on a Management Server
To deploy ACS, first install ACS on a management server, which creates the collector and the ACS audit database. Make sure you run this exercise as ADATUM\Admin by openining a command prompt and entering tis command: 'whoami'.
Follow these steps:
1. Run Setup from the Operations Manager DVD, and from the splash screen, click the Audit collection services link in the Optional Installations section.
2. Click Next at the Welcome to the Audit Collection Services Collector Setup wizard page. Accept the license agreement and click Next.
3. On the Database Installations Options page, select Create a new database. Click Next.
4. On the Data Source page, accept the default Open Database Connectivity (ODBC) data source name of OpsMgrAC and click Next.
5. On the Database page, select Database server running locally. Accept the default database name of OperationsManagerAC and click Next.
6. On the Database Authentication page, select Windows authentication and click Next.
7. On the Database Creation Options page, specify the SQL Server default directories, and click Next. 
8. On the Event Retention Schedule page, select to accept the default settings, of 02:00 AM local time to perform daily database maintenance and retain 14 days of security events in the ACS audit database. Click Next.
9. On the ACS Stored Timestamp Format page, select the default to use local time zone timestamps and click Next.
10. Click Next to begin the installation. Enter adatum\administrator, Pa$$w0rd if prompted.

## Deploying ACS Reporting to an Reporting Services Instance
1. Copy the ACS folder (and all files and subfolders) from the ReportModels folder of the System Center Operations Manager DVD to the root of the C:\ drive of LON-SV1. This creates a C:\ACS folder with some subfolders on the Reporting Services computer.
2. Open a command prompt in elevated mode on LON-SV1 and run the following command in the C:\ACS folder:
```UploadAuditReports <AuditDBServer> <Reporting Server Web Service URL> <ACS folder>```
For example:
```UploadAuditReports  LON-SV1  http://LON-SV1/reportserver  C:\ACS```
3. Running this command successfully produces output which, at first glance, appears to contain warnings, but actually are empty error lists, and this is an expected output.
4. Browse to the Reporting Services Report Manager URL (http://LON-SV1/Reports) and open the Audit Reports folder. Click the View button on the right of the screen and select Show Hidden Items. Click on the DBAudit data source and confirm that the connection string mentions Windows integrated security.

## Enabling ACS Forwarders
Audit collection is enabled in the Operations console from the Monitoring -> Operations Manager views. Enable audit collection first for all management servers and gateways, then for all agents.

Follow these steps:
1. Navigate to the Monitoring -> Operations Manager -> Management Server -> Management Servers State view.
2. Select the management server from the second panel (not the one with this title: Management Server State from Health Service Watcher) and click the Enable Audit Collection task. This task enables and configures the Audit Collection Service on the appropriate Operations Manager Health Service.
3. Click Run.
4. Repeat steps 2 and 3, this time from the Operations Manager -> Agent Details -> Agents by Version view in the Monitoring space. Select all agents and run the Enable Audit Collection task.

## ACS Retention
To modify the retention period, you can use the AdtAdmin.exe tool with the /setpartitions switch, or follow these steps to modify the retention period manually:
1. Log on to the computer running SQL Server hosting the audit database with an account that has administrative rights to that database.
2. Open SQL Server Management Studio, and connect to the database engine.
3. Expand the Databases folder, and select the **OperationsManagerAC** database.
4. Right-click to open the context menu and select New Query.
5. In the Query pane, type the following, where the Value-field equals the number of days you want to pass before data that has aged is groomed out. For example, if you want to retain data for 30 days, enter 31.
```
USE OperationsManagerAC
UPDATE dtConfig SET Value = 31 WHERE Id = 6
```
6. Click the Execute button on the toolbar. This runs the query and then opens the Messages pane, which should read (1 row(s) affected).
7. Restart the Operations Manager Audit Collection Service on the ACS collector for this to take effect.
