# Creating an OLE DB Synthetic Transaction
The OLE DB monitor can monitor many different database products. Here are the steps for creating an OLE DB synthetic transaction:
1. Open the Operations console and navigate to the **Authoring** space.
1. Right-click **Management Pack Templates** and select Add Monitoring Wizard. 
1. Select OLE DB Data Source and click Next.
1. On the next page, input the name and a description for the synthetic transaction and select the management pack in which you want to create the transaction rules. For this example, the transaction name will be **Operations Manager Database Monitor**, and select the **Sample** management pack created previously. Click Next to continue.
1. On the Connection String page, click on Build.
1. Select the appropriate Provider in the drop-down list. Because the OperationsManager database is a Microsoft SQL database data source, select **Microsoft OLE DB Provider for SQL Server**.
1. Enter the database server’s name in the IP address or device name box and the database name in the Database box. For this example enter the name of the Operations Manager database server and instance (**LON-SV1**) and the name of the database, **OperationsManager**.
1. On the Connection page, click **Test**. This test is performed from the management server and does not necessarily validate the OLE DB data source is reachable from the watcher node selected in the subsequent step. After a moment, you should see a green check mark icon and the notice **Request processed successfully**.
1. Click Next.
1. The query performance page provides the ability to set error and warning thresholds based upon the connection time. If a query is entered, performance thresholds can be configured for query time and fetch time. These can also be set to different values for error and warning thresholds. To determine appropriate threshold values, monitor the performance counters for a period of time. On the query performance page leave the default values, and click Next.
1. On the Choose Watcher Nodes page, select one or more managed computers to act as watcher nodes, ideally from several different locations. It is generally best to select at least two watcher nodes for each OLE DB data source. This way, when you are alerted to a problem accessing the data source, you can more easily rule out individual watcher node failure. Each instance of a watcher node monitoring an OLE DB data source creates a new object in the OLE DB Data Source State view, which becomes usable by the Distributed Application (DA). Select **LON-DC1** and **LON-SV1**.
1. The default interval to run the OLE DB data source query is every two minutes. Adjust the query interval to **1 minute** and click Next.
1. On the summary page, click **Create** and wait several moments. You might inspect the 1201 and 1210 event ids on the agent nodes.
1. In a few minutes, you should be able to locate the new OLE DB data source monitor(s) in the Monitoring -> Synthetic Transaction -> OLE DB Data Source State view folder. There will be one monitor for each watcher node.


## Viewing the OLE DB Transaction Performance Data
After creating the OLE DB data source monitor and allowing sufficient time to pass to enable data to populate the reports, you can review the performance data related to the OLE DB data source monitor. Follow these steps:
1. Navigate to the Monitoring space and expand the Synthetic Transaction folder in the navigation tree to open the OLE DB Data Source State view. Notice the OLE DB data source monitor displayed on the right-hand side. To pivot to the performance view, right-click the object and select Open -> Performance View.
1. See the performance view for the OLE DB data source. The available performance counters are Connection Time, Execution Time, and Fetch Time. Select one or both of these counters and view the graph. If additional watcher nodes are configured, these appear as separate counters, so you can compare the open time and connection time from different watcher nodes.
