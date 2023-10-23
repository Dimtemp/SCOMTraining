# Chapter: Administering Management Packs
Importing management packs tells Operations Manager how to monitor a wide range of services. It is a neccesary procedure during every Operations Manager deployment.


## Importing Management Packs from disk
1. Open Hyper-V Manager, and open a console session the LON-SV1 VM.
1. Open Windows Explorer.
1. Navigate to: **E:\Management Packs**.
1. Run the first MSI that is in the folder to extract the contents of the Management Pack.
1. **Note.** If an error message appears about a remote desktop conneciton, click **View**, and **unselect** Enhanced Session form the VM Connection window.
1. Accept the license agreement and leave all other options to their default setting.
1. Repeat this for every MSI in the same folder (not any subfolders).
1. Now open the SCOM Console.
1. Open the **Administration** workspace.
1. Right click **Management Packs** and select **Import Management Packs**.
1. Click **Add**, and then **Add from disk...**
1. Select **No** to skip the depency check.
1. Browse to C:\Programm Files (x86)\System Center Management Packs.
1. Select the folder that contains the Windows Server management packs.
1. Select all the MP files that exist in that folder and click **Open**.
1. Click **Install** and wait for the import. This might take a minute or two.
1. Repeat from step 7 for all other folders.


## Verifying a succesfull import.
1. Open the Windows Explorer and enter this in the address bar: **```\\LON-DC1\C$```**
1. Windows Explorer opens the root of the C-Drive from the LON-DC1 server.
1. Open the Program Files folder
1. Open the Microsoft Monitoring Agent folder
1. Open the Agent folder
1. Open the Health Service State folder
1. Open the Management Packs folder
1. Verify the existence of Microsoft.Windows.Server files.

### Notice that some SQL files might be present in this folder on the domain controller. These management packs contain discoveries for SQL Server. Since there is no SQL Server on the Domain Controller, it will not be monitored. As soon as a SQL server is installed on the domain controller it will be monitored. This behaviour is by design.
1. Open the SCOM Console.
1. Open the Monitoring workspace
1. Scroll down to the Microsoft Windows Server folder.
1. Inspect the various views within the Windows Server folder. At least two servers should appear that run Windows Server.


## If time permits: Listing All Management Packs Associated with a Server
You can use PowerShell to list all management packs associated with a server using the Get-SCOMRule cmdlet. Follow these steps to extract the list:
1. Open the Operations Manager Shell (click Start -> Microsoft System Center -> Operations Manager Shell)
2. In the command window, type the following:
```powershell
Get-SCOMRule | Select-Object @{Name="MP";Expression={ Foreach-Object { $_.GetManagementPack().DisplayName }}}, DisplayName | Sort-Object MP
```


## Importing Management Packs from the online catalog
### Note: you can only perform this procedure if the lab environment has an internet connection. Skip this procedure if your lab environment doesn't have an internet connection.
First introduced with Operations Manager 2007 R2, you can download Management Packs using the Administration node of the console. Follow these steps to download management packs using the console:
1. Navigate to Administration -> Management Packs. From the Tasks pane on the right, select Import Management Packs.
2. When selecting management packs, the search criteria in the View section of the Select Management Packs from Catalog page enables you to select from several search options. Select the **All Management packs in the catalog** option. Use the search field to download management packs for the following technologies:
    - Core OS
    - SQL Server
    - IIS
    - Active Directory
> Please make sure that you don’t select any localized management packs that you don’t use, like Chinese, Japanese, French, etc…

The wizard will alert you if there are dependencies on other management packs or versions; you can download those also to resolve the issue. Once you complete your selection, select OK to view the download list. Select Download to initiate the download process.
