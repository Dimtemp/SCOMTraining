# Chapter: Monitoring with Operations Manager 
 
## Creating an Override
This section looks at the process for creating an override against a monitor. Here are the steps to create an override from the Authoring pane in Operations Manager. Overrides can also be created in the Monitoring or My Workspace panes.

1. Navigate in the Operations console to Authoring -> Management Pack Objects -> Monitors.
1. Using one of the search methods discussed in the **Locating Rules and Monitors in the Operations Console** section, locate the monitor you wish to override. This example will override the Available Megabytes of Memory monitor located under the Windows Server 2016 Operating System class. Using the scoping bar, scope the console to this class. You will find this monitor under the Performance aggregate monitor.
1. After locating the monitor, right-click it and select Overrides. Next, choose Override the Monitor. 
1. Choosing Override the Monitor opens a submenu with the following options:
  - For all objects of class: < Class the monitor is attached to >
  - For a group...
  - For a specific object of class: < Class the monitor is attached to >
  - For all objects of another class.....
1. For this example, assume a single computer running Windows Server 2016 is causing excessive alerts. For this override, choose **specific object of class Windows Server 2016 and above Operating System**.
1. Selecting this option presents the Select Object dialog. From this page, select the server (in this case **LON-SV1**) for the computer that is experiencing heavy usage and therefore generating alerts.
1. Highlight the object and click OK after selecting the object you wish to override.
1. The Override Properties page appears.
1. The Override Properties page displays all the parameters you can override for the monitor. This particular monitor includes a large number of parameters you can override. Because the interest is to modify the threshold values, focus on the Available Memory Threshold (Mbytes) parameter.
1. To modify this parameter, scroll down to tick the check box next to the parameter and type the new value in the Override Value column, which should highlight automatically when you put a tick in the check box. For this example, change the value to 50 MB. Type 50 into the column, select the management pack in which to store the override, and click Apply. The next column (Effective Value) will change to reflect the change you made. Click OK to close the dialog box.
1. To verify the override, look in the Overrides Summary page. To locate this page, right-click the monitor, and choose Overrides Summary. You will see the override listed in the Overrides Summary page. From here, you can delete or edit any overrides as required.
1. Confirm that the changed management pack is downloaded by the agent. The procedure is explained in a previous exercise.


## Other overrides
Overrides are often used to change threshold values. Other examples of the use of overrides is enabling or disabling a certain rule or monitor for a class, group or specific object. For example: you can enable a disabled monitor (previously created) for a specific group of servers.
Repeat the previous procedure (Creating an override) with the following parameters:
-	Monitor name: Print Spooler Service Monitor
-	Override the Monitor: for a group: Windows Server 2016 and above Computer Group
-	Enabled: true
**Note.** You cannot select any other management pack than the sample management pack. This is because the (custom) monitor is stored in an unsealed management pack. Since dependencies between unsealed management packs are not allowed, this override is forced to be stored in the same management pack.


## Another override
Repeat the previous procedure (Creating an override) with the following parameters:
-	Monitor name: Server Time out of Sync
-	Override the Monitor: for a group: Windows Server 2016 and above Computer Group
- Enabled: true


## Locate overrides
Try these three methods when locating overrides:
-	Operations console -> Authoring -> Management Pack Objects -> Overrides.
-	Operations console -> Reporting -> Microsoft Generic Report Library -> Overrides.
-	PowerShell -> Get-SCOMOverride. More information on the Operations Manager Shell can be found the Chapter, **PowerShell and Operations Manager**.
