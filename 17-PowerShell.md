# Chapter: PowerShell (optional)

## Get-SCOMAgent
1. Log on to LON-SV1 as Administrator and open the Operations Manager Shell. Make sure you start the Operations Manager Shell. If you start the ‘regular’ PowerShell then use this command to import the Operations Manager module: “import-module OperationsManager”.
2. The Get-SCOMAgent cmdlets fetch the OpsMgr agent data into the PowerShell pipeline; then the Where-Object acts as a filter and only keeps information about the objects that meet the criteria of ManuallyInstalled = True. The result of the filter action is then piped to the following Format-Table cmdlet, which specifies that only the Name object should be displayed to the output.
```powershell
Get-SCOMAgent | Where ManuallyInstalled -eq $True | FT Name
```

## PowerShell-Based Agent Installation
Here is an example of syntax used to deploy an Operations Manager agent:
```powershell
$Account = Get-Credential -UserName 'ADATUM\Admin' -Message 'Enter password'
$Svr = Get-SCOMManagementServer -Name "LON-SV1.Adatum.msft"
Install-SCOMAgent  –Name "LON-W10.Adatum.msft" –PrimaryManagementServer $Svr  –ActionAccount $Account
```

## Uninstalling Agents Using PowerShell
The following is a PowerShell script that uninstalls agents based upon matching a naming convention. This example identifies a unique naming for the computers such as those named with “CL” indicating they are a client computer:
```powershell
Get-SCOMAgent -DNSHostName CL*.adatum.msft | Disable-SCOMAgentProxy
$credential = Get-Credential
Get-SCOMAgent -DNSHostName CL*.adatum.msft |
Foreach { Uninstall-SCOMAgent –Agent $_ -ActionAccount $credential }
```

## Using Repair-SCOMAgent
You can also repair an OpsMgr agent from the command line. Repair-SCOMAgent requires the agent object (not just the agent name) as input in order to perform the repair. The underlying repair process is the same; you are simply instantiating the repair from the PowerShell Shell.
```powershell
Get-SCOMAgent -Name "LON-DC1.adatum.msft" | Repair-SCOMAgent -verbose
```

## Enable-SCOMAgentProxy
The Enable-SCOMAgentProxy cmdlet enables an agent to act as a proxy and discover objects not hosted on the local computer. This cmdlet is normally used in conjunction with the Get-SCOMAgent cmdlet, which fetches the desired agents that are then piped to the Enable-SCOMAgentProxy cmdlet that changes the property of ProxyingEnabled to $True . The next one-liner uses Get-SCOMAgent to fetch all OpsMgr agent information, which is then pipelined to the Where-Object cmdlet that will only pull out OpsMgr information that has ProxyingEnabled set to false. Those agents are then pipelined to the Enable-SCOMAgentProxy cmdlet that sets the ProxyingEnabled property to true. Note that $False and $True are used to represent true and false in PowerShell. Here is an example:
```powershell
Get-SCOMAgent | Where { $_.ProxyingEnabled.Value -eq $False } | Enable-SCOMAgentProxy
```
To verify this one-liner has the desired effect, run the following one-liner, which returns a list of agents along with confirmation that agent proxy has been enabled.
```powershell
Get-SCOMAgent | Where { $_.ProxyingEnabled.Value -eq $True } | Select Name, ProxyingEnabled
```

## Retrieving the AgentApproval Setting
The Get-SCOMAgentApprovalSetting cmdlet fetches the AgentApprovalSetting for the management group to which the OpsMgr PowerShell console is currently connected. It will show either Pending, AutoApprove, or AutoReject.
```powershell
Get-SCOMAgentApprovalSetting
```

## Setting the AgentApproval Setting
The cmdlet Set-SCOMAgentApprovalSetting sets the AgentApprovalSetting for the management group to which the OpsMgr PowerShell console is currently connected. The three parameters are AutoApprove, AutoReject, and Pending. Here is an example to set the agent approval setting for the management group to manual:
```powershell
Set-SCOMAgentApprovalSetting -Pending
```
To verify the changes were applied, run the following:
```powershell
Get-SCOMAgentApprovalSetting
```

## Starting Maintenance Mode
As you might guess, the Start-SCOMMaintenanceMode cmdlet can be used to initiate maintenance mode for a monitored object. The following snippet starts maintenance mode for a computer.
```powershell
$Instance = Get-SCOMClassInstance -Name LON-DC1.adatum.msft
$Time = ((Get-Date).AddMinutes(10))
Start-SCOMMaintenanceMode -Instance $Instance -EndTime $Time -Reason "Security
Issue" -Comment "Applying software update"
```

## Modifying an Active Maintenance Mode Window
To modify an active maintenance mode window requires a combination of the Get-SCOMMaintenanceMode and Set-SCOMMaintenanceMode cmdlets. The Get-SCOMMaintenanceMode cmdlet is used to retrieve the active maintenance mode window and the Set-SCOMMaintenanceMode cmdlet to update the end time of the maintenance mode window.
```powershell
$NewEndTime = (Get-Date).addDays(1)
Get-SCOMClassInstance -Name *.Contoso.com | Get-SCOMMaintenanceMode |
Set-SCOMMaintenanceMode -EndTime $NewEndTime ` -Comment "Updating end time."
```
By updating the end time to the current time, you can effectively end maintenance mode for a monitored object on demand.

## Using Get-SCOMAlert
Before PowerShell can take action on an alert, an alert or collection of alerts must be identified. Get-SCOMAlert does just that; it fetches specified alerts. The Get-SCOMAlert cmdlet has many parameters due to the number of attributes defined in an alert.
Here are examples using the ResolutionState parameter for the Get-SCOMAlert cmdlet:
•	Get new alerts: ```Get-SCOMAlert -ResolutionState 0```
•	Get closed alerts: ```Get-SCOMAlert -ResolutionState 255```
Examples using the Severity parameter for the Get-SCOMAlert cmdlet:
•	Get severity informational alerts: ```Get-SCOMalert -severity 0```
•	Get alerts of severity warning: ```Get-SCOMalert -severity 1```
•	Get alerts of severity error: ```Get-SCOMalert -severity 2```
Examples using Priority parameter for Get-SCOMAlert cmdlet:
•	Get low priority alerts: ```Get-SCOMAlert -Priority 0```
•	Get normal priority alerts: ```Get-SCOMAlert -Priority 1```
•	Get high priority alerts: ```Get-SCOMAlert -Priority 2```
It is possible to combine several parameters together in one line to get some specific information, illustrated in the following examples:
•	Gets a list of new alerts with a error severity: ```Get-SCOMAlert -ResolutionState 0 -Severity 2```
•	Gets a list of closed alerts with high priority: ```Get-SCOMAlert -ResolutionState 255 -Priority 2```
•	Gets a list of new alerts with severity of error and high:
o	```Get-SCOMAlert -ResolutionState 0 -Severity 2 -Priority 2```

## Setting Alert Resolution State with Resolve-SCOMAlert
The Resolve-SCOMAlert cmdlet does one thing; it sets the ResolutionState on an alert sent to it to closed (255). This is the same action that occurs with Set-SCOMAlert -ResolutionState 255. The cmdlet has many parameters similar to those available with Set-SCOMAlert; in essence, you could resolve alerts in bulk and modify the properties of the alert at the same time as in these examples:
- Gets a list of new informational alerts, closes them, and adds a comment to the closed alerts:
```powershell
Get-SCOMAlert -ResolutionState 0 -Severity 0 | Resolve-SCOMAlert -Comment 'Chuck Norris closed these informational alerts with fists of fury and the command shell.'
```
- Gets a list of new error alerts, closes the alerts, and adds a comment to the closed alerts:
```powershell
Get-SCOMAlert -ResolutionState 0 -Severity 2 | Resolve-SCOMAlert -Comment 'Automated close out of alerts.'
```

## Retrieving License Information
The Get-SCOMAccessLicense cmdlet retrieves license information about the management group to which your OpsMgr PowerShell session is connected. It returns DeviceID, WorkloadRoleName, information about role type for a given computer (management server, agent-managed computer, and so on), and whether the machine is virtualized. It also returns the LogicalProcessorCount and PhysicalProcessorCount; both are important pieces of information when dealing with System Center licensing.
Here is an example of a one-liner report that gives a sum of both of the processor counts and physical process count for the management group to which the OpsMgr PowerShell console is currently connected:
```powershell
Get-SCOMAccessLicense | measure-object -property LogicalProcessorCount,PhysicalProcessorCount -sum | foreach{$_.Property + " Total : " + $_.Sum}
```

## Upgrading from an Evaluation Copy
If a management group was installed using an evaluation copy of Operations Manager, Set-SCOMLicense enables an administrator to run this cmdlet with a valid product key and remove the evaluation expiration timeout. The following example is only to show proper syntax and is taken directly from the help file.
```powershell
Set-SCOMLicense -ProductId 'C97A1C5E-6429-4F71-8B2D-3525E237BF62'
```

## Determining the RMS Emulator
The Get-SCOMRMSEmulator cmdlet shows the management server currently hosting the RMSE. If running locally from a management server, you can run this without options to fetch data about the management group to which the PowerShell console is connected. When running from a workstation, you can specify a management server with which to establish a connection, as well as specify alternate credentials to determine the management group’s current RMSE.
```powershell
Get-SCOMRMSEmulator
```

## Moving the RMS Emulator Role
The Set-SCOMRMSEmulator cmdlet moves the RMSE to a specified management server. First retrieve the management server object (for the management server where you wish to move the role) using Get-SCOMManagementServer cmdlet. Then pass the output through the pipeline to Set-SCOMRMSEmulator to the variable.
```powershell
Get-SCOMManagementServer -Name "LON-SV2.adatum.msft" |
Set-SCOMRMSEmulator -verbose
```
This is not something you would do very often, but if you needed to do some work on a management server, you might decide to make a clean transition of the role before decommissioning or performing maintenance on the server hosting the RMSE role.

## Removing the RMS Emulator Role
The RMS emulator is only for backwards compatibility to legacy management packs and is in no way required for the management group to function correctly. So in theory, if you are able to confirm no workflows target the legacy Root Management Server class (nor would any in the future), you could remove this role. The Remove-SCOMRMSEmulator cmdlet removes the RMS emulator role from the management group with which the OpsMgr PowerShell console currently has a connection. Run the cmdlet with no options; it will prompt to verify this action.
```powershell
Remove-SCOMRMSEmulator
```

## Temporarily Disabling All Notification Subscriptions
Consider an example where you may want to temporarily disable all notification subscriptions during an extensive data center outage (planned or otherwise); this can be accomplished by retrieving all the enabled notification subscriptions with Get-SCOMNotificationSubscription and passing them through the pipeline to Disable-SCOMNotificationSubscription, as shown here.
```powershell
Get-SCOMNotificationSubscription | where {$_.Enabled -eq $True} |
Disable-SCOMNotificationSubscription
```
When you are ready to re-enable all notifications within OpsMgr, another one-liner reverses the effects of the previous command. You will still need to retrieve all the disabled notification subscriptions with Get-SCOMNotificationSubscription and then pass them to another cmdlet, Enable-SCOMNotificationSubscription, to re-enable all disabled subscriptions.
```powershell
Get-SCOMNotificationSubscription | where {$_.Enabled -eq $False} |
Enable-SCOMNotificationSubscription
```

## Backing Up Unsealed Management Packs
Part of a comprehensive backup strategy for OpsMgr would include backing up unsealed management packs on a nightly basis to the file system, as discussed in Chapter 12, “Backup and Recovery.” This is to ensure changes made to the OpsMgr environment, such as overrides, custom rules, and monitors, are captured and backed up.
Make sure you have a C:\Backup folder before running this command.
```powershell
Import-Module OperationsManager
Get-SCOMManagementGroupConnection -ComputerName ‘LON-SV1’ |
Set-SCOMManagementGroupConnection
Get-SCOMManagementPack | Where-Object { $_.Sealed -eq $False } |
Export-SCOMManagementPack -path "C:\Backups"
```

## Setting Failover Management Servers to Agents
As your OpsMgr environment grows and you add hundreds (or even thousands) of OpsMgr agents on Windows servers and incorporate cross-platform and network device monitoring, you may want to configure specific failover management servers to balance the agent load.
This script performs the following high-level actions:
1. Retrieves the agent to be updated.
2. Sets two variables; one for the primary management server and the second variable for the failover management server.
3. Sets the primary and failover management servers for the list of agents in the $agent variable.
```powershell
#Get the agent you want to update
$Agent = Get-SCOMAgent "LON-DC1.adatum.msft"
#Get the primary and failover management servers
$primaryMS = Get-SCOMManagementServer "LON-SV1.Adatum.msft"
$failoverMS = Get-SCOMManagementServer "LON-SV2.Adatum.msft"
#Set Fail-over Management Server on Agent
Set-SCOMParentManagementServer -Agent $Agent -FailoverServer $FailoverMS -passthru
#Set Primary Management Server on Agent
Set-SCOMParentManagementServer -Agent $Agent -PrimaryServer $PrimaryMS -passthru
```
One behavior to be aware of when using the Set-SCOMParentManagementServer cmdlet is you will get a failure message if you attempt to set the primary management server to the same server as the current failover management server.
With a bit of effort, you can update agent failover settings in bulk as described in the article on updating agent failover settings from a spreadsheet with PowerShell at http://www.systemcentercentral.com/tabid/143/indexid/95393/default.aspx

## Balancing the Agent Load
While resource pools were a fantastic addition to Operations Manager 2012, one important item they do not address is balancing the agent load across management servers in the resource pool. For example, if you have two management servers and you discover and install 2,500 agents with the Discovery Wizard, all 2,500 will use the same management server as their primary. This is not a very efficient use of resources to say the least! 
Fortunately, with the OpsMgr Shell, you can easily balance the agent load across multiple management servers. The sample script referenced in this section evenly distributes agents across two or more management servers. Running this script as part of a schedule task can ensure the agent load is balanced as your environment grows and evolves.
While it is relatively easy to balance agents across two management servers with PowerShell, the script logic becomes significantly more complex when you need to support 2– N management servers. Fortunately, that did not bother Andreas Zuckerhut, who routinely writes PowerShell-based automation solutions for OpsMgr that rate at the high end of the complexity scale. You can find a copy of this community-developed solution in the OpsMgr by Example series at http://www.systemcentercentral.com/BlogDetails/tabid/143/IndexID/96292/Default.aspx .

## Some Useful One-Liners
PowerShell is a very succinct language, and it is relatively easy to do a lot of work with a relatively small amount of code when compared to some other MS scripting languages, like VBScript and JScript. This section includes a few easy-to-use one-liners that should be useful in any OpsMgr environment.

## Processing Alerts in Bulk
Processing alerts in bulk may well be the most common use of the OpsMgr Shell and one you should approach with caution. Because you may find yourself trying to clean up tens of thousands of alerts in a worst-case scenario, efficient syntax is important. This section includes several examples of effective use of the -criteria parameter instead of Where-Object to optimize performance of bulk alert processing commands.
- Resolve informational alerts:
```powershell
Get-SCOMAlert -criteria 'ResolutionState = ''0'' AND Severity = ''0''' |
Set-SCOMAlert -ResolutionState 255
```
Find a longer list of one-liners for processing alerts at Pete Zerger’s article discussing an updated collection of one-liners at http://www.systemcentercentral.com/BlogDetails/tabid/143/IndexID/89870/Default.aspx

## Overview of Installed Patches on Agent Machines
This excellent one-liner shows the contents of the PatchList object. It shows the name of an agent and what is in the patch list.
```powershell
Get-SCOMAgent | sort {[string] $_.PatchList} | select Name, PatchList
```
If running this in a large environment, rather than looking at the screen, dump the output to a CSV file using the Export-CSV cmdlet as shown here:
```powershell
Get-SCOMAgent | sort {[string] $_.PatchList} | select Name, PatchList |
Export-CSV -NoTypeInformation C:\output.csv
```
This information was adapted from Stefan Stranger’s blog at
http://blogs.technet.com/b/stefan_stranger/archive/2012/08/06/om2012-quicktip-overview-of-installed-patches-foragents.aspx

## Agent Health State and Grey Agent Detection
While agent health state is an important piece of information to the overall health status of an OpsMgr agent, it may not be the best indicator of an agent’s true health state. If an agent is healthy when it goes offline, it still reflects its healthy state, displaying in the Operations console under Agent State as being Healthy (with a green check mark) but Grey (offline). A better measure of whether an individual agent is healthy and responsive would be checking the HealthServiceWatcher class’s health state. Here is an example that outputs the display name of the agents with the health state of their health service watcher:
```powershell
Get-SCOMClass -Name "Microsoft.SystemCenter.HealthServiceWatcher" |
Get-SCOMclassinstance |sort displayname|FT displayname, healthstate –auto
```
The health state value could be Success (good), Uninitialized (maintenance mode is running), or Error (the Health Service Watcher is offline).

## Report on Agent Primary and Failover Management Servers
You will want to get a report monthly to check that your agents are not attempting to report to a management server previously removed from your environment. This is also a great sanity check to make sure things are set up properly.
```powershell
Get-SCOMAgent|sort ComputerName |
FT -a ComputerName, PrimaryManagementServerName, @{   label="SecondaryManagementServers";
expression={ $_.GetFailoverManagementServers() | foreach { $_.name }}
}
```

## Start a Remote Console Connection
The easiest way to access an OpsMgr PowerShell console from a machine without the Operations console installed that has PowerShell v2 loaded is to establish a connection to a remote management server using PowerShell v2, and then import the OperationsManager module using the Import-Module cmdlet.
1. Run this command from the Operations Manager server (LON-SV1) to enable PowerShell access:
```powershell
Enable-PSRemoting  -Force
```
2. Log on to LON-DC1 and open PowerShell from the Taskbar. Establish a remote session to the server with the OpsMgr module.
```powershell
Enter-PSSession  -ComputerName LON-SV1.Adatum.msft
```
3. Import the OperationsManager module using the Import-Module cmdlet.
```powershell
Import-Module OperationsManager
```
4. Perform some OpsMgr related action, for example:
```powershell
Get-SCOMManagementServer
Get-SCOMAgent
```
5. Disconnect from the remote session.
```powershell
Exit-PSSession
```
