# Chapter: Cross Platform (optional)

## Preparation
Perform this procedure from the host server
1. Download a supported Linux installation ISO (e.g. Debian, CentOS).
1. Open Hyper-V Manager
1. Create a new VM with the name LON-LNX.
1. Open the settings of the LON-LNX virtual machine and connect the downloaded ISO.
1. Start the VM and follow the OS installation procedure.
1. Use this password for the root user: Pa55w.rd

## Configuring Accounts and Profiles
Perform the following steps from the LON-SV1 to create each UNIX/Linux action account:
1. In the Operations console, open Administration -> Run As Configuration. -> UNIX/Linux Accounts.
2. In the Tasks pane, click Create Run As Account.
3. On the Account Type page, choose Monitoring Account or Agent Maintenance Account.
4. On the General Properties page, provide a name and description for the account. The description is optional, but a good way to ensure other OpsMgr administrators of the account’s intended purpose.
5. On the Account Credentials page, provide account credentials that can be used for the Run As account type that you selected. Select Next to continue.
6. Configure distribution of the Run As account: On the Distribution Security page, define whether these credentials will be stored in a less- or more-secure configuration:
  •	More secure: With the more-secure approach, you select the computers that will receive the credentials.
  •	Less secure: With the less-secure option, the credentials are sent automatically to all managed computers.
  The more-secure approach is strongly recommended, targeting the Cross Platform Resource Group for distribution.

Complete this procedure for the UNIX/Linux privileged monitoring account, the unprivileged monitoring account, and agent maintenance accounts.

After creating the Run As accounts, add each Run As account to the applicable profile.
There are three profiles to configure:
  •	UNIX/Linux Action Account: Add a monitoring Run As account to this profile that has unprivileged credentials.
  •	UNIX/Linux Privileged Account: Add a monitoring Run As account to this profile that has privileged credentials or credentials to be elevated.
  •	UNIX/Linux Agent Maintenance Account: Add a monitoring Run As account to this profile that has privileged credentials or credentials to be elevated.

To configure these profiles, perform the following steps:
1. In the Operations console, navigate to Administration -> Run As Configuration -> Profiles.
2. In the list of profiles, right-click and select Properties on one of the following profiles:
  •	UNIX/Linux Action Account
  •	UNIX/Linux Privileged Account
  •	UNIX/Linux Agent Maintenance Account
3. In the Run As Profile Wizard, click Next until you get to the Run As Accounts page.
4. On the Run As Accounts page, click Add to add a Run As account you created. Select the class, group, or object that will be accessed using the credentials in the Run As account. Click OK and Save.

Repeat each of these steps for the three profiles with their matching Run As accounts.

With the UNIX/Linux Run As configuration complete, you can import the appropriate UNIX/Linux management packs and then begin discovering UNIX/Linux systems.

## Import Management Packs
1. In the Operations console, open Administration -> Management Packs -> Import Management Packs.
2. Click Add, Add from disk. Select No.
3. Browse to D:\ManagementPacks, and select all Management Packs that start with the name “Microsoft.Linux.Universal”. There should be four.
4. Click Import.

## Configure WinRM for Basic Authentication
1. From the LON-SV1, open a Command Prompt and enter this command:
2. Winrm set winrm/config/client/auth @{Basic="true"}

## Discovering Systems and Deploying the Agent
Discovering a UNIX/Linux system is a relatively straightforward, wizard-driven process, although discovery without root is a bit more nuanced. Follow these steps to discover UNIX/Linux systems:
1. Navigate to Administration -> Device Management -> Agent Managed and right click to select the Discovery Wizard. The wizard defaults to Windows computers, but select the UNIX/Linux computers option and click Next.
2. On the Discovery Criteria page, select the Add button. In the Discovery Criteria dialog, enter the following information: 
  ▶ Discovery Scope: < IP address or FQDN > and SSH port number of the target host. To add additional hosts, click Add row and enter additional IP addresses and fully qualified domain names (FQDNs) as necessary, using one line per IP address or FQDN.
  ▶ Discovery type: Select All computers.
3. Click Set credentials to launch the Credential Settings dialog.
4. Select the User name and password radio button and enter the following values:
  ▶ User name: root
  ▶ Password & confirm password: Pa55w.rd
5. Click Discover to start the discovery process.
6. Ensure the Discovery Type is set to All computers, and discovery and installation should proceed successfully. Click Save.
7. The discovery process will take from several seconds to a few minutes, depending on the number of hosts in the list. When the process is complete, a list of UNIX and Linux computers is displayed.
8. On the Discovery Criteria page, at the Select target resource pool drop-down, select Cross-Platform Resource Pool, and click Discover.
9. Select the check box next to the computers on which you would like to install an agent and click Next.
10. When the process is complete, all computers to which an agent was deployed successfully will reflect a Successful status in the Computer Management Progress dialog.
11. Click Done to exit the wizard.
