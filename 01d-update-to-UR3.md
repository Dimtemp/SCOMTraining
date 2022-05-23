# Follow this procedure to update the Operations Manager installation to update release 3.

1. On the host computer, open Windows Explorer.
2. Navigate to C:\Hyper-V\files\SC2019\Lib.
3. Right-click the UR3 folder and select copy.
4. Open Hyper-V manager, open a session to the LON-SV1 VM and log on as ADATUM\Administrator.
5. Copy the files to the desktop.
7. Run the KB4594078-AMD64-Server.exe file first.
8. Run the KB4594078-AMD64-Console.msp file next.
9. Please notice this is a minimal update procedure for the training. Please inspect the URL at the end to determine if any other actions are needed in a regular, non-training, environment.
10. Reboot the LON-SV1 server.

Congratulations! You just updated the SCOM 2019 RTM installation to UR3.

For more information, open this URL:
https://kevinholman.com/2021/03/31/ur3-for-scom-2019-step-by-step/
