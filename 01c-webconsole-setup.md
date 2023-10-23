# If time permits: Install the Web console

# Prerequisites
1. In Hyper-V Manager, select the LON-SV1 VM and mount the Windows 2019 ISO.
1. Log on to the LON-SV1 VM using the ADATUM\Admin account.
1. Install dotnet 3.5 using this command: ```Dism.exe /online /enable-feature /featurename:NetFX3 /All /Source:D:\sources\sxs /LimitAccess```
1. This might take several minutes.
1. Open an elevated PowerShell console and enter this command:
```PowerShell
Install-WindowsFeature Web-Asp-Net, Web-Windows-Auth, Web-Request-Monitor, Web-Metabase, Web-Mgmt-Console, NET-WCF-HTTP-Activation45
```
1. This might take several minutes.


## Install the web console
1. Open Windows Explorer.
1. Navigate to C:\System Center Operations Manager.
1. Run setup.exe
1. From the splash screen click the large Install link to start a setup wizard.
1. Click Add a feature.
1. Select Web console. Click Next.
1. Setup continues with the message Verifying that your environment has the required hardware and software. If there are issues, the message The Setup wizard cannot continue appears. This means additional hardware resources or software is required to continue. The yellow Pending Restart Check can be ignored.
1. After resolving any prerequisite problems, click Verify Prerequisites Again. If verification is successful, click Next.
1. At the Specify a web site for use with the Web console page, select the Default Web Site to be used for the Web console. Click Next.
1. At the Select an authentication mode for use with the Web console page, select Mixed authentication mode. Click Next.
  1. Note: If you are publishing the Web console to the Internet, select Use Network Authentication. Use Mixed Authentication only if you are using the Web console in intranet scenarios. 
1. Set Windows Update to Off. Click Next.
1. At the Web console Installation Summary page, review your selections. Take note of the Uniform Resource Locators (URLs) to be used for accessing the Web console and APM features. To continue, press Install.
1. Setup is complete when all green checkmarks appear in the left column. Any component that failed to install is marked with a red "X".

## Run the web console
1. Click Start, Microsoft System Center, Web Console
1. This opens the default web browser.
1. Not all workspaces are exposed in the web console. Verify at least the Monitoring and My Workspace panels are visible.
