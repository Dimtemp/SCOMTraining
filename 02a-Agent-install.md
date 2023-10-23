# Chapter: Installing and Configuring Agents

## Prerequisistes
1. Open the LON-DC1 VM.
1. From the LON-DC1 VM, open a PowerShell window.
1. Run this command from the PowerShell prompt: Invoke-Command -ComputerName LON-SV1 { Get-NetFirewallRule | Where-Object DisplayGroup -match print | Enable-NetFirewallRule }
1. Open Windows Explorer and enter this in the address bar: ```\\LON-SV1\E$```
1. Navigate to the Lib folder and start the .NET Framework setup by double clicking this file: **ndp472-kb4054530-x86-x64-allos-enu**.
1. Follow the wizard using all default values.
1. Switch to the LON-SV1 VM Connection window.


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
1. **Unselect** the **Install APM** option if it is selected.
1. Click Finish to begin installing the OpsMgr agents.
1. The status of each agent deployment displays on the Agent Management Task Status page. The status starts at Queued, changes to Started, and moves to either Success or Failure. Should the agent deployment fail, click the targeted computer; the task output box provides details on why it failed. Click Close when this deployment is complete (deployments continue when the Agent Management Task Status page is closed).

## Approval Process
Operations Manager by default rejects agents that are manually installed. Change this configuration in the Operations Manager console by following these steps:
1. Navigate to Administration -> Settings -> Security. Right-click Security and select Properties.
1. The General tab shows the default configuration is Reject new manual agent installations. Select the option that says **Review new manual agent installations in pending management view**.
1. If you choose the option to review new manual agent installations, a check box is available that reads **Automatically approve new manually installed agents**. If you select this option, new manual agents are automatically approved. If you do not choose this second option, manually installed agents display in the Operations console, under Administration -> Device Management -> Pending Management, where you can approve or reject their installation.
1. For now, select the **Automatically approve new manually installed agents** option.
