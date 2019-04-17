# Chapter: Network Monitoring (optional)

## Prepare the simulator
1.	Log on to LON-SV1.
2.	Open Internet Explorer and download the SNMP Device Simulator from Jalasoft. 
3.	Run Setup.exe and select all the defaults.
4.	Double-click the new SnmpDeviceSimulatorConsole shortcut on the desktop.
5.	In the Repository section, select Cisco PIX Firewalls and click Load.  
6.	Feel free to experiment with other devices like: Cisco Wireless, Cisco Routers, Cisco Switches
7.	Right-click Cisco PIX Firewalls and select Simulate Device.
8.	Select the 10.10.0.30 address and click Accept.
9.	Click the Start All button at the bottom of the console.
10.	Click Save Configuration and save it as SystemCenterNetworkDevices.xml on the desktop.

## Network Device Monitoring
1.	On LON-SV1, open the Operations Manager 2012 console and go to the Administration workspace.
2.	Select Discovery Wizard.
3.	Select Network Devices and click Next.
4.	Provide a name such as Operations Manager 2012 Network Discovery and select the LON-SV1.Contoso.com server under Available Servers.
5.	Click the Create Resource Pool button.
6.	In the Create a Resource Pool Wizard, provide a name such as Network Monitoring Pool.
7.	In the Pool Membership section, Add the LON-SV1 server.
8.	Click Next in the Pool Membership window.
9.	In the Summary window, click the Create button and select Close.
10.	In the Discovery Method window, select Explicit Discovery and click Next.
11.	In the Default Accounts window, select Create Account.
12.	Provide a name, such as Network Discovery, and click Next.
13.	Type: public in the Community String section and click the Create button.
14.	Click Next on the Default Account window.
15.	In the Devices window, click the Add button.
16.	Type 10.10.0.30 in the IP Address section and click OK.
17.	In the Devices window, click Next.
18.	In the Schedule Discovery window, select Run the discovery manually.
19.	In the Summary window, select Create.
20.	When the warning message appears, select Yes to distribute the new Run As account.
21.	Select Run the network discovery rule after the wizard is closed and click Close.
22.	Open the Event Viewer on LON-SV1 and refresh until you see EventID 12021 from the OpsMgr Network Discovery source.
23.	Back in the Operations Manager 2012 console, navigate to Monitoring, Network Devices to see the network devices.
