# Chapter: Administering Management Packs
Importing management packs tells Operations Manager how to monitor a wide range of services. It is a neccesary procedure during every Operations Manager deployment.

## Importing Management Packs
First introduced with OpsMgr 2007 R2, you can download MPs using the Administration node of the console. Follow these steps to download management packs using the console:
1. Navigate to Administration -> Management Packs. From the Tasks pane on the right, select Import Management Packs.
2. When selecting management packs, the search criteria in the View section of the Select Management Packs from Catalog page enables you to select from several search options. Select the **All Management packs in the catalog** option. Use the search field to download management packs for the following technologies:
•	Core OS
•	SQL Server
•	IIS
•	Active Directory
> Please make sure that you don’t select any localized management packs that you don’t use, like Chinese, Japanese, French, etc…
5. The wizard will alert you if there are dependencies on other management packs or versions; you can download those also to resolve the issue. Once you complete your selection, select OK to view the download list. Select Download to initiate the download process.

## If time permits: Viewing the contents of a Management Pack
You can view the contents of a Management Pack through the Authoring pane of the Operations Manager console. A very easy and ‘low level’ way to view the contents of a Management Pack is through the **MPViewer** utility, originally written by Boris Yanushpolsky. A recent version is available at
> https://kevinholman.com/files/6560.MPViewer.2.3.3.zip
1. Download and install it. Open a Management Pack from the C:\Backups folder. With the tool you can tell whether a management pack contains object discoveries, rules, monitors overrides, etc…

## If time permits: Listing All Management Packs Associated with a Server
You can use PowerShell to list all management packs associated with a server using the Get-SCOMRule cmdlet. Follow these steps to extract the list:
1. Open the Operations Manager Shell (Start -> All Programs -> Microsoft System Center 2012 -> Operations Manager)
2. In the command window, type the following:
Get-SCOMRule | select-object @{Name="MP";Expression={ foreach-object  { $_.GetManagementPack().DisplayName }}}, DisplayName | Sort MP
