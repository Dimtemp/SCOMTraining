# Chapter: Administering Management Packs
Importing management packs tells Operations Manager how to monitor a wide range of services. It is a neccesary procedure during every Operations Manager deployment.

## Importing Management Packs from the online catalog
### Note: you can only perform this procedure if the lab environment has an internet connection. Skip to the next procedure if your lab environment doesn't have an internet connection.
First introduced with OpsMgr 2007 R2, you can download MPs using the Administration node of the console. Follow these steps to download management packs using the console:
1. Navigate to Administration -> Management Packs. From the Tasks pane on the right, select Import Management Packs.
2. When selecting management packs, the search criteria in the View section of the Select Management Packs from Catalog page enables you to select from several search options. Select the **All Management packs in the catalog** option. Use the search field to download management packs for the following technologies:
    - Core OS
    - SQL Server
    - IIS
    - Active Directory
> Please make sure that you don’t select any localized management packs that you don’t use, like Chinese, Japanese, French, etc…

The wizard will alert you if there are dependencies on other management packs or versions; you can download those also to resolve the issue. Once you complete your selection, select OK to view the download list. Select Download to initiate the download process.

## Importing Management Packs from disk
### Note: follow this procedure if your lab environment doesn't have an internet connection.
1. Return to the host machine, open Hyper-V Manager, and open a console session the LON-SV1 VM.
2. Make sure Enhanced session is turned on by clicking the **View** menu.
3. Minimize the LON-SV1 Virtual Machine Connection window and return to the host machine.
4. Open Windows Explorer.
5. Navigate to: **C:\Hyper-V\files\SC2019\Lib\Management Packs**.
6. Copy the **Management Packs.zip** file to the desktop of the LON-SV1 virtual machine.
7. Unzip the zip file and open the folder with the unzipped contents.
8. Run every MSI that is in the folder to extract the contents of the Management Pack. Accept the license agreement and leave all other options to their default setting.
9. Now open the SCOM Console.
10. Open the **Administration** workspace.
11. Right click **Management Packs** and select **Import Management Packs**.
12. Click **Add**, and **then Add from disk...**
13. Select **No** to skip the depency check.
14. Browse to C:\Programm Files (x86)\System Center Management Packs.
15. Select the folder that contains the Windows Server management packs.
16. Select all the MP files that exist in that folder and click **Open**.
17. Click **Install** and wait for the import. This might take a minute or two.
18. Repeat step 8 - 14 for all other folders.


## Verifying a succesfull import.
1. Rightclick **Start** and select **Run**.
2. Enter this command: **```\\LON-DC1\C$```**
3. Windows Explorer opens the root of the C-Drive from the LON-DC1 server.
4. Open the Program Files folder
5. Open the Microsoft Monitoring Agent folder
6. Open the Agent folder
7. Open the Health Service State folder
8. Open the Management Packs folder
### Notice that some SQL files might be present in this folder on the domain controller. These management packs contain discoveries for SQL Server. Since there is no SQL Server on the Domain Controller, it will not be monitored. As soon as a SQL server is installed on the domain controller it will be monitored. This behaviour is by design.
9. Open the SCOM Console.
10. Open the Monitoring workspace
11. Scroll down to the Microsoft SQL Server folder.
12. Inspect the various views within the SQL Server folder. At least on server should appear that runs the SQL Server service.


## If time permits: Listing All Management Packs Associated with a Server
You can use PowerShell to list all management packs associated with a server using the Get-SCOMRule cmdlet. Follow these steps to extract the list:
1. Open the Operations Manager Shell (click Start -> Microsoft System Center -> Operations Manager Shell)
2. In the command window, type the following:
```powershell
Get-SCOMRule | Select-Object @{Name="MP";Expression={ Foreach-Object { $_.GetManagementPack().DisplayName }}}, DisplayName | Sort-Object MP
```
