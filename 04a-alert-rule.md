# Chapter: Monitoring with Operations Manager 

## Alert-Generating Rule
The following procedure explains the process to create an alert rule by creating a basic Windows Event Log alert rule. The rule generates an alert if a Operating System crash has been detected. Follow these steps:
1. Open the Operations console and navigate to **Authoring -> Management Pack Objects**.
1. Right-click **Rule** and select **Create New Rule**.
1. Select **Alert Generating Rules -> Event Based -> NT Event Log (Alert)**, but **do not** click Next yet.
1. Create a new management pack: click **New** and enter **Sample** as the name of your new  Management pack.
1. Click Next and Create to create a new, empty management pack.
1. Click Next.
1. Name for this rule: **Crash detected**.
1. Target the **Windows Server Operating System** class so this rule will apply to all Windows servers.
1. Leave the rule enabled and click Next to continue.
1. On the following page, select the **System** event log. You can click the ... button to browse and select the log, or you can simply type in the name of the log.
1. Click Next.
1. Use the **Build Event Expression** page in the wizard to match the Event ID and Event Source parameters. Configure the Event ID as **Event ID Equals 6008** and the Event Source to be **Event Source Equals EventLog**.
1. **Note.** It's best to paste or type both values in the **Value** column.
1. Click Next to continue.
1. The final page of the Create Rule Wizard configures the actual alert OpsMgr will generate. Leave the alert with the default name. Notice this rule has a **Priority of Medium** and a **Severity level of Critical**.
1. Click Create to create the new alert rule.

## Confirm that a changed management pack is downloaded by the agent
Confirming that a change in the monitoring environment is confirmed by the agent is an extremely important and usefull procedure. You will use it a lot during the training, as well as in real life.
1. Open a PowerShell prompt.
1. Run this command from the PowerShell prompt: ```Invoke-Command -ComputerName LON-DC1 { Get-NetFirewallRule | where { $_.displayname -like '*access (dcom-in)' -or $_.displaygroup -eq 'Remote Event Log Management' } | Enable-NetFirewallRule }```
1. Open the Event Viewer.
1. From Event Viewer, select **Action** and select **Connect to another computer**. Enter LON-DC1.
1. Open the **Applications and Services** node, click the **Operations Manager** log and search for event id **1201**. A short while after the 1201 event id, a new event with event id 1210 should appear. This confirms the download and activation of the management pack.
1. Minimize the Virtual Machine connection window to return to the host server.
1. In Hyper-V Manager, right click **LON-DC1** and click **Turn Off**.
1. **Note.** By turning off the server, instead of shutting down, we simulate an Operating System crash.
1. After the DC has been turned off, turn it back on, and wait for the boot procedure.
1. Return to the **LON-SV1 Virtual Machine Connection** window and open the **Operations Manager** console.
1. Wait for an alert to appear with the Name **Crash Detected**.


## Alert-Generating Rules
1. Repeat the first procedure with the following parameters: 
  - Select destination management pack: Sample.
  - Name: Reason for unexpected shutdown.
  - Log: System
  - Event ID: 1076
  - Source: USER32
1. Now repeat the procedure to confirm the management pack download using the Event Viewer.
1. Minimize the Virtual Machine connection window to return to the host server.
1. In Hyper-V Manager, doubleclick **LON-DC1** to open a console window.
1. Log on to LON-DC1 and specify the reason for the unexpected shutdown: **i had to turn it off**.
1. Return to the **LON-SV1 Virtual Machine Connection** window and open the **Operations Manager** console.
1. Wait for an alert to appear with the name **Reason for unexpected shutdown**.
1. Open the alert by double clicking it.
1. Select the **Altert context** tab and verify the alert reasin is **i had to turn it off**.


> NOTE: CLOSING ALERTS ON OLDER OPERATIONS MANAGER INSTALLATIONS
> 
> When you configure an alert using an alert-generating rule, the resulting alert does not close automatically, as is the case with alerts generated by monitors. You must close these alerts manually after resolving the root cause, or they will be auto-resolved after a set amount of time has passed based on your management group settings.

