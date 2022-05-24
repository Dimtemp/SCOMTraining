# Creating a Web Application Synthetic Transaction

This section looks at the process to monitor a web application using the Web Application Transaction Monitoring template. Configuring a web application synthetic transaction is quite straightforward; a wizard allows you to configure basic monitoring, and OpsMgr includes a Web Application Designer that allows you to configure advanced settings such as login information for the website. The designer also makes it easy to configure the website for monitoring, providing a web recorder you can use to record the synthetic transaction you will create using Internet Explorer. 

Follow these steps to create a web application synthetic transaction:
1. Launch the Operations console and navigate to the Authoring space.
2. Right-click the Management Pack Templates sub tree and select Add Monitoring Wizard. From this page, select Web Application Transaction Monitoring as the monitoring type, and then click Next.
3. On the following page, input the name and a description for the synthetic transaction, and select the management pack in which to create the transaction rules. For this example call the transaction Bing and select the Sample management pack used elsewhere, or another one you have already created. Click Next to continue.
4. The next page is the Enter and Test Web Address page. Enter the basic URL you wish to monitor. For this example enter www.bing.com (although, as you will see later in this process, the information you enter here is irrelevant as you can change it using the Web Application Editor in the “Configuring Advanced Monitoring for a Website” section). After entering the URL, click the Test button to validate you can contact that URL. Click Next.
5. The next page configures the watcher nodes, where you will identify and configure the computer initiating the test. The page lists all machines running OpsMgr Windows agents, management servers, and gateways; tick the check boxes to carry out the test on the machines you choose. For this example, run the test from LON-SV1.Adatum.com and configure the test to run each minute. Click Next to continue.
6. The final page displays a summary of the information you have specified throughout the wizard. The page also allows you to Configure Advanced Monitoring or Record a browser session. If you do not check this option, the wizard completes and the web application synthetic transaction is saved to the previously specified management pack. For this example, the next step is to configure more advanced monitoring of the website, so check the Configure Advanced Monitoring or Record a browser session check box at the bottom of the page. The next section covers the steps for advanced website monitoring.

## Configuring Advanced Monitoring for a Website
Please follow the instructions in the topic “Using the recorder with 64-bit systems” on page 883 of the book to allow the 64-bit plugin to function with Internet Explorer.
After using the Add Monitoring Wizard, you can configure advanced monitoring of a website or web application.

Follow these steps:
1. When you click Create in the Add Monitoring Wizard with the Configure Advanced Monitoring option checked, the wizard closes and the Web Application Editor opens.
2. Using the Web Application Editor, the next step is to record a web session and look at the additional options available when creating a web application synthetic transaction. Begin by deleting any web addresses present in the editor in preparation for recording a web session. Select the website configured in the wizard in the previous section and click the Delete option on the right-hand side in the Actions pane under the Web Request section. Click OK when prompted.
3. Click the Start Capture button. This opens an Internet Explorer browser window with a Web Recorder pane on the left-hand side. Approve any plugins displayed at the bottom of the screen.
4. With the editor cleared, record a web session while browsing a number of pages on Bing, entering a search term, browsing to a website, and browsing to an https (SSL) site. This process demonstrates OpsMgr’s capability to simulate various browser steps and record them. For this example, browse to Bing (www.bing.com) and perform a search. From the search results browse to a resulting wiki page and from there open an https site.
5. After you complete recording the web session, click the Stop button in the Web Recorder pane. This closes Internet Explorer, bringing you back to the editor with the web addresses displayed in the console.
6. The next step is to configure the performance counters for this web application monitor. Click the Configure Settings link, which opens the Web Application Properties page, and open the Performance Counter tab.
7. From this tab, you can configure a number of options that affect the entire web application, including performance counters to collect, and any logon information required to access the website (logon information is specified using Run As accounts). You can also add or remove watcher nodes from this page. Using the Performance Criteria tab, you can also configure additional alerts to generate when the total response time for the entire website takes longer than an amount of time you specify.
8. For this example, four additional performance counters will be added that are not collected by default. On the Performance Counter tab, check the check box next to the following counters:
  - Total: DNS Resolution Time
  - Total: Time To First Byte
  - Total: Time To Last Byte
  - Total: Total Response Time
9. Click OK to save the options and close the options page.
This example configured performance counters for an entire web application. Note that a large number of the options configured globally are also available to each individual website. You can also configure extra options such as custom conditions for generating alerts. 
10. The last configuration required will limit the number of alerts generated in the event of a failure. Although this option is not required, the authors recommend using this functionality to prevent an alert storm. To prevent the transactions continuing to process when the previous transaction fails (and limit the number of alerts generated), select all web addresses in the editor, and select the Stop processing the subsequent requests if any error criteria is met check box.
11. After selecting the Stop processing the subsequent requests if any error criteria is met option, verify the settings you have applied. Click the Verify button. This button is grayed out but becomes available after changes are made to the synthetic transaction.
12. Finally, click the Apply button to save the settings. This creates all of the monitoring components automatically (this button is grayed out until you verify your criteria). You can then close the editor.

## Viewing the Website Performance Data
Now that there is a web application to monitor Bing, the performance counters specified for collection can be reviewed. 

To view the performance counters, perform the following steps:
1. In the Operations console, navigate to Monitoring -> Web Application Transaction Monitoring, and click the Web Application State view. The right-hand pane will show the web application monitor created in the “Creating a Web Application Synthetic Transaction” section. Pivot to the performance view by right-clicking the object, then selecting Open -> Performance View.
2. You now see the performance view for the web application and can notice the available performance counters are the ones selected in the “Configuring Advanced Monitoring for a Website” section. To demonstrate the performance graph, select several counters added to the web application. You can also display these performance counters by creating a dashboard view and adding the performance widget or the objects by performance widget.

### TIP: CREATING A DASHBOARD WITH PERFORMANCE VIEW DATA   Use the performance view to identify the path, object, counter, and instance required when adding the performance widget. Creating this view ahead of time makes it easier to determine what the appropriate information is when you are configuring the performance widget.
