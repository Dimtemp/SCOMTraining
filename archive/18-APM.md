# Chapter: Monitoring .NET Applications

## Required
- IIS MP
- Print spooler service monitor

## Preparation
1. In the Operations console, navigate to **Administration -> Installed Management Packs**.
2. Verify you have the **Windows Server 2016 Internet Information Services 10** management pack imported. If it is not, return to exercise **03 Management Packs** and import it.
3. Import the APM management pack by clicking the Tasks menu, select Actions, **Import Management Packs**.
4. Click Add, **Add from disk**. Select No for the Online Catalog Connection dialog.
5. Navigate to **C:\System Center Operations Manager\Management Packs** folder and select the **Microsoft.SystemCenter.APM.Web.IIS10.mp** file. Click Open.
7. Click Install. Click Close after the import is finished.

## Create the Monitor
1.	In the Operations console, navigate to **Authoring -> Management Pack Templates**.
2.	Right-click and select **Add Monitoring Wizard**. Select **.NET Application Performance Monitoring** and click Next to continue.
3.	Use **MyAPM** as the name. Optionally enter a description.
4.	Select the **Sample** management pack. Create it if needed. Notice you will receive a warning if the Operations Manager APM Web IIS 7 management pack is not imported. Click Next.
5.	The next page asks you to add application components to monitor. Click Add to include application components that will be part of this application; these components are discovered by the management packs included in the installation.
6.	Use the Search button and select several Application components. The components that you pick are not relevant in this example. Make sure that you select at least one.
7.	Click OK when you complete adding components to return to the What to Monitor page.
8.	Note: In short, default configuration includes scanning only the website and one level of subapplication folders, and searching only for files with certain extensions including .aspx, .asmx, and .svc. Based on these criteria, the application components are prefilled into the wizard grouped by the application full path on the IIS (such as Default Web Site\VirtualDir) and not based on the file system path. You can adjust the discovery mechanism by overriding the rule’s properties.
9.	You can also tag this configuration by selecting the **Environment** drop-down and assigning it to Production, Staging, Test, Development, or giving it a custom tag. This is useful when you have multiple environments hosting the same application that should be managed separately and potentially have different application monitoring settings.
10.	The last option on this page is to limit the monitoring to a specified group of servers by selecting a Targeted group ; this is a standard computer group that can include static or dynamic members. Consider defining groups to separate environments from one another and limiting the number of excessive discoveries when you know where the application will be running. You might also define groups if you want to roll out application monitoring in stages; you can add new computers to the group determined by your current deployment phase. Select the Search button to open the Search dialog box. Click **Search** and select the **Windows Server Computer Group** and click ok.
11.	After completing the What to Monitor page, click Next to continue.
12.	The next page of the wizard is the Server-Side Configuration page. The settings for monitoring performance and exception alerts control the type of alerts that need to be fired based on the type. By default, exception alerts include only security and connectivity failures and not application failures. To change these and other settings requires additional configuration.
13.	The alerting threshold is one of the key settings for performance monitoring and defines what is considered as normal transaction performance and what is slow.
14.	Each time a transaction is executed, the APM agent monitors its duration and compares this with the alerting threshold; a performance alert is generated if the transaction runs slower than that threshold.
15.	Even if the performance events alerts setting is not checked, the alerting threshold is still important since it is used for the events collected by APM agent against the application component(s) and is available in the Application Diagnostics console. Picking a threshold is always not obvious, and you should adjust thresholds over time based on application performance. Thresholds defined for business logic components such as web services or WCF should be less than those for the front-end application components, as front-end components call business logic and run slower since they contain their own logic in addition to those calls.
16.	Complete the wizard, which will apply the settings to the application components, create required dashboards, and alert when it is appropriate. You must recycle IIS or Windows services on the monitoring servers to start .NET performance monitoring.

## Monitor .NET Applications
1. Open a PowerShell prompt.
2. Enter the following command and press Enter: ```Restart-Service spooler```
3. Return to the Operations console, navigate to **Monitoring -> Application Monitoring**.
4. Open .NET Monitoring, select the Monitored Applications view and observe the MyAPM application.
