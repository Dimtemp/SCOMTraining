# Chapter: Client Monitoring (optional)

## Enabling Agentless Exception Monitoring (AEM) on a Management Server
To use AEM, you must activate one of the management servers in your environment to provide the AEM feature. Activate the server using the Operations console in the Administration pane under Device Management -> Management Servers. Right-click the management server and select Configure Client Monitoring. This starts a wizard that enables AEM on the server. Follow these steps:
1. The wizard starts with an introductory page, describing each of the steps that will occur: configuring where Customer Experience Improvement Program data is sent, where errors are sent, transmission settings, and end-user error crash behavior. Click Next.
2. On the CEIP Forwarding page of the wizard, configure the Customer Experience Improvement Program. You can configure how CEIP collects data in several ways:
▶ Continue to send data directly to Microsoft (default).
▶ Use the selected management server to collect and forward data to Microsoft.
If you select the second option, you can specify whether to use the Secure Sockets Layer (SSL) protocol, whether you use Windows authentication, and the specific port number (which defaults to 51907).
3. Specify the following on the Error Collection settings page:
▶ The location of the file share path (which must have at least 2GB free disk space). Use C:\AEM.
▶ Whether error reports will be gathered for Windows Vista and later computers, and if so, what port to use (defaults to 51906).
▶ Whether you will use SSL and Windows Authentication for Vista and later clients.
▶ The organization name to be displayed in messages on the local client. Use Adatum.
4. On the Error Forwarding settings page, select to forward basic or detailed error signature information to Microsoft. Allowing detailed forwarding means that when Microsoft requests additional data about the hang or crash (because Microsoft has not seen the error before), the additional data is forwarded along with the error signature. Click Next.
5. At the Create File Share page, select to use the Action Account and click Next. The wizard will create the file share and report success, then click Next again.
NOTE If the wizard takes a very long time, please verify whether the broker is enabled. Open SQL Management Studio, Open the Properties of the OperationsManager database, click Options and enable the broker.
6. The wizard completes with the Client Configuration Settings page, where you confirm the folder location to save the group policy administrative template (a file with the .ADM extension). The default is the Documents folder of the current user. Select Finish.
TIP: INSTALL GPMC   If your OpsMgr administrator account is also a domain administrator, save time by installing the Group Policy Management Console (GPMC) on the management server that will have AEM enabled. You will need to import, link, and edit domain group policy. To install GPMC on the management server, use the Add Features Wizard in Windows Server Manager and select the Group Policy Management feature.

## Deploying the AEM Policy
Enabling AEM on a management server by running the Configure Client Monitoring wizard also saves a group policy template with the .ADM file extension. The file name will be the FQDN of the management server. Here are the recommended steps to deploy AEM policy to your domain:
1. Open the GPMC in Administrative Tools and navigate to the Group Policy Objects node in the domain. Select the node, right-click, and choose New.
2. Name the policy as desired. In this example use AEM Policy.
3. Locate the new policy in the tree below the Group Policy Objects node, select the policy, right-click, and choose Edit.
4. The Group Policy Object Editor opens. Navigate to the Computer Configuration -> Policies -> Administrative Templates node, right-click and select Add/Remove Templates.
5. The Add/Remove Templates dialog opens; click Add. Browse to the location of the template file saved by the Configure Client Monitoring Wizard. The path is the Documents folder of the current user. Select the file and click Open.
6. Observe that the Current Policy Templates list now includes the imported template. Click Close.
7. Returning to the Group Policy Object Editor, notice there is now a Microsoft Applications node under Computer Configuration -> Policies -> Administrative Templates -> Classic Administrative Templates (ADM).
8. Expand the Microsoft Applications -> System Center Operations Manager (SCOM) node to reveal the four subordinate nodes that begin with the words SCOM Client Monitoring.
9. Beginning with the first node, SCOM Client Monitoring CEIP Settings, select the node on the left side of the GPMC and double-click to open each Settings item in the right side of the GPMC. With the individual Settings item open, select the Enabled radio button. This exposes the values for that setting that you selected when running the Configure Client Monitoring Wizard; click OK.
10. Walk the tree of subordinate nodes in the System Center Operations Manager (SCOM) node, selecting and enabling each feature as desired. (Repeat step 9 for each client monitoring setting you want to configure.) In all there are 11 Settings items that correspond to the questions and responses utilized by the Configure Client Monitoring Wizard.
11. Now, navigate to Computer Configuration -> Policies -> Administrative Templates -> System -> Internet Communications Management -> Internet Communications. Double-click Turn Off Windows Error Reporting, select Disabled, and click OK.
12. Optionally disable the User Configuration portion of the GPO. In environments with many GPOs, user logon processing is faster when you disable the user portion of GPOs that contain no user settings. To disable the User Configuration portion of the GPO, right-click the root of the policy in the Group Policy Object Editor, and select Properties. Tick the Disable User Configuration Settings item and click OK.
13. Select File -> Exit to close the Group Policy Object Editor and return to the GPMC.
14. Select where to link the new GPO. Because there is only one AEM server per management group and since you want to include all computers in the domain, you will usually link the GPO at the root of the domain.
To enable AEM on all computers in the domain, right-click the domain object and choose Link an Existing GPO. Select the GPO and click OK.
15. The new GPO appears under the domain root with a shortcut (link) icon. Close the GPMC.

## Retrieving AEM results
Log on to LON-W10 and download NotMyFault.zip from the following URL:
http://technet.microsoft.com/en-us/sysinternals/bb963901
Unzip the archive and use NotMyFault.exe to implement a generic exception.
Open Performance Monitor, right click Monitoring Tools and select View System Reliabilty. Notice the red X-symbol indicating the application exception previously created.
Log on to LON-SV1 and open the Windows Explorer.
Navigate to the C:\AEM folder (or the folder you created yourself) and notice the crash reports uploaded by the client.
Open the Operations Manager console and navigate to the AEM view.

## Business Critical Monitoring Management Pack
NOTE   To perform the following the exercise download and install the Windows Client management pack from the Microsoft website. This management pack cannot be directly imported from the Operations Manager console. Make sure that you import the MP files and the XML file included in the MSI. Download from:
http://www.microsoft.com/en-us/download/details.aspx?id=15700
Business Critical Monitoring is the most comprehensive client monitoring solution with OpsMgr. This is the only level of monitoring that can watch client computers individually and generate alerts. Adding client computers to Business Critical Monitoring requires more overhead than other types of client monitoring. You can only bring client computers into Business Critical Monitoring after discovery takes place and the clients have an agent installed on them. This means that client computers must first be made Collective Monitoring clients; then they can be promoted to Business Critical Monitoring status. Here are the steps to perform to add client computers to Business Critical Monitoring:
1. Navigate to Authoring -> Groups.
2. Type Business Critical in the Look for box and click Find Now.
3. Select the appropriate group for the operating system of the client computers to add. For example, to add Windows 7 client computers, select the All Business Critical Windows 7 Clients group. Right-click the group and select Properties.
4. On the Explicit Members tab, select Add/Remove Objects.
5. In the Search for drop-down box, select Windows 7 Client Computer and select Search.
6. All Windows 7 computers with OpsMgr agents installed will appear in the Available items area.
7. Select one or more computers to be added to Business Critical Monitoring, and click Add. After confirming that the desired computers are in the Selected objects area, click OK, then click OK again.
8. Repeat steps 3 through 7 for other operating systems where you have client computers to be added to Business Critical Monitoring.
To enable Advanced Monitoring on an object of interest, such as the network interface of a mission-critical client computer, follow these steps:
1. Open the Authroing pane, select Monitors and search for Network Adapter Connection Health, scope under Windows 7.
2. Right-click and select Override and select Override the Monitor -> For a Specific Object.
3. The Select Object picker should appear; select the matching object that you want to monitor and click OK.
4. The Override Properties page should appear; tick the Override box in the top Enabled line and change the Override Setting from False to True. Save the override to the Sample management pack and click OK.
5. Click OK again and close the Health Explorer. Within several minutes, the state icon for the object should change from Not Monitored to Healthy. 
In addition to the generic views in the Monitoring space populated with data from business critical client computers, you can run reports to learn more details about client computer performance.
Follow these steps to produce a Disk Space Usage Report.
1. Navigate to the Reporting pane and select the Windows 7 Client Operating Systems (Aggregate) report folder.
2. Select the Windows 7 Disk Space Usage Report and click Open.
3. After viewing the report, optionally save the report as a PDF, XLS, or other file type by selecting File -> Export.
