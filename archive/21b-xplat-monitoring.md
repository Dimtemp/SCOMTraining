## Finding Monitoring Data in the Console
Operations Manager includes many views for exploring the state, performance, and alerts related to UNIX and Linux computers. Views are organized at the top level into separate UNIX and Linux folders. The subfolders present platform-specific folders for different UNIX and Linux distributions, such as AIX, Solaris, Red Hat, and SUSE.

## UNIX/Linux Log File Template
The Log File template does exactly as its name suggests and enables you to configure monitoring a log file hosted on a UNIX/Linux system. As with other management pack templates, creating a new log file monitor is simple and wizard-based. Choosing to create a new log file monitor presents the standard rule/monitor creation dialogs where you provide the log file monitor a name and select a management pack in which to store it. 

Follow these steps:
1. Navigate to the **Authoring** pane in the SCOM console, select Management Pack Templates and start the UNIX/Linux Log File Monitoring Wizard.
2. Enter a friendly name in the textbox provided and using the drop-down, select a management pack in which to save your custom monitor, then click Next. The authors suggest using a dedicated management pack for the output of the UNIX and Linux monitoring templates.
3. This opens a dialog where you will configure the log file monitor as follows:
  ▶ Monitoring target: Select either a specific UNIX/Linux computer or computer group to target the monitor.
  ▶ Log file monitoring settings: Manually enter the name and location of the log file to monitor. The format of this log file path will depend on the version of UNIX/Linux you are targeting but will be similar to the /tmp/logfile format.
  ▶ Expression: Configure the expression (in regular expression format) to monitor for in the log file. The Expression Test section lets you test the regular expression you just created against a sample line of text you input, which replicates what is found in the log file.
  ▶ Run As profile: If necessary, change the Run As profile from the default configuration. This may be required if the log file being monitored requires elevated privileges to access and sudo has not been enabled on the unprivileged account.
  ▶ Alert severity: Configure the desired alert severity. Error is the default.
4. Click the Test button to test your regular expression syntax versus a line from the target log file targeted for monitoring. When you have tested successfully, click OK.
5. Change the Run As profile and Alert severity defaults if necessary, then click Next.
6. On the UNIX/Linux Log File Summary page, click Create.

## UNIX/Linux Process Template
The UNIX/Linux Process template also ships as part of OpsMgr 2012. This template works similarly to the Windows Service monitoring template, enabling you to monitor the availability of a specific service (sometimes referred to as a process) running on a UNIX/Linux server. 

Follow these steps:
1. After choosing to create the new template and assigning it a name and destination management pack, proceed to the process details dialog. From this page, click Select a process to select a source server for the process. This server does not necessarily have to be the server you ultimately monitor but must be actively running the process.
2. After highlighting the appropriate server and clicking Select, the wizard immediately begins to enumerate the processes, making it easier to select the appropriate process for monitoring. From this list, scroll down to select the X process (which represents the graphical user interface, or GUI, on the host) and click Select.
3. Click Next to monitor the service for only the single server selected, or select the Select a group check box and select a computer group to target the monitor.
4. Check the Generate an alert check box for minimum or maximum number of service instances that should be running. To simply check that a service is running, also select the option to Generate an alert when the minimum number of process instances is less than the specified value and set the value to 1.
5. To complete the wizard, click Next and then Create. Once the monitor is created, it appears in the Health Explorer under Availability -> Application/Service Availability Rollup. If the service stops, the monitor displays an unhealthy state.
6. To test your configuration, you can stop the GUI for a short time to verify the configuration works as expected. It is simple to stop the GUI until the monitor transitions to an error state and generates an alert. Here’s how to start and stop the GUI:
7. To stop the GUI, from a terminal session, type
  /sbin/init 3
8. To restart the GUI from the command line interface, log in if prompted and type
  /sbin/init 5

## Creating a UNIX/Linux Shell Command Two State Monitor (DNS)
Use the nslookup command to check name resolution health from the DNS server (specifying the local host as the server in the second argument). An example is nslookup linux.adatum.com 127.0.0.1. Here is what the actual output of this command looks like:
  lx11:/var/lib/named # nslookup linux.adatum.com 127.0.0.1
  Server: 127.0.0.1
  Address: 127.0.0.1#53
  Name: linux.datum.com
  Address:192.168.1.76

To make this command easier to read on your monitor (and this page), you can do a bit of pipeline parsing:
nslookup linux.adatum.com 127.0.0.1|egrep "^Name:.*linux.adatum.com"|wc -l

This shell command returns a value of 1 if the line: Name: linux.adatum.com is found in StdOut and a value of 0 otherwise. Therefore, a value of 1 means the name resolution attempt succeeded, and a value of 0 means it failed. Here are the steps to create a monitor using this command:
1. In the Operations console, navigate to **Authoring** -> Management Pack Objects and right-click Monitors. Select Create a Monitor -> Unit Monitor.
2. Expand Scripting -> Generic, select UNIX/Linux Shell Command Two State Monitor, and select the Sample management pack. Click Next
3. Input a name, description, and target ( UNIX/Linux Computer ) for the monitor. Select a Parent monitor ( Availability ) and uncheck Monitor is enabled. Click Next.
4. Configure a schedule interval. For performance optimization, this should be as large of a value as reasonable; 10 or 15 minutes should be sufficient for most purposes. Click Next.
5. Input the shell command (replacing linux.adatum.com with the hostname to resolve):
  nslookup linux.adatum.com 127.0.0.1|egrep '^Name:.*linux.adatum.com'|wc –l
6. The UNIX/Linux Privileged Account Run As profile is appropriate for this command, and 120 is a sufficient value for the Timeout (seconds). 7. Click Next
8. The next page of the wizard is for configuring the Monitor Error Expression. If the conditions defined in this expression are matched, the monitor goes to an error state. The Expression Filter dialog is preloaded with the following values:
  //*[local-name()="StdOut" Contains <input value>
  //*[local-name()="ReturnCode"] Equals 0
9. With the shell command used in this example, the error state should be triggered when StdOut does not equal 1, so the first line can be modified to that effect. This results in an error condition triggered when StdOut does not equal 1 and the nslookup command executed successfully (ReturnCode equals 0).
10. After clicking Next, the Healthy Expression dialog is displayed. As a StdOut value of 1 indicates a successful nslookup operation using the provided shell command, simply set the first line to: //*[local-name()="StdOut"] Equals 1 and click Next.
11. In the Configure Health dialog, you can choose whether you want the error state to map to a Critical or Warning event by changing the Health State drop-down. This example sets the Health State to Warning.
12. The next dialog is for alert configuration. Check Generate alerts for this monitor and select an appropriate Priority and Severity (match monitors’ health). Edit the Alert name if appropriate and provide an Alert description. Standard $Target$ variables can be embedded in the Alert description by clicking [...]. Here is the syntax to include data from the shell command execution:
  StdOut: $Data/Context///*[local-name()="StdOut"]$
  StdErr: $Data/Context///*[local-name()="StdErr"]$
  ReturnCode: $Data/Context///*[local-name()="ReturnCode"]$
  This example uses the following description:
  The BIND DNS server: $Tar-get/Property
  [Type="MicrosoftUnixLibrary7320040!Microsoft.Unix.Computer"]
  /NetworkName$ failed a name resolution test. StdErr
13. Click Create to complete the monitor creation.
14. As this monitor targets all UNIX and Linux computers, it was created without being enabled by default. Use an override to enable it for the group of BIND servers. Navigate to **Authoring** -> Management Pack Objects, Monitors. Click Change Scope, and check Linux Computers. Find the monitor just created (BIND Name Resolution Check).
15. Right-click the monitor, click Overrides -> Override the Monitor -> For a Group. Select the Linux BIND servers group created previously and click OK.
16. Override the Enabled property to equal True and click OK. 

## UNIX/Linux Shell Command Performance Collection Rule
This example creates a DNS name resolution time performance collection rule using the new UNIX/Linux Shell Command Performance Collection Rule in Operations Manager. Perform the following steps:
1. In the **Authoring** pane of the console, right-click Rules, and select Create a new rule.
2. Under Collection Rules -> Probe Based, select UNIX/Linux Shell Command (Performance) and select the Sample management pack. Click Next.
3. Input the Name and Description for the rule. Select the Rule target ( UNIX/Linux Computer ) and uncheck Rule is enabled. Click Next.
4. Configure a schedule interval. For performance optimization, this should be as large a value as reasonable; 10 or 15 minutes should be sufficient for most purposes. Click Next to continue.
5. On the Shell Command Details page, input the shell command /usr/bin/time –f %e nslookup linux.adatum.com 127.0.0.1 > /dev/null. This command will return the time in seconds (to StdErr) it takes to complete the name resolution lookup. This is a non-privileged operation, so the UNIX/Linux Action Account is sufficient for the Run As profile. Click Next.
6. The next page provides the opportunity to filter the output before mapping to performance data. Performance data mapping can only occur if the value is a valid double value, so the default expression syntax uses a RegExp to validate StdOut is a numeric value, and also filters that ReturnCode = 0, indicating a successful execution.
7. While the default configuration is valid for most scenarios, the time command used in this shell command actually outputs its value to StdErr. So in this case, the first line of the filter should be modified to use a Parameter Name of //*[localname()="StdErr"]. Click Next.
8. Configure the performance mapping information. Object, Counter, and Instance are arbitrary values used to identify the performance metric in performance views and reports. The default value of $Data///*[localname()=“StdOut”]$ is the variable syntax for the returned StdOut, which is appropriate for most cases. This needs to be modified here because the time command used in this example outputs to StdErr. The StdErr variable is $Data///*[localname()='StdErr']$. Click Create.
9. As this rule targets all UNIX and Linux computers, it was created without being enabled by default. Use an override to enable it for the group of BIND servers. Navigate to **Authoring** -> Management Pack Objects -> Rules. In the top-right of the Rules pane, click Change Scope, and check UNIX/Linux Computer from the Scope Management Pack Objects dialog. Find the rule just created (BIND Name Resolution Test Time in Seconds) in the UNIX/Linux Shell Command Performance Collection Rule created in this procedure.
10. To enable the rule, right-click the rule, click Overrides -> Override the Monitor -> For a Group. Select a group containing the BIND servers (which must have been created previously) and click OK.
11. Override the Enabled property to equal True and click OK.

## Creating a UNIX/Linux Shell Command (BIND Restart Task)
The Run a UNIX/Linux Shell Command task wizard is the simplest of the shell command templates, and relatively easy even for those OpsMgr administrators new to UNIX/Linux shell scripting. These steps result in a task that restarts the BIND daemon on a Linux computer from the Operations console. 

Follow these steps:
1. Navigate to **Authoring** -> Management Pack Objects and right-click Tasks. Select Create a New Task.
2. Select Run a UNIX/Linux Shell Command from the Agent Tasks list, and select the Sample management pack. Click Next.
3. Input this name for the task: Restart BIND Daemon, and select the target Linux Computer. Click Next.
4. The command to restart the BIND daemon is service named restart. Type this into the shell command entry pane. Restarting a daemon is a privileged operation, so select the UNIX/Linux Privileged Account Run As profile. The default timeout of 120 seconds should be sufficient, so click Create.
