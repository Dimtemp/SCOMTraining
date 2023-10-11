# Chapter: Monitoring with Operations Manager 

## Basic Service Monitor
As monitoring services is common, the next procedure creates a Windows service monitor to monitor the Print Spooler service. Follow these steps:
1. In the Operations console, navigate to **Authoring -> Management Pack Objects**.
2. Right-click Monitors and select **Create a Monitor -> Unit Monitor**.
3. Select **Windows Services -> Basic Service Monitor**. Select the **Sample** Management Pack as a target for the monitor. Click Next to continue.
4. On the next page, name the monitor and configure a target for it. Name this monitor **Print Spooler Service Monitor** and target the **Windows Server Operating System** class, as this should apply to all Windows servers. Notice here, unlike when you created rules, you are asked to specify the parent monitor. In this case, leave the setting at the default of Availability. Uncheck the checkbox next to **Monitor is enabled** to **disable the monitor**. It will be enabled using an override. Click Next to continue.
5. Now, configure the service you want to monitor. In this case, it is the Print Spooler (Spooler) service. You can click the ... button to browse for the service or type **Spooler** into the service name box. Click Next.
6. The next page of the wizard is the Configure Health page. This is where you define what the health of the monitor will be in relation to the state of the service. Because this is a basic service monitor, it is already correctly defined.
7. The final page of the wizard configures the actual alert OpsMgr will generate. Check the **Generate alerts for this monitor** check box, leave the alert name as it is, and add an alert description. Also, leave the check box enabled for **Automatically resolve alert**. This means that once the monitor returns to a Healthy state, any generated alerts are automatically resolved. Click Create to create the new service monitor.
Confirm that the changed management pack is downloaded by the agent. The procedure is explained in a previous exercise.
