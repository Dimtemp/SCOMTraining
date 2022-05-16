# Follow this procedure to update the Operations Manager installation to update release 3.

1. On the host computer, open Windows Explorer.
2. Navigate to C:\Hyper-V\files\SC2019\Lib.
3. Right-click the UR3 folder and select copy.
4. Open Hyper-V manager, open a session to the LON-SV1 VM and log on as ADATUM\Administrator.
5. Copy the files to the desktop.
7. Run the KB4594078-AMD64-Server.exe file first.
6. Extract the kb4594078-amd64-console_43ebc155be6f16bd23f25046295f783a17b44e4a.cab file to the desktop.
7. Repeat this for all other cab files.
8. Run the kb4594078-amd64-webconsole_a1acfa83400aadb0ed22258d55461db871ea5f91 package you just extracted to the desktop.
9. Run the  kb4594078-amd64-gateway_3ca85b190add68e8b89c2da8420e8d9e963716fc package you just extracted to the desktop.
10. Run the KB4594078-AMD64-Console package you just extracted to the desktop.
11. Run the kb4594078-amd64-reporting_e99852377f67b911ca856ac41f72012548cc6778 package you just extracted to the desktop.
12. Run the kb4594078-amd64-agent_496a3262857f5d563f7f28eeeb4ef93befadff33 package you just extracted to the desktop.
14. Reboot the LON-SV1 server.

Congratulations! You just updated the SCOM 2019 RTM installation to UR3.
For more information, open this URL:
https://kevinholman.com/2021/03/31/ur3-for-scom-2019-step-by-step/
