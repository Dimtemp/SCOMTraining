# Chapter: Distributed Applications


## Prerequisites
- IIS and SQL Management packs.
- IIS role has been installed.


**Note.** If the SQL and/or IIS management packs have not been imported at this moment, it is best to import them as soon as possible, run both PowerShell commands in step 1 and 2, and take a coffee break.


1. Start an elevated PowerShell console and run this command: ```Add-WindowsFeature Web-WebServer, Web-Mgmt-Console``` (This step might have been executed in a previous exercise. The Exit Code will display NoChangeNeeded if this is the case.)
1. Right click the PowerShell icon and select **Run as different user**.
1. Use these credentials: Administrator, Pa55w.rd
1. Run this command: ```sqlcmd -Q 'CREATE DATABASE Webshop'```
1. Optionally, you can force to run the discovery process on the agent by restarting the Microsoft Monitoring Agent (a.k.a. HealthService): ```Restart-Service healthservice```
1. Leave this PowerShell window open.
1. Open the **Monitoring** pane.
1. Navigate to Microsoft SQL Server, SQL Server Database Engines, Database Engines.
1. Select the Databases view and verify at least the following databases exist: master, model, msdb, OperationsManager, OperationsManagerDW, tempdb, Webshop.
1. Navigate to Microsoft Windows Internet Information Services.
1. Select the **IIS Role State** view and verify the LON-SV1 server is displayed.
1. Select the **Web Site State** view and verify the Default Web Site is displayed.


## Creating the Distributed Application
1. Navigate to and select **Authoring** -> Distributed Applications. Right-click and choose **Create a new distributed application**.
1. Enter a name and description for the DA. This name will appear in the Monitoring -> Distributed Applications global view, so use a name that communicates its purpose. For this example, select the same name **Critical Website**.
1. Choose the **Line of Business Web Application** template.
1. Select the **Sample** management pack to save the DA.
1. Click OK.


The next part of creating the DA is to add the components. The following steps populate the DA components with managed objects:
1. On the lower left side of the Distributed Application Designer, click the **Database** tile.
1. Right-click the **Webshop** database and then select Add To -> Critical Website Web Application Database (drag-and-drop is also possible).
1. On the lower left side of the Distributed Application Designer, click the **Web Site** tile.
1. Right-click the **Default Web Site** database and then select Add To -> Critical Website Web Application Web Sites.
1. Click the Save icon, or select File -> Save.
1. Exit the Distributed Application Designer (File -> Close).


## Inspect the Distributed Application
1. After several minutes, you can view the health status of the new DA in the following view: Monitoring -> Distributed Applications
1. Right click the Critical Website distributed application, select Open, **Diagram View**.
1. Observe both components that combine in the critical website service on the top:
    - database
    - website
1. Keep the diagram view open.
1. Return to the PowerShell window as mentioned at the start of this exercise.
1. Run this command to set the database offline: ```sqlcmd -Q 'ALTER DATABASE Webshop SET OFFLINE'```
1. Return to the diagram view and wait for the distributed application update the status (optionally hit F5).
1. After a while the database will turn gray. Minimize the diagram view to return to the Operations Manager console.
1. Hit Refresh (F5) to update the Distributed Application view. 
1. The DA you previously created will turn yellow in a while.
1. Run this command to set the database online again: ```sqlcmd -Q 'ALTER DATABASE Webshop SET ONLINE'```
1. Run this command to set the website in a stopped state: ```Get-WebSite | Stop-Website -Passthru```
1. Return to the diagram view to view the changes in state.
1. Run this command to set the website in a started state: ```Get-WebSite | Start-Website -Passthru```
1. Return to the diagram view to view the changes in state.
1. Close the diagram view.
