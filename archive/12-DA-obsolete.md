NOTE   The following management packs need to be imported to be able to perform the exercices:
- SQL
- IIS
•	DNS
•	Information Worker Windows Explorer
•	Information Worker Windows Internet Explorer

The OLE DB Data source needs to be running.


## Creating the Web Application
The first step to enable the Client Web Access (Internet Explorer Service) DA is creating one or more web applications using the Add Monitoring Wizard in the **Authoring** space. You then use the Distributed Application Designer, specifying the Windows Internet Explorer Service template, to add the web application as an object to monitor. The scenario demonstrates the Internet Explorer Service DA for employees accessing a business-critical website. The goal of the DA is to detect problems accessing that website. Follow these steps to define the critical website:


1. In the Authoring space, navigate to the Management Packs node and run the Add Monitoring Wizard.
2. Select Web Application Transaction Monitoring as the monitoring type and click Next.
3. On the Web Application Name and Description page, enter a name and description for the critical website. The name will appear as a component of the DA, so name it something that makes the most sense in that context. For this example, choose Critical Website Access for the name. Select the Sample management pack to save your changes and click Next.
4. Enter and test the URL you will be monitoring. This test is performed from the management server you are currently connected to and does not necessarily validate the URL is reachable from the watcher node you select in the next step. The results of the test are displayed along with a Details button. The tabs show how you can expose the actual Hyper Text Markup Language (HTML) returned from the monitored web server. You can later use details from the HTML reply to validate proper response from the critical website.
5. On the Choose Watcher Nodes page, select one or more managed computers to act as watcher nodes, preferably from multiple and different locations. Select at least two watcher nodes for each web address. This way when you are alerted to a problem accessing the critical website, you can more easily rule out individual watcher node failure. Each instance of a watcher node monitoring a URL creates a new object in the Web Applications State view, which becomes usable by the DA.
By default, the web query runs every 2 minutes. This might be too short an interval if you have a larger number of watcher nodes or a complex set of web application tests. Adjust the query interval as appropriate and click Next.
6. Click Create and wait several moments. You should then be able to locate the new web application monitors in the Monitoring -> Web Application Transaction Monitoring -> Web Applications State view folder. Each watcher node will have a separate monitor.

## Creating the Windows Internet Explorer Service DA
After configuring your web applications, the watcher nodes should appear in a healthy state at Monitoring -> Web Application Transaction Monitoring -> Web Applications. You can now create the Critical Website Access DA, in which the watcher nodes will participate. Follow these steps:
1. Navigate to and select **Authoring** -> Distributed Applications. Right-click and choose Create a new distributed application.
2. Enter a name and description for the DA. This name will appear in the Monitoring -> Distributed Applications global view, so use a name that communicates its purpose. For this example, select the same name Critical Website Access used when defining the web application.
3. Choose the Windows Internet Explorer Service template. (This template is available as part of the Microsoft Information Worker management pack; you must install this management pack to be able to see the template.)
4. Select a custom management pack to save the DA; this should be the same management pack to which you saved the web application.
The next part of creating the DA is to add the components. The following steps populate the DA components with managed objects:
1. On the left side of the Distributed Application Designer, under Objects, double-click the Perspective object type tile.
2. Click the Object tile at the top of the object list to sort the perspectives by object name.
3. Locate and select both Critical Website Access watcher nodes; these are the ones created as web applications.
4. Right-click and then select Add To -> Critical Website Access Windows Internet Explorer Clients node. The node now contains two Critical Website Access watcher nodes.
5. Double-click the Computer Role object type tile.
6. Click the Object tile at the top of the object list to sort the computer roles by object name.
7. Locate the server name hosting the DNS services in the Object column. Move the cursor slowly over the server names (hover) to view a floating tip describing each object. Do so until you locate the DNS services object and select it.
8. Right-click and then select Add To -> […] Internet Explorer Network Services. Observe the DNS Services component now contains the DNS service object of the selected server.
9. Click the Save icon, or select File -> Save.
10. Exit the Distributed Application Designer (File -> Close). After several minutes, you can view the health status of the new DA in the following views:
•	Monitoring -> Distributed Applications
•	Monitoring -> Microsoft Windows Client -> Enterprise Health Monitoring -> Internet Explorer Services State
Access to the DA object itself remains at the **Authoring** -> Distributed Applications node. You can return to that node at any time to modify the components, objects, relationships, and other settings in the DA.

## Creating the OLE DB Data Source
Follow these steps to define the OLE DB data source:
1. Navigate to Authoring -> Management Pack Templates and start the Add Monitoring Wizard.
2. Select OLE DB Data Source as the monitoring type and click Next.
3. On the OLE DB Data Source Name and Description page, enter a name of the data source. For example Database SQL Connectivity. Select the Sample management pack and click Next.
4. Click Build on the Connection String page.
5. Select the appropriate Provider in the drop-down list, in this example Microsoft OLE DB Provider for SQL Server.
6. Enter the server’s name in the IP address or device name box (LON-SV1) and the database name in the Database box (OperationsManager). Click OK to leave the Build Connection String.
7. Click the Test button on the Connection screen. The test is performed from the management server and does not necessarily validate the data source is reachable from the watcher node you will select in step 9. After a moment, you should see a green check mark icon and the notice Request processed successfully.
8. On the query performance page take the defaults and click Next.
9. On the Choose Watcher Nodes page, select one or more managed computers to act as watcher nodes, ideally from several different locations. 
The default interval to run the OLE DB data source query is every 2 minutes. Adjust the query interval as appropriate and click Next.
10. Click Create and wait several moments. You should then be able to locate the new OLE DB data source monitor(s) in the Monitoring -> Synthetic Transaction -> OLE DB Data Source State view folder. There will be one monitor for each watcher node.
