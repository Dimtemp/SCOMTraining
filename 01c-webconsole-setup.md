## If time permits: Install the Web console
1. On the LON-SV1 Server, open a PowerShell prompt and enter this command:
```PowerShell
Install-WindowsFeature Web-Windows-Auth, Web-Asp-Net, Web-Request-Monitor, NET-WCF-HTTP-Activation45, Web-Mgmt-Console, Web-Metabase
```
1. This might take several minutes.
1. Open Windows Explorer.
1. Navigate to C:\System Center Operations Manager 2019.
1. Run setup.exe
1. From the splash screen click the large Install link to start a setup wizard.
1. Select Web console. Click Next.
1. Select Installation location. Accept the default or specify your alternative path, and click Next.
1. Setup continues with the message Verifying that your environment has the required hardware and software.
1. If the verification is successful, click Next.
1. At the Specify a Management server page, enter the name of a management server to be used by the Web console only, in this case LON-SV1. The management server you specify will handle data associated with specific management servers or management groups. Normally, this is the name of the first installed management server, or if using a load-balanced management server pool, the virtual server name of the pool. Click Next.
1. At the Specify a web site for use with the Web console page, select an IIS web site to be used for the Web console. Select an existing web site from the available web sites on the local IIS server. Select the Default Web Site. Click Next.
1. At the Select an authentication mode for use with the Web console page, select Mixed authentication mode. Click Next.
  1. Note: If you are publishing the Web console to the Internet, select Use Network Authentication. Use Mixed Authentication only if you are using the Web console in intranet scenarios. 
1. At the Web console Installation Summary page, review your selections. Take note of the Uniform Resource Locators (URLs) to be used for accessing the Web console and APM features. To continue, press Install.
1. Setup is complete when all green checkmarks appear in the left column. Any component that failed to install is marked with a red “X.” 
