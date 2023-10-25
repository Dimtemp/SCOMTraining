# Web Application Transaction Monitoring (Synthetic Transactions)

This section looks at the process to monitor a web application using the Web Application Transaction Monitoring template. Configuring a web application synthetic transaction is quite straightforward; a wizard allows you to configure basic monitoring, and OpsMgr includes a Web Application Designer that allows you to configure advanced settings such as login information for the website. The designer also makes it easy to configure the website for monitoring, providing a web recorder you can use to record the synthetic transaction you will create using Internet Explorer. 

**Note!** It appears that Microsoft is not supporting the web recorder plug in after 2012. The web recorder plug-in works in Internet Explorer 32-bit and 64-bit. More info: https://learn.microsoft.com/en-us/answers/questions/965899/web-application-transaction-monitoring

Follow these steps to create a web application synthetic transaction:
1. Start a PowerShell console and run this command: ```Add-WindowsFeature Web-WebServer, Web-Mgmt-Console```
2. Launch the Operations console and navigate to the **Authoring** space.
3. Right-click **Management Pack Templates** and select **Add Monitoring Wizard**. From this page, select Web Application Transaction Monitoring as the monitoring type, and then click Next.
4. On the following page, input the name and a description for the synthetic transaction, and select the management pack in which to create the transaction rules. For this example call the transaction **Website** and select the **Sample** management pack used elsewhere, or another one you have already created. Click Next to continue.
5. The next page is the Enter and Test Web Address page. Enter the basic URL you wish to monitor. For this example enter localhost (although, as you will see later in this process, the information you enter here is irrelevant as you can change it using the Web Application Editor in the "Configuring Advanced Monitoring for a Website" section). After entering the URL, click the Test button to validate you can contact that URL. Click Next.
6. The next page configures the watcher nodes, where you will identify and configure the computer initiating the test. The page lists all machines running OpsMgr Windows agents, management servers, and gateways; tick the check boxes to carry out the test on the machines you choose. For this example, run the test from **LON-SV1** and configure the test to run **each minute**. Click Next to continue.
7. The final page displays a summary of the information you have specified throughout the wizard. The page also allows you to Configure Advanced Monitoring or Record a browser session. If you do not check this option, the wizard completes and the web application synthetic transaction is saved to the previously specified management pack. For this example, the next step is to configure more advanced monitoring of the website, so check the **Configure Advanced Monitoring or Record a browser session** check box at the bottom of the page.

## Configuring Advanced Monitoring for a Website
After using the Add Monitoring Wizard, you can configure advanced monitoring of a website or web application.

Follow these steps:
1. When you click Create in the Add Monitoring Wizard with the **Configure Advanced Monitoring** option checked, the Web Application Editor opens.
1. The next step is to configure the performance counters for this web application monitor.
1. Click the **Configure Settings** link, which opens the Web Application Properties page, and open the **Performance Counter** tab.
1. From this tab, you can configure a number of options that affect the entire web application, including performance counters to collect, and any logon information required to access the website (logon information is specified using Run As accounts). You can also add or remove watcher nodes from this page. Using the Performance Criteria tab, you can also configure additional alerts to generate when the total response time for the entire website takes longer than an amount of time you specify.
1. For this example, four additional performance counters will be added that are not collected by default. On the Performance Counter tab, check the check box next to the following counters:
  - Total: DNS Resolution Time
  - Total: Time To First Byte
  - Total: Time To Last Byte
  - Total: Total Response Time
1. Click OK to save the options.
1. This example configured performance counters for an entire web application. Note that a large number of the options configured globally are also available to each individual website. You can also configure extra options such as custom conditions for generating alerts. 
1. The last configuration required will limit the number of alerts generated in the event of a failure. Although this option is not required, it is recommended to use this functionality to prevent an alert storm. To prevent the transactions continuing to process when the previous transaction fails (and limit the number of alerts generated), select all web addresses in the editor, and select the **Stop processing the subsequent requests if any error criteria is met** check box.
1. Click **Verify** to verify the settings you have applied. This button is grayed out but becomes available after changes are made to the synthetic transaction.
1. Finally, click the Apply button to save the settings. This creates all of the monitoring components automatically (this button is grayed out until you verify your criteria). You can then close the editor.


## Viewing the Website Performance Data
Now that there is a web application to monitor a local website, the performance counters specified for collection can be reviewed. 

To view the performance counters, perform the following steps:
1. In the Operations console, navigate to Monitoring -> Web Application Transaction Monitoring, and click the **Web Application State** view. The right-hand pane will show the web application monitor created in the previous section. Pivot to the performance view by right-clicking the object, then selecting Open -> Performance View.
1. You now see the performance view for the web application and can notice the available performance counters are the ones selected in the previous section. 
1. To demonstrate the performance graph, select several counters added to the web application. You can also display these performance counters by creating a dashboard view and adding the performance widget or the objects by performance widget.
