# If time permits: Creating Custom Resolution States
Operations Manager 2012 ships with two defined resolution states: New and Closed. With the release of Service Pack 1 for Operations Manager 2012, several resolution states have been added, which include: Acknowledged (249), Assigned to Engineering (248), Awaiting Evidence (247), Resolved (254), Scheduled (250).
You can define your own custom resolution states to provide additional granularity. Here is the process to create a custom resolution state:
1. Open the Operations console and navigate to the Administration pane.
2. Select Settings. Double-click Alerts to open the Global Management Group Settings - Alerts page.
3. Click New. The Edit Alert Resolution State page appears. Type a name for the new resolution state and select a unique ID for it. (The ID affects where it appears in the context menu. The number 1 appears at the top, whereas 255 is at the bottom.) For this example, call the resolution state Assigned to Next Scheduled Maintenance and give it an ID of 240.
4. Click OK and OK again to finish creating the new alert resolution state.
5. To use the new state, navigate to the Active Alerts view in the Monitoring space, right-click an alert, and select Set Resolution State. The Support resolution state is now available.
