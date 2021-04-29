# Chapter: Monitoring with Operations Manager 

## Creating a Performance Collection Rule
As Windows Performance collection rules are most often used, this section discusses the steps required to gather a performance counter not collected by OpsMgr by default. For this example, you will be collecting the **% Processor Time** counter for the **IIS worker process (w3wp.exe)**.
1. In the Operations console, open the Authoring workspace.
1. Right-click **Rules** and select **Create New Rule**.
4. Select **Collection Rules -> Performance Based -> Windows Performance** as the rule type.
5. Select the **Sample** Management Pack you previously created as a target for the rule.
6. Click Next to continue.
7. Give the rule this name: **IIS worker process CPU Time**.
8. Target the most specific existing class for this example, which is the IIS Server Role class (don’t forget to select the option “view all targets”).
9. Since the rule is targeted to the most specific existing class, it can be enabled so it runs on all IIS servers.
1. Use the Select-button to select the **Process -> % Processor Time counter** for the w3wp process (select instance from list).
> NOTE: If the w3wp does not appear in the list, start a webbrowser and visit http://localhost. The w3wp process should appear in the list.
1. At the Performance Object, Counter, and Instance page, change the collection interval to **1 minute**.
1. Click Next to continue to the final page of the wizard.
1. The last page of the wizard allows you to configure optimized collections. Optimized collection reduces the amount of disk space a performance counter collection uses in the data warehouse.
1. Click Create to create the performance collection rule.
1. Confirm that the changed management pack is downloaded by the agent (previous exercise).

## Viewing the results of a collection rule
1. Open the **My Workspace** pane. Right click **Favorite Views** and select **New -> Performance View**.
1. Enter the following name: **IIS worker process performance**.
1. Under Show data related to, click the … button and specify **IIS Server Role**.
1. Select the checkbox next to **with a specific instance name** and enter the process name: **w3wp**.
1. Click Ok. The view should contain the performance counter. Select it to display a graph.  
