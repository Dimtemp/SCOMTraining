# Chapter: Monitoring with Operations Manager

## Requirements
For this exercise to succeed, you need to have the SQL Management Pack imported. This has been covered in exercise 03.

## Creating a Performance Collection Rule
As Windows Performance collection rules are most often used, this section discusses the steps required to gather a performance counter not collected by OpsMgr by default. For this example, you will be collecting the **% Processor Time** counter for the **SQL Server database engine process (sqlservr.exe)**.
1. In the Operations console, open the Authoring workspace.
1. Right-click **Rules** and select **Create New Rule**.
1. Select **Collection Rules -> Performance Based -> Windows Performance** as the rule type.
1. Select the **Sample** Management Pack you previously created as a target for the rule.
1. Click Next to continue.
1. Give the rule this name: **SQL Server process CPU Time**.
1. Under rule target, click **Select**.
1. Click **View all targets**.
1. Target the most specific existing class for this example, which is the **MSSQL on Windows: DB Enginge**
1. Click Next.
1. Use the **Select** button to open the **Select Performance Counter** window.
1. Object: **Process** (not processor).
1. Select counter from the list: **% Processor Time** 
1. Select instance from list: **sqlservr** process (if this instance does not appear, choose any other and type sqlservr in the Instance variable after selecting OK).
1. At the Performance Object, Counter, and Instance page, change the collection interval to **1 minute**.
1. **Note.** This is not a best-practice, but in class we don't want to wait too long for output.
1. Click Next to continue to the final page of the wizard.
1. The last page of the wizard allows you to configure optimized collections. Optimized collection reduces the amount of disk space a performance counter collection uses in the data warehouse. Leave it unselected.
1. Click Create to create the performance collection rule.
1. Confirm that the changed management pack is downloaded by the agent (verify the 1201 and 1210 events in the event log on the client computer).


## Viewing the results of a collection rule
1. Open the **My Workspace** pane. Right click **Favorite Views** and select **New -> Performance View**.
1. Enter the following name: **SQL Server process performance**.
1. Under Select conditions, click **collected by specific rules**.
1. Under criteria descritpion, click the blue **specific** hyperlink.
1. In the list that appears, select the rule with the name you specified previously: **SQL Server process CPU Time**.
1. Click Ok to close the wizard.
1. The new view should contain the performance counter. Select it to display a graph.
1. It might take several minutes for data to arrive.
