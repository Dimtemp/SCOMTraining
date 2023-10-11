# Maintenance Mode
As an example of how to apply maintenance mode to an object, the following procedure shows how to put the C: drive of the LON-DC1 computer in maintenance mode for 30 minutes to carry out some essential maintenance.

The easiest way to put a component into maintenance mode is to use the Diagram view of the monitored computer to locate the component.

Perform these steps:
1. Navigate to Monitoring -> Windows Computers and right-click the LON-DC1 computer. From the menu, select Open -> Diagram View.
1. Expand the subfolders in the Diagram View. Now right-click the C: drive object and from the context menu, select Maintenance Mode -> Start Maintenance Mode.
1. Check the Planned box on the right and the Selected objects only radio button. Now, select a category for planned maintenance. Select the Hardware: Maintenance (Planned) category from the drop-down list. Click OK, and add a comment if you like.
1. Set the number of minutes to 30 and click OK.
1. If you refresh the view, you will see that the object now has a **wrench** icon to indicate it is in maintenance mode.
1. You can edit maintenance mode and remove a managed computer or object from maintenance mode using the same context menu used in step 1.
