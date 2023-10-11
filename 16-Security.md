# Chapter: Security and Compliance


## Operators
1. Log on to **LON-SV1** and start **Active Directory Users and Computers**.
1. Open the Users container and create a new user with the name **Joe**. Use this password: Pa55w.rd
1. Disable the option **User must change password at next logon** and Next, and Finish, to create the user account.
1. To create the user role, open the Operations console and navigate to the **Administration** space.
1. In the Administration pane, select **Security** and right-click **User Roles**. Select **New User role**, and then select the **Advanced Operator** profile.
1. On the General page of the wizard, enter a name for the User role such as **Adatum_Advanced_Operators** and click Add in the User role members section of the page. In the Select User or Groups dialog box, specify **Joe** and click OK to return to the General page. Click Next.
1. The Group Scope page asks you to approve groups. Members of this user role can set overrides and monitor objects in approved groups. By default, the entire management group is selected. Unchecking this lets you select specific groups. Click Next when you complete group selection.
1. The Tasks page asks you to Approve tasks members of this user role can execute. All tasks are automatically approved by default. Alternatively, you can select Only tasks explicitly added to the **Approved tasks** grid are approved and press Add to add approved tasks to open the Select Tasks dialog, where you can check the tasks you wish to add. You can view the tasks to select either by task name or management pack order. For this example, the default of All tasks are automatically approved was used. Click Next when finished selecting tasks.
1. The Dashboards and Views page of the wizard lets you define the views and dashboards members of this user role can access. The default is **All dashboards and views are automatically approved**. If you select Only the dashboards and views selected in each tab are approved, you can select specific dashboards and views in the Monitoring Tree and Task Pane.
1. **Note.** Selecting any dashboard under the Monitoring Tree tab gives members of this user role access to data in the data warehouse. Be aware that should you select specific dashboards and views, members of this security role will **not automatically have permissions to new views and dashboards** later added to OpsMgr unless you rerun the wizard. 
1. Clicking the Task Pane tab allows you to add dashboards you would like members of this user role to access and view from the Tasks pane. 
1. Click Next.
1. The Summary page lists a summary. Click Create to create the user role.
1. Click Start, right click the Operations Manager icon, select More, Run as different user.
1. Enter the user name and password for the account you created previsously.
1. Confirm that this user is an operator: it has access to the Monitoring, Authoring and My Workspace panes. It can view, modify and close alerts in the monitoring pane, but it does not have access to the administration or reporting panes.


## Agent Proxying
Agent proxying allows agents to submit data not only for their own device but also for other devices that might not be able to host an agent themselves. Domain Controllers normally need the proxying option enabled. To configure agent proxying on an agent-managed computer, follow these steps:
1. In the Operations console, navigate to Administration -> Device Management -> Agent Managed.
1. Right-click **LON-DC1**, select **Properties**, and then select the **Security** tab. Check the box **Allow this agent to act as a proxy and discover managed objects on other computers**, and click OK.


## Determining the SQL Server Port
To identify the port, follow these steps:
1. Run SQL Server Configuration Manager on the system hosting the SQL Server (Start -> All Programs -> Microsoft SQL Server ## -> SQL Server Configuration Manager).
1. In the left-hand pane of the console, expand SQL Server Network Configuration.
1. Select Protocols for < instance name >.
1. In the right-hand pane, double-click on TCP/IP.
1. **Note.** TCP/IP might be disabled. This should be set to enabled if the SQL Server is not running on the same server as the Operations Manager server.
1. Select the IP Addresses tab.
1. The TCP/IP Properties page shows settings for a number of IP addresses. The port is under the IPAll section, which is at the bottom of the list.


## Agents Across a Firewall
If you are installing agents on any computer running the Windows Firewall, it is necessary to modify the default firewall configuration. This is also true for computers utilizing the agentless managed feature of OpsMgr. Use the Group Policy Management Console (GPMC) to create and deploy a firewall exceptions GPO in the domain where OpsMgr will manage computers.
1. Start an elevated PowerShell console and run this command: ```Add-WindowsFeature GPMC```
1. Click Start, select Administrative tools, and click **Group Policy Management**.
1. Navigate to Domains, adatum.msft, Group Policy Objects.
1. Right-click Group Policy Objects node, select New, and create a new GPO named OpsMgr Policy.
1. Right-click the new GPO and select Edit.
1. Navigate to the Computer Configuration -> Policies -> Administrative Templates -> Network -> Network Connections -> Windows Defender Firewall -> Domain Profile node.

### inbound remote admin
1. Open the Windows Defender Firewall: Allow inbound remote administration exception
1. Enable the setting.
1. At the **Allow unsolicited incoming messages from these IP addresses** section, enter the Internet Protocol (IP) addresses and subnets of the primary and secondary management servers for the agent. If all computers are on the same subnet, you can enter the word **localsubnet**. This setting opens TCP ports 135 and 445 to permit communication using Remote Procedure Call (RPC) and Distributed Component Object Model (DCOM). Click OK.

### inbound file and printer sharing
1. Open the Windows Defender Firewall: Allow inbound file and printer sharing exception
1. Enable the setting.
1. At the Allow unsolicited incoming messages from section, enter the IP addresses and subnets of the primary and secondary management servers for the agent in the same manner as the previous step. This opens TCP ports 139 and 445, and UDP ports 137 and 138 to permit network access to shared files. Click OK.

### inbound port
1. Open the Windows Defender Firewall: Define inbound port exceptions
1. Enable the setting.
1. click the Show button
1. Enter the port the agent uses to communicate with the management servers (the default is 5723): TCP:< IP address of management server >< subnet >:enabled:OpsMgr Agent. An example entry would be:
```5723:TCP:localsubnet:enabled:OpsMgrAgent```
1. Click OK, and then click OK again.

### verify
1. Close the Group Policy Editor and return to the GPMC. Make sure the OpsMgr Firewall Exceptions Policy group policy object you just created is selected.
1. Go to the Settings tab and select to show all. Verify that the settings are what you configured.
1. Navigate in the GPMC to the domain and/or organizational unit (OU) where the computers to be managed are located. In this example, choose the Adatum.com domain, then right-click and choose to Link an Existing GPO; then select the OpsMgr Policy.
1. Allow the GPO to take effect on prospective managed computers. Automatic group policy refresh occurs within an hour on most Windows computers.
1. To have the new GPO take effect immediately on a particular computer, either restart it or execute the command ```gpupdate /force```.

### unlink the group policy object
Unlinking the group policy object reverts the firewall to the previous configuration. This is to prevent any problems for the remainder of the course.
1. Return to the Group Policy Management console.
1. Navigate to Domains, adatum.msft.
1. Right-click the SCOM GPO, select Delete.
1. Click OK.
