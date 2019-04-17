## Change the recovery model of the OpsMgr databases
Only recommended for this type of high availability!
1. Open SQL Server Management Studio and connect to the SQL Server instance hosting the OpsMgr databases, the OperationsManager database in this case.
2. In the left part of SQL Management Studio (the Object Explorer), expand the Databases node.
3. Select the OperationsManager database, right-click, and select Properties.
4. On the Database Properties page, select Options to display the options available for this database. 
5. Change the Recovery model setting to Full and click OK to save your changes. Repeat these steps for the OperationsManagerDW database.

## Configuring Log Shipping
With the recovery model reconfigured, it is time to configure log shipping.
For a detailed guide about configuring log shipping for OpsMgr, see http://social.technet.microsoft.com/wiki/contents/articles/11372.configure-sql-server-log-shipping-guide-for-thesystem-center-operations-manager-2007-r22012-operational-database.aspx.
We do not discuss log shipping in detail. However, we will highlight some potential pitfalls. Here are some things to consider when configuring log shipping:
▶ SQL Server Agent service: The SQL Server Agent service must run under a domain account and be a member of the SQLServerSQLAgentUser$<ComputerName>$<Instance> local group.
▶ Firewall considerations: The firewall must allow access to the primary and secondary SQL servers. Open the ports related to the SQL Server instance and those for file and printer sharing.
▶ Broker service: The Broker service should be enabled, as well as CLR (Common Language Runtime) integration. The article at http://msdn.microsoft.com/en-us/library/ms131048.aspx discusses enabling CLR Integration.
▶ Management server configuration: Each OpsMgr management server requires modifications as described in the wiki mentioned earlier in this section for configuring log shipping for OpsMgr. Be sure you are familiar with these changes, and know where to locate the registry keys and file requiring those modifications.
▶ Database modifications: The OperationsManager database requires a modification as well, as described in the wiki mentioned earlier in this section for configuring log shipping for OpsMgr. Ensure you know the table and which record.
