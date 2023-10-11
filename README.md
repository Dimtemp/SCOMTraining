# System Center Operations Manager Training

Exercises and scripts for delivering a System Center Operations Manager (SCOM) training


## Virtual Machines
|VM|OS|Description|
|---|---|---|
|LON-DC1|Windows 2016|domain controller for the adatum.msft domain|
|LON-SV1|Windows 2019|designated Operations Manager management server|
|LON-SV2|Windows 2016|member server|
|LON-W10|Windows 10|dedicated to client monitoring|

## Credentials
|Account name|Password|Remarks|
|---|---|---|
|Local administrator|P@ssw0rd|This is the default local administrator account on the Windows VMs. Hardly used during this course.|
|ADATUM\Administrator|Pa55w.rd|This is the default Domain Admin. Rarely used during the course.|
|ADATUM\Admin|Pa55w.rd|This is also a Domain Admin account. This is the preferred account to use during the course.|
|ADATUM\MSAA|Pa55w.rd|Management Server Action Account: This account is used by the management server to perform actions on monitored computers. It is recommended to use a domain account for this purpose, especially if you have a distributed environment with multiple management servers.|
|ADATUM\SDK|Pa55w.rd|The SDK account is used by the Operations Console, as well as any other application that uses the SDK, to connect to the management server. This account should have permissions to access both the Operations Manager database and the OperationsManagerDW database.
|ADATUM\DRA|Pa55w.rd|Data Reader Account: This account has read access to the Operations Manager database. It is used by the management server to read data from the database.|
|ADATUM\DWA|Pa55w.rd|Data Writer Account: This account has write access to the Operations Manager database. The management server uses this account to write data into the database.|
