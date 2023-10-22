## Copy source files
1. On the host, click Start and click Windows PowerShell ISE.
1. Click View, click Show Script pane.
1. Run these commands:
```PowerShell
Get-VM|Enable-VMIntegrationService -Name 'Guest Service Interface'
dir C:\Hyper-V\ *.msi -Recurse | foreach { Copy-VMFile -name LON-SV1 -SourcePath $_.FullName -DestinationPath C:\ -FileSource Host }
```


## Install prerequisites
1. Run Windows Explorer.
1. Navigate to C:\
1. Run this file: **SQLSysClrTypes.msi**.
1. Follow the wizard to install the SQL System CRL Types.
1. Run this file: **ReportViewer.msi**.
1. Doubleclick the file and follow the wizard to install the SQL System CRL Types.


## Update SQL Server Service password
1. If you were required to change your password in a previous step, the SQL Server Service password needs to be updated. Only perform this procedure if you indeed changed the password.
1. Open Server Manager.
1. Click Tools, Services.
1. In Services, scroll down to SQL Server.
1. Open the SQL Server properties.
1. Click the Log On tab and enter the updated password. Click OK.
1. Restart the SQL Server service.
