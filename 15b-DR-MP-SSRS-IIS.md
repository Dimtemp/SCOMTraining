## Backing Up Management Packs from the console
The Operations console only allows you to export unsealed management packs. To use the Operations console to back up and restore management packs, follow theses steps:
1. Create a folder C:\Backup.
2. In the Operations console, navigate to Administration -> Management Packs. In the Details pane, right-click any unsealed management pack to bring up the option to Export Management Pack (this option is grayed out for sealed management packs).
3. Select C:\Backup.
4. Open the file you just created in the C:\Backup folder and verify it’s a XML file.

## Backing Up Management Packs from PowerShell
You can back up (export) unsealed management packs in an ad-hoc manner using the Operations console. This technique is discussed in Chapter 13, “Administering Management Packs.” For purposes of regularly scheduled jobs, the authors recommend you back up your unsealed management packs in a batch mode, using PowerShell cmdlets to export the management packs. As sealed management packs are not modified, you should only need to export unsealed management packs. Open the Operations Manager Shell from Start -> All Programs -> Microsoft System Center -> Operations Manager. From the Operations Manager Shell execute this command:
```powershell
Get-SCOMManagementPack | Where Sealed -eq $false | Export-SCOMManagementPack -Path C:\Backup
```

## Backing Up Reporting Services Encryption Keys
The Reporting Services setup process creates encryption keys that are used to secure credentials, connection information, and accounts used with server operations. If you should need to rebuild or repair your Reporting Services installation, you must apply the key to make the ReportServer database operational. If you cannot restore the key, database recovery will require deleting the encrypted data and re-specifying any values that require encryption. You can use the RSKeyMgmt.exe utility to extract a copy of the encryption key from the ReportServer database. The utility writes the key to a file you specify and scrambles the key using a password you provide. This file should be backed up as part of your backup and recovery procedures. You should also document the password used for the file.
1. Use the following syntax to create a backup of the encryption key:
```RSKeyMgmt -e -fC:\Backup\rsdbkey.txt -p<password>```
1. Run RSKeyMgmt locally on the computer hosting the report server.

## Backing Up the IIS Metabase
The IIS configuration is split between the web.config files and the applicationHost.config files. The applicationHost.config files include configuration information for the sites, applications, virtual directories, application pool definitions, and the default configuration settings for all sites on the Web server. To back up the IIS configuration, follow these steps:
1. Log on to the server hosting the Web console server.
2. Open PowerShell using the Run As Administrator option.
3. Type the following command to back up the configuration:
```
CD C:\Windows\system32\inetsrv
.\appcmd add backup mybackup
```
The backup is created in the folder C:\Windows\system32\inetsrv\backup. If you do not specify the name of the backup, the system will name it using a date/time format.
