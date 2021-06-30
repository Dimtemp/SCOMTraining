# Chapter: Backup and Recovery

## Preparation
1. Log on to the lab server using RDP and open an internet browser.
2. Download the SQL Server Management Studio to your desktop from this URL: https://go.microsoft.com/fwlink/?linkid=2043154.
3. If the download is ready, right click the file on the desktop and select copy.
4. Open Hyper-V Manager and open a connection to the LON-SV1 VM. Make sure you're using Enhanced session.
5. Log on to LON-SV1 as Adatum\Administrator.
6. In the LON-SV1 VM, right click the desktop and click paste.
7. When the file has been pasted, doubleclick it to install SQL Server Management Studio. 
8. Follow the wizard to install SQL Server Management Studio.

## Operations Manager Database Backups using SQL Server Management Studio
1. Open SQL Server Management Studio and navigate to Databases -> OperationsManager.
2. Right-click the OperationsManager database, select Tasks, and then choose Back Up to bring up the Back up Database General page.
3. The default backup type is Full, which is the backup type used for the OperationsManager database. This backup type backs up the entire database file, rather than just the changes since the previous backup.
  - Because the OpsMgr databases have a simple recovery model by default, the transaction log is truncated as each transaction completes, meaning you cannot do an transaction log backup unless you change the recovery model in the database options to Full.
4. Under Destination, select the backup destination as Disk, which is the default.
5. Select Add under Destination. The wizard provides a default location. To enter the location and filename where the backup will be stored, click on the button with the ellipsis (...), and name the file OperationsManager_Full_OMGRP.bak. Click OK.
6. SQL Server Management Studio next displays the Select Backup Destination dialog. Click OK to confirm the destination.
7. After specifying the general requirements for the backup, select the Options page. You must decide whether you will override the backup set (file). By default, SQL Server appends the current backup to the end of the backup file if it already exists. Alternatively, you can overwrite (replace) the file. The option to truncate the transaction log is grayed out because the database recovery type is defined as simple (unless changed when configuring Log Shipping).
8. Selecting the Script option at the top of the dialog box generates Transact SQL code you can use to schedule the backup rather than having to return to SQL Management Studio each time you want to back up the database. Once the script is generated, the progress status shows that scripting completed successfully.
9. After generating the script, select the Script menu at the top of the panel (the down-arrow next to the script button) to bring up the scripting options. Sveral options appear:
  - Script Action to New Query Window
  - Script Action to File
  - Script Action to Clipboard
  - Script Action to Job
10. To schedule the backup as a SQL job, select the Script Action to Job option.
11. Select the Schedules page and click New to add a new schedule.
12. You can now define the details of the schedule. Create a Schedule type of Recurring with a backup frequency of Daily and a start time of 3:00:00 AM. Click OK to save the job.
13. In SQL Server Management Studio, navigate to SQL Server Agent, Jobs, right click the job created in step 10 and click Start Job at Step…
14. Confirm that the backup has successfully completed. Also verify the contents of the backup folder.

## Optional exercise: Performing Operations Manager Database Restores
### Warning! This exercise might cause your environment to malfunction. Proceed with care.
Follow these steps to restore the operational database:
1. Stop both System Center * services and the Microsoft Monitoring Agent Service on your management server to ensure Operations Manager will not try to write data to the database.
2. Before performing a full restore for a SQL Server database, you must delete the existing database. Launch SQL Server Management Studio -> Databases -> OperationsManager. Right-click the database and select Delete. Uncheck the option to delete and back up and restore history information from the database; check the option to close existing connections; then click OK to delete the operational database.
3. Restore the database from the most recent backup. Right-click Databases and select Restore Database. In the Source for Restore section, select From Database, and select OperationsManager from the drop-down list. This displays the Restore Database page.
4. If you have more than one backup, verify you selected the latest one for restore and click OK to begin the restore process. Depending on the size of your database, this may take several minutes.
5. Open the Properties of the OperationsManager database, click Options and enable the broker (true). If you omit this step, eventually an alert about the SQL Broker will appear.
6. Start the services you disabled on your management servers in step 1 and verify you can open the SCOM Console.

## Optional exercise: backup the database using TSQL commands
1. Open a command prompt.
2. Enter this command to create a backup folder: ```mkdir C:\Backup```
3. Enter this command to open the interactive SQL utility: ```sqlcmd```
4. A prompt appears.
5. Enter this command to inspect the names of the existing databases: ```SELECT Name FROM sys.databases```
5. Enter this command to start the backup of the primary Operations Manager database: ```BACKUP DATABASE  OperationsManager TO DISK = 'C:\Backup\opsmgr.bak'```
5. Enter this command to start the backup of the primary Operations Manager database using compression: ```BACKUP DATABASE  OperationsManager TO DISK = 'C:\Backup\opsmgr_compressed.bak' WITH COMPRESSION```
6. Inspect the contents of the C:\Backup folder. Notice the last backup will be a lot smaller.
