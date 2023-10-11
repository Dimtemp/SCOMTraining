# Chapter: Monitoring with Operations Manager 

## Windows Event Monitor
- One of the most basic types of monitors is the Windows Events monitor, which detects Windows events and uses these events to update its status.
- These monitors can vary in complexity from simple, single-event detection to a complex correlation of events; even missing events can contribute to the status of a Windows Events monitor.

Follow these steps:
1. Open the Operations console and navigate to **Authoring -> Management Pack Objects**.
1. To create a new monitor, right-click **Monitors** in the left pane, then select **Create a monitor**.
1. Select **Unit Monitor** to open the Select a Monitor Type page.
1. This monitor will be configured to fail based on a Windows event and return to a normal state based on a different Windows event. Select **Windows Events -> Simple Event Detection -> Windows Event Reset**.
1. You must also specify the management pack to which you want to add the monitor. As with other examples in this chapter, use the **Sample** Management Pack and click Next.
1. Enter a name for the new monitor. This monitor will be called **Server Time out of Sync**.
1. Set the target for the monitor to **Windows Server Operating System**.
1. Set the parent monitor (the monitor under which this one will reside) to **Configuration**.
1. **Uncheck** the **Monitor is Enabled** option: it will be enabled later using an override.
1. Click Next.
1. Select the **System** log. Click Next.
1. The Build Event Expression page is where you specify the parameters of the event that enables OpsMgr to accurately detect and update the state to unhealthy when the event appears in the System log. By default, the wizard adds the Event ID and Event Source parameters. In this example, the rule will look for an event with an event ID of **50** and a source of **W32Time**. This event indicates time synchronization is not working. Once you have specified the event information for the unhealthy event, click next and repeat the process. This will define the event that causes the monitor to return to a healthy state.
1. Use an event from the **System** log with an Event ID of **37** and a source of **W32Time**. Event 37 indicates that time synchronization is now working correctly.
1. After you complete these steps click Next.
1. The Configure Health page displays. Here, you can also specify the severity of the different states of the monitor. For this example, leave both of these configurations in their default states for warning and healthy. Click Next.
1. In the final page of the wizard, you can specify if the monitor will generate an alert. Choose the option: **Generate alerts for this monitor**. Once you check the Generate alerts for this monitor check box, a number of options appear:
    - You can configure the level the monitor must be at before an alert is generated (Warning or Critical). In this case, change the setting to Warning as the health state was defined to be Warning or Healthy.
    - Use the check box below this option to specify whether OpsMgr will Automatically resolve the alert when the monitor returns to a healthy state. You will want to do this in most cases—by enabling monitors to resolve their own alerts, you minimize the number of excess alerts residing in the console at any one time.
    - Configure the details of the alert in the bottom section of the page; this defines what appears when it is generated. The information includes the name of the alert, any descriptive information, and the priority and the severity of the alert.
1. When satisfied with the alert details and other settings in the wizard, click Create. 

> Confirm that the changed management pack is downloaded by the agent (event id's 1201 and 1210). The procedure is explained in a previous exercise.
 