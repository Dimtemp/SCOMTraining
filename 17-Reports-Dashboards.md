# Chapter: Reporting and Dashboarding

## Edit and Run a Preconfigured Windows Server Report
1.	On LON-SV1 in the Operations Manager console, select the Monitoring node.
2.	Click the Active Alerts view.
3.	Click the View menu. If Tasks are off, then click it to display the tasks window on the right side of the screen.
4.	Select any alert.
5.	On the right side of the console, select the Availability report. If there’s no link to the Availability report, select another alert and try again.
6.	Fill in the following: From – Yesterday
7.	Select Run.
8.	Notice that there is a red section indicating DOWN (downtime).
9.	Click on the Availability Tracker link.
10.	Review the report.

## Export a Report
1.	In the Availability Report window select the Export drop-down box.
2.	Select MHTML.
3.	Save the report to the desktop.
4.	Open the MHTML file on the desktop and verify the report.
5.	Close the MHTML report.

## Publish Reports
1.	In the Availability Report window select File > Publish.
2.	Change the name to My Availability.
3.	Do not close the report.
4.	In the Operations Manager 2012 console, in the Reporting node, click on Authored Reports.
5.	Locate the report you just published and run it. Notice that you do not have to fill in any information this time.
6.	Close the My Availability report and return to the Availability Report.
7.	Click File, Save to management pack and select the Sample Management Pack.
8.	Do not close the report.

## Schedule a Report
1.	Open Windows Explorer on LON-SV1 and create a folder: C:\SCOM-Reports.
2.	Share this folder as: SCOM-Reports.
3.	Grant everyone full control of the shared folder.
4.	In the Availability Report window, select File > Schedule.
5.	Type Availability in the description.
6.	Change the delivery method to File Share.
7.	In the Delivery Window enter the following:
  -	File name: Availability
  -	Path: \\LON-SV1\SCOM-Reports
  -	Render format: MHTML
  -	Write mode: Autoincrement
  -	User name: Administrator
  -	Password: Pa$$w0rd
8.	Click Next.
9.	In the Schedule window enter the following:
a.	Generate the report: Once
b.	Subscription beginning: Five minutes from the current time
10.	Click Next.
11.	Click Finish on the Parameters window.
12.	Look for the report to appear in the share

## Reports to explore
Consider the following reports to explore:
- Microsoft Generic / Availability
  - E.g. Windows Servers
- Microsoft Generic / Configuration changes
  - E.g. Configuration Changes on SCOM Servers/Agents or SQL Servers
- Microsoft Generic / Most common alerts
- Microsoft Generic / Overrides
- SQL Server / SQL DB Space
  - Specify the SQL DB Engine group
- Windows Server 2016 / OS Performance
  - CPU, Memory, Disk
- Windows Server Operating System / Performance by System (or Utilization)
- System Center Core / Data Volume by MP
  - All Management Packs
- System Center Core / Data Volume by Workflow
 
## Dashboards
1. Select the My Workspace pane in the SCOM Console. Right click Favorite Views and select New  Dashboard View.
2. Select the Grid Layout template and click Next.
3. Enter a name for your dashboard and click Next.
4. Select at least a 4 Cell Dashboard and Finish the Wizard.
5. You will see several cells (at least 4) with a hyperlink “Click to add widget…” in each cell.
6. Click one of the hyperlinks and add a Performance Widget.
7. Specify “Windows Servers CPU Usage” as the Name and click Next.
8. Select “Windows Server Computer Group” under “Select a group or object”. Click Add and add the following performance counter: Processor Information, % Processor Time, _Total.
9. Finish the wizard.
10. Optionally reconfigure the widget with the gear symbol in the top right corner of the graph.
11. Repeat step 6 – 9 for the remaining widgets. Try at least these widgets:
•	Alert widget on all active alerts
•	Objects by performance to display most heavily used servers
•	State widget to show the state of your databases (not database servers)
