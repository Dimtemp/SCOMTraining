# Chapter: Installing and Configuring Agents

## Using the Discovery Wizard
Using the wizard is the easiest method to deploy OpsMgr agents. To launch the Discovery Wizard to discover Windows systems, follow these steps:
1. Open the Operations console and navigate to Administration.
1. Under **Administration Overview**, click **Required: Configure computers and devices to manage** 
1. On the Discovery Type page, choose **Windows computers** from the options available (Windows computers, UNIX/Linux computers, and Network devices).
1. The next page asks you to select either automatic or advanced discovery. Select **Automatic computer discovery** and click Next.
> TIP : AVOID USING THE SERVERS ONLY OPTION IN THE DISCOVERY WIZARD.
> 
> It is a best practice to not use the **Servers Only** option during a discovery as the filter requires contacting each machine for verification. This process slows down the discovery and can lead to discovery failures from timeouts.
1. The Administrator Account page allows you to choose the default account or specify another user account when installing the OpsMgr agent. The default is **Use Selected Management Server Action Account** (also referred to as the MSAA). If your MSAA account is not a domain administrator or at least a local administrator on the target workstation, you can provide credentials for this discovery process. In this case choose **Use Selected Management Server Action Account**. Click Discover to continue.
1. The next page lists the systems available for agent installation (systems that already have the OpsMgr agent are not displayed). Select the **LON-DC1** server, validate the Management Mode is **Agent**, and click Next to continue.
1. Take the defaults on the Summary page for the agent installation folder (%ProgramFiles%\Microsoft Monitoring Agent) and for the agent action account to use the credentials of the Local System account.
1. **Unselect** the **Install APM** option.
1. Click Finish to begin installing the OpsMgr agents.
1. The status of each agent deployment displays on the Agent Management Task Status page. The status starts at Queued, changes to Started, and moves to either Success or Failure. Should the agent deployment fail, click the targeted computer; the task output box provides details on why it failed. Click Close when this deployment is complete (deployments continue when the Agent Management Task Status page is closed).

## Approval Process
OpsMgr’s default configuration rejects manually installed agents. Change this configuration in the Administration node of the Operations console by following these steps:
1. Navigate to Administration -> Settings -> Security. Right-click Security and select Properties.
1. The General tab shows the default configuration is Reject new manual agent installations. Select the option that says **Review new manual agent installations in pending management view**.
1. If you choose the option to review new manual agent installations, a check box is available that reads **Automatically approve new manually installed agents**. If you select this option, new manual agents are automatically approved. If you do not choose this second option, manually installed agents display in the Operations console, under Administration -> Device Management -> Pending Management, where you can approve or reject their installation.


## Configuring Active Directory Integration
Active Directory Integration enables domain member computers to automatically find a management server. It creates a container in the domain root of Active Directory named OperationsManager. This container is used by clients to determine the management group and management server with which they will communicate.

### Preparing Active Directory
1. Open the **Active Directory Users and Computers program**.
2. In Active Directory, create a new global security group with the name **ADIntegration**.
3. Add the computer accounts belonging to the AD Assignment Resource Pool: **LON-SV1**.
4. To view members of this resource pool, navigate to **Administration -> Resource Pools**, right-click **AD Assignment Resource Pool**, and choose **View Resource Pool Members** (this should contain all management servers in the management group by default).
5. To create the container Operations Manager uses to store information for AD Integration, open a command prompt (not PowerShell) and enter these commands:
> **cd %ProgramFiles%\Microsoft System Center 2019\Operations Manager\Server**
> 
> **MOMADAdmin.exe OMGRP Adatum\ADIntegration Adatum\Administrator Adatum**
1. The parameters are as follows:
    - Management group name. You can find the management group name by opening the Operations Manager console and looking at the name of the management group, shown on the title of the console.
    - MOMAdminSecurity group name: ADIntegrationGroup, this is the group created in the first step.
    - RunAs account name: Specify the account that is used for rules to run on the agent. You can find this by navigating in the Operations Manager console to **Administration -> Run As Configuration -> Accounts -> Type of Action Account**.
    - Domain in which to create the container.
1. A successful run of MOMADAdmin indicates it successfully created the container and added the appropriate security group to the container.

### Configuring Operations Manager
1. From the Administration pane, create rules for AD Integration that indicate which servers communicate with a given management server. Configure AD Integration per management server in **Administration -> Device Management -> Management Servers** by right-clicking a server and choosing Properties.
1. Click Add to start the Agent Assignment and Failover Wizard, which specifies the domain and defines the inclusion, exclusion, and failover criteria:
    - Inclusion criteria: Define those systems that will report to this management server. LDAP queries can be created based on a naming convention, or an OU or group membership. Use the * wildcard in this exercise.
    - Exclusion criteria: Define any systems that will not report to this management server. This works similarly to the inclusion page; here you can write an LDAP query to exclude systems from reporting to this management server. **Leave this step blank**.
    - Failover: Choose a random failover. It’s also possible to specify management servers for failover. When configuring failover, consider that the failover server must be able to support the total number of agents that would report to it should the primary management server fail. As an example, if there are 2,000 servers reporting to a primary server and 2,000 servers reporting to the failover server, if the primary failed the failover server would now be expected to support 4,000 servers, which might be beyond the supported number of agents per management server.

### Configure the Operations Manager Administrator role
1. Navigate to **Administration -> Security -> User Roles -> Operations Manager Administrators**.
2. The group specified when running MOMADAdmin must be added to the Operations Manager Administrator role: **Adatum\ADIntegration**.
3. If this step does not occur, Operations Manager raises an alert indicating that this step is required for AD Integration to function.

### Verification
After configuring AD Integration, you must validate it is functional. There are multiple steps associated with validation, including checking AD, agent event logs, and the registry key on the agent.
> NOTE: Since the AD Integration rule that is responsible for the correct configuration only runs once per hour you can skip the following three verification steps. Make sure you perform the following three steps after one hour.
1. Open **Active Directory Users and Computers**. Select **View -> Advanced Features**. Don’t forget to click Refresh. Within the container there should be another container matching the name of the management group, and within the management group-named folder a **HealthServiceSCP** folder and a domain local security group. After defining the AD auto assignment information, a container with the name of the management server and _SCP on the end, and two domain local security groups based on the management server name (with _PrimarySG_# and _SecondarySG_#) are added to the container for the management group.
1. Agent Event Logs: An agent must be installed without specifying management group information to use Active Directory Integration. When the System Center Management service starts, events are logged to the Operations Manager event log, indicating AD Integration is configured and that the agent is able to identify its management server.
1. Registry Key: A registry key is created on the agent indicating AD Integration is configured for the agent. This key is named EnableADIntegration. Open the registry editor and navigate to **HKLM\System\CurrentControlSet\Services\HealthService\Parameters\ConnectorManager**. A value of 0 indicates Active Directory Integration is turned off, and a value of 1 indicates that Active Directory Integration is turned on. This value can be changed on an agent, but do not manipulate this registry key on a management server.
