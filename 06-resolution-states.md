# Creating Custom Resolution States
Operations Manager ships with several defined resolution states: New, Closed, Acknowledged (249), Assigned to Engineering (248), Awaiting Evidence (247), Resolved (254), Scheduled (250).

You can define your own custom resolution states to provide additional granularity. Here is the process to create a custom resolution state:
1. Open the Operations console and navigate to the **Administration** pane.
1. Select Settings. Double-click Alerts to open the Global Management Group Settings - Alerts page.
1. Click New.
1. The Edit Alert Resolution State page appears. Type a name for the new resolution state and select a unique ID for it. (The ID affects where it appears in the context menu. The number 1 appears at the top, whereas 255 is at the bottom.) For this example, call the resolution state **Assigned to Next Scheduled Maintenance** and give it an ID of **240**.
1. Click OK and OK again to finish creating the new alert resolution state.
1. To use the new state, navigate to the Active Alerts view in the Monitoring space
1. Right-click an alert, and select Set Resolution State.
1. The **Assigned to Next Scheduled Maintenance** resolution state is now selectable.
