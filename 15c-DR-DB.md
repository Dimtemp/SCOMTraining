# Chapter: Backup and Recovery

## SQL Server Management Studio installation
1. On the LON-SV1 VM, open Windows Explorer and navigate to the Lib (E:) drive.
1. Open the SSMS folder and run the SSMS-Setup-ENU. This starts the SQL Server Management Studio installation.
1. Follow the wizard to install SQL Server Management Studio.
1. Process to the next exercise during installation.


## Backup the database using TSQL commands
1. Open an elevated PowerShell console (Run as Administrator).
1. Enter this command to create a backup folder: ```mkdir C:\Backup```
1. Enter this command to open the interactive SQL utility: ```sqlcmd```
1. A prompt appears.
1. Enter this command to inspect the names of the existing databases: ```SELECT Name FROM sys.databases```
1. Enter this command to start execution: ```GO```
1. Identify the names of both Operations Manager databases.
1. Enter this command to start the backup of the primary Operations Manager database: ```BACKUP DATABASE  OperationsManager TO DISK = 'C:\Backup\opsmgr_full.bak'```
1. Enter this command to start the backup of the primary Operations Manager database using compression: ```BACKUP DATABASE  OperationsManager TO DISK = 'C:\Backup\opsmgr_compressed.bak' WITH COMPRESSION```
1. Enter this command to start execution of the two previous commands: ```GO```
1. Inspect the contents of the C:\Backup folder. Notice the last backup will be a lot smaller.
1. Make a note or screenshot of the database backup files including the size.


## Operations Manager Database Backups using SQL Server Management Studio
1. Click Start, hold shift and rightclick the **Microsoft SQL Server Management Studio**.
1. Use the ADATUM\Administrator account to start the management studio.
1. Click Connect.
1. Navigate to Databases -> OperationsManager.
1. Right-click the **OperationsManager** database, select **Tasks**, and then choose **Back Up** to bring up the Back up Database General page.
1. The default backup type is Full, which is the backup type used for the OperationsManager database. This backup type backs up the entire database, rather than just the changes since the previous backup.
  - Because Operations Manager databases have a simple recovery model by default, the transaction log is truncated as each transaction completes, meaning you cannot do a transaction log backup unless you change the recovery model in the database options to Full. This is further discussed in the Log Shipping exercise.
  - The option to truncate the transaction log is grayed out because the database recovery type is defined as simple (unless changed when configuring Log Shipping).
1. Leave all options at their default setting. 
1. Notice the backup destination is the same as the command from the PowerShell console.
1. Select the Options page.
1. At **Set backup compression** select **Compress backup**.
1. Click OK.
1. Open Windows Explorer and navigate to the C:\Backup folder. 
1. Notice the last backup is included in the scom_compress.bak file. This file now holds two separate backups. By default, SQL Server appends the current backup to the end of the backup file if it already exists. Alternatively, you can overwrite (replace) the file. 


## Scheduled job
1. Return to the Management Studio.
1. Navigate to Databases -> OperationsManager.
1. Right-click the **OperationsManager** database, select **Tasks**, and then choose **Back Up** to bring up the Back up Database General page.
1. Notice the backup destination is the same as the command from the PowerShell console.
1. Select the down arrow to the right of the Script option at the top of the dialog box.
1. Choose **Script Action to Job**.
1. This generates Transact SQL code you can use to schedule the backup rather than having to return to SQL Management Studio each time you want to back up the database.
1. Select the Schedules page and click New to add a new schedule.
1. Create a Schedule type of Recurring with a backup frequency of Daily and a start time of 3:00:00 AM. Click OK to close the schedule window.
1. Click OK to save the job.
1. Navigate to SQL Server Agent, Jobs.
1. Locate the job with the name you used while creating the job.
1. Right click the job created in step 10 and click Start Job at Step...
1. Since the job contains only 1 step it executes immediately.
1. Confirm that the backup has successfully completed.
1. Verify the contents of the backup folder.


## Optional exercise: Performing Operations Manager Database Restores
### Warning! This exercise might cause your environment to malfunction. Proceed with care.
Follow these steps to restore the operational database:
1. Open Services.msc and stop the following services to ensure Operations Manager will not try to write data to the database:
  - Microsoft Monitoring Agent
  - System Center Data Access Service
  - System Center Management Configuration
1. Launch SQL Server Management Studio
1. Navigate to Databases, OperationsManager.
1. Right-click the database and select Delete. 
  1. **Uncheck** the option to Delete backup and restore history information from the database
  1. **Check** the option to close existing connections
1. Click OK to delete the operational database.
1. Restore the database from the most recent backup. Right-click Databases and select Restore Database. In the Source for Restore section, select From Database, and select OperationsManager from the drop-down list. This displays the Restore Database page.
1. If you have more than one backup, verify you selected the latest one for restore and click OK to begin the restore process. Depending on the size of your database, this may take several minutes.
1. Open the Properties of the OperationsManager database, click Options and enable the broker (true). If you omit this step, eventually an alert about the SQL Broker will appear.
1. Start the services you previously disabled on your management server and verify you can open the SCOM Console.
