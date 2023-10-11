# Web Application Availability Monitoring

In addition to the Web Application Transaction Monitoring template, Operations Manager provides a Web Application Availability Monitoring template. Here are the major differences between these two templates:
  - Web Application Availability Monitoring: You can add individual websites or paste in a large number of URLs from a CSV file. Additionally, you can specify either agents or a resource pool as a watcher node. This template does not include some of the advanced capabilities available in the Web Application Transaction Monitoring template such as recording a series of web pages. With the Global Service Monitoring (GSM) functionality, web applications availability monitoring can perform synthetic tests for your websites from Microsoft Azure cloud locations around the world. You can display the results in a dashboard map. Availability monitoring is best used to provide insights into how well a website is performing across a set of testing locations that are geographically dispersed. This is the best choice when determining if a website is available.
  - Web Application Transaction Monitoring: You can record web transactions and perform advanced configurations with the Web Application Availability Monitoring template. Transaction monitoring is best used to test internal website functionality and validate the website is functioning as expected. This is the best monitoring option when opening the website is insufficient as a test.

To create a web application availability monitor, perform the following steps:
1. Start a PowerShell console and run this command: ```Add-WindowsFeature Web-WebServer, Web-Mgmt-Console``` (This step might have been executed in a previous exercise. The Exit Code will display NoChangeNeeded if this is the case.)
1. Launch the Operations console and navigate to the **Authoring** space.
1. Right-click the Management Pack Templates and select the Add Monitoring Wizard.
1. Select **Web Application Availability Monitoring** as the monitoring type, and click Next.
1. On the following page, input the name and a description for the synthetic transaction, and select the management pack in which to create the transaction rules. For this example call the transaction Bing and select the Sample management pack used previously. Click Next to continue.
1. The next page is used to add URLs to monitor with this synthetic transaction. You can add bulk URLs by importing a CSV file in the format of Name, URL (include http:// or https:// as part of the URL). For this example, add a single URL named Bing with a URL value of http://localhost. Click Next.
1. The next page configures which resource pools or agents will function as watcher nodes for this synthetic transaction. A resource pool and agents can both be configured as watcher nodes. Add **LON-SV1** and click Next to continue.
1. The next page provides an option to run a test or change the configuration for the tests. Click **Change Configuration**.
1. The default configuration is to run each of the tests on a frequency of every 10 minutes. 
1. Observe the other values and click OK.
1. The **Run Test** button executes the synthetic transaction from the agent or resource pool that was highlighted. Results of the test are shown and can show data including the HTTP response and the raw data from the synthetic transaction.
1. The final page displays a summary of the information you have specified throughout the wizard. Click **Create** to finish this wizard and create the synthetic transaction.


## Viewing the Website Data
To view the output, perform the following steps:
1. In the Operations console, navigate to Monitoring -> Application Monitoring -> Web Application Availability Monitoring
1. Click the **Test State** view and observe the output.
1. Click the **Web Application Status** view and observe the output.
