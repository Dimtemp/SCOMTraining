# RMS
## Confirming the RMS Emulator Role
Using the PowerShell cmdlet Get-SCOMRMSEmulator, you can check which management server hosts the RMSE.
You can also check which management server hosts the RMSE role by using the Operations console. Navigate to Administration -> Device Management -> Management Servers. The middle pane shows all management servers, with the RMS Emulator column showing which management server hosts the RMSE role.

## Moving the RMS Emulator Role
When using the PowerShell cmdlet Set-SCOMRMSEmulator in conjunction with Get-SCOMRMSEmulator, you can move the RMS emulator role to another management server.
Here is an example of the syntax:
Get-SCOMManagementServer -Name "LON-SV2.Adatum.com" | Set-SCOMRMSEmulator
TIP : ALWAYS CHECK AND USE FQDNS WHEN MOVING RMSE ROLE
When the RMSE role is moved using the Get-SCOMRMSEmulator and Set-SCOMRMSEmulator PowerShell cmdlets, there is no confirmation of success. To confirm the action was successful, run the Get-SCOMRMSEmulator cmdlet again or check the Operations console as described in the “Confirming the RMS Emulator Role” section. Also, know that you must use FQDNs for the management server names when running these PowerShell cmdlets, as otherwise the cmdlets might not work.

## Removing the RMS Emulator Role
If you determine you no longer need the RMS emulator role, you can remove that role using the Remove-SCOMRMSEmulator PowerShell cmdlet. You must confirm the deletion of that role. This prevents running this PowerShell cmdlet accidentally. When you confirm the deletion, the RMS emulator role is removed. After removing the role, you can run Get-SCOMRMSEmulator to confirm the role is removed.
TIP: RESTORING THE RMSE ROLE AFTER IT IS REMOVED   Should you remove the RMSE role and need to restore it, you can use the same PowerShell cmdlet that moves the role to another management server to assign the role to a management server. You will want to verify afterwards that the cmdlet was successful by running Get-SCOMRMSEmulator.
