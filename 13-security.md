# Chapter: Security and Compliance

## Operators
To create the user role, log on as an OpsMgr Administrator and navigate to the Administration space in the Operations console. Follow these steps:
1. In the Administration pane, select Security and right-click User Roles. Select New User role, and then select the Advanced Operator profile.
2. On the General page of the wizard, enter a name for the User role such as Adatum_Advanced_Operators and click Add in the User role members section of the page. In the Select User or Groups dialog box, specify the AD users or groups to add to this role and click OK to return to the General page. Click Next. Note that the following screens of the Create User Role Wizard will vary based on the profile type to which this user role is assigned.
3. The Group Scope page asks you to approve groups. Members of this user role can set overrides and monitor objects in approved groups. By default, the entire management group is selected. Unchecking this lets you select specific groups. Click Next when you complete group selection.
4. The Tasks page asks you to Approve tasks members of this user role can execute. All tasks are automatically approved by default. Alternatively, you can select Only tasks explicitly added to the ‘Approved tasks’ grid are approved and press Add to add approved tasks to open the Select Tasks dialog, where you can check the tasks you wish to add. You can view the tasks to select either by task name or management pack order. For this example, the default of All tasks are automatically approved was used. Click Next when finished selecting tasks.
5. The Dashboards and Views page of the wizard lets you define the views and dashboards members of this user role can access. The default is All dashboards and views are automatically approved. If you select Only the dashboards and views selected in each tab are approved, you can select specific dashboards and views in the Monitoring Tree and Task Pane.
Selecting any dashboard under the Monitoring Tree tab gives members of this user role access to data in the data warehouse. Be aware that should you select specific dashboards and views, members of this security role will not automatically have permissions to new views and dashboards later added to OpsMgr unless you rerun the wizard. 
Clicking the Task Pane tab allows you to add dashboards you would like members of this user role to access and view from the Tasks pane. 
Click Next.
6. The Summary page lists a summary. Click Create to create the user role.
7. Log off from LON-SV1 and log on as the user you specified in step 2. Confirm that this user is an operator: it can view, modify and close alerts in the monitoring pane, but it does not have access to the administration pane.
8. Log off from LON-SV1 and log back on as Adatum\Administrator.

## Agent Proxying
To configure agent proxying on an agent-managed computer, follow these steps:
1. In the Operations console, navigate to Administration -> Device Management -> Agent Managed.
2. Right-click LON-DC1 (Domain Controllers normally need the proxying option enabled), select Properties, and then select the Security tab. Check the box Allow this agent to act as a proxy and discover managed objects on other computers, and click OK.

## Determining the SQL Server Port
To identify the port, follow these steps:
1. Run SQL Server Configuration Manager on the system hosting the SQL Server (Start -> All Programs -> Microsoft SQL Server 2012 -> Configuration Tools -> SQL Server Configuration Manager).
2. In the left-hand pane of the console, expand SQL Server Network Configuration.
3. Select Protocols for < instance name >.
4. In the right-hand pane, double-click on TCP/IP.
5. Select the IP Addresses tab.
6. The TCP/IP Properties page shows settings for a number of IP addresses. The port is under the IPAll section, which is at the bottom of the list. 

## Agents Across a Firewall
If you are installing agents on any computer running the Windows Firewall, it is necessary to modify the default firewall configuration. This is also true for computers utilizing the agentless managed feature of OpsMgr.
Use the Group Policy Management Console (GPMC) to create and deploy an OpsMgr firewall exceptions GPO in the domain where OpsMgr will manage computers.
1. Right-click Group Policy Objects node, select New, and create a new GPO named OpsMgr Policy.
2. Right-click the new GPO and select Edit.
3. Navigate to the Computer Configuration -> Policies -> Administrative Templates -> Network -> Network Connections -> Windows Firewall -> Domain Profile node.
4. In the setting Windows Firewall: Allow inbound remote administration exception, enable the setting, then at the Allow unsolicited incoming messages from these IP addresses section, enter the Internet Protocol (IP) addresses and subnets of the primary and secondary management servers for the agent. If all computers are on the same subnet, you can enter the word localsubnet. This setting opens TCP ports 135 and 445 to permit communication using Remote Procedure Call (RPC) and Distributed Component Object Model (DCOM). Click OK.
5. In the setting Windows Firewall: Allow inbound file and printer sharing exception, enable the setting, then at the Allow unsolicited incoming messages from section, enter the IP addresses and subnets of the primary and secondary management servers for the agent in the same manner as the previous step. This opens TCP ports 139 and 445, and UDP ports 137 and 138 to permit network access to shared files. Click OK.
6. In the setting Windows Firewall: Define inbound port exceptions, enable the setting and click the Show button, and enter the port the agent uses to communicate with the management servers (the default is 5723): TCP:< IP address of management server >< subnet >:enabled:OpsMgr Agent. An example entry would be: 5723:TCP:localsubnet:enabled:OpsMgrAgent. Click OK, and then click OK again.
7. Close the Group Policy Editor and return to the GPMC. Go to the Settings tab of the new OpsMgr Firewall Exceptions Policy and select to show all. Verify that the settings are what you configured.
8. Navigate in the GPMC to the domain and/or organizational unit (OU) where the computers to be managed are located. In this example, choose the Adatum.com domain, then right-click and choose to Link an Existing GPO; then select the OpsMgr Policy.
9. Allow the GPO to take effect on prospective managed computers. Automatic group policy refresh occurs within an hour on most Windows computers. To have the new GPO take effect immediately on a particular computer, either restart it or execute the command gpupdate /force.
