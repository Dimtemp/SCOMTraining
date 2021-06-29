# Creating a TCP Port Monitor
This section looks at the process for creating a TCP port monitor. Follow these steps to create the monitor:
1. Launch the Operations console and navigate to the Authoring space.
2. Right-click the Management Pack Templates sub tree and select Add Monitoring Wizard.
3. The different monitoring types available are displayed. From this page, select TCP Port and click Next.
4. On the General Properties page, input the name and a description for the synthetic transaction and select the management pack to which you will save the transaction rules. For this example, name the TCP Port Monitor Vancouver Router and select the Sample management pack to store this in. Click Next to continue. 
5. On the target and port page, enter the TCP name or IP address of the primary network device and the port number with which to communicate. For this example, communication is occurring with the LON-SV1 on port 80. In your own environment, you would input any server or network device’s IP address or DNS name, and the appropriate port to monitor. Click the Test button to validate the port. Click Next to continue.
6. The next page is the Choose Watcher Nodes page, where the computer initiating the test is selected and configured. The page lists all computers running OpsMgr agents, and you can tick the check boxes to carry out the test on the computers you choose. In this example, run the test from the LON-SV1 and LON-DC1 machine. Configure the test to run every minute instead of the default setting of 2 minutes. Click Next, and continue to the final page of the Add Monitoring Wizard.
7. The final page of the wizard summarizes the information you have input throughout the wizard. Click Create to complete creating the TCP Port synthetic transaction.

## Viewing the TCP Port Performance Data
Similar to the other synthetic transactions discussed in this chapter, the TCP Port monitor synthetic transaction collects performance data. View this information using the process described here:
1. Navigate to the Monitoring -> Synthetic Transaction -> TCP Port Checks State view. Displayed on the right-hand side is the TCP port monitors configured in the previous section. Right-click an object, then select Open Performance View.
2. The Performance view opens, with the only performance counter available being the Connection Time counter for the TCP port being monitored. As the example configured additional watcher nodes, these nodes appear as separate counters, allowing you to compare the connection time from different watcher nodes.
