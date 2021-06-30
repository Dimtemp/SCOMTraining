# Network Load Balancing the Data Access Service

Before we can use Network Load Balancing (NLB) on virtual machines we have to inform the hypervisor that MAC addresses can be spoofed.
### Perform this procedure from the host server
1. Open Hyper-V Manager
2. Open the Settings of the LON-SV1, select the Network adapter, select Advanced Features and select Enable MAC address spoofing.
3. Repeat this procedure for the LON-SV2.

### Install NLB
1. From LON-SV1, Open Server Manager and install the Network Load Balancing Feature on each management server (LON-SV1 and LON-SV2).
2. If you want to do this from PowerShell you can enter this command:
```Install-WindowsFeature NLB -ComputerName LON-SV1, LON-SV2```
3. Still on LON-SV1, open the Network Load Balancing Manager from Administrative Tools.
4. Select the **Cluster** Menu, and select New.
5. Specify **LON-SV1** and click Connect and click Next.
6. Click Next in the Host Parameters dialog box.
7. In the Cluster IP Addresses dialog box, click Add and enter the following IP address: **10.0.0.90** with subnet mask: **255.255.255.0**. Finish the Wizard.
8. Add one or more additional hosts running the System Center Data Access Service (this could be any OpsMgr management server) to the NLB cluster. In our case: LON-SV2.
9. Open DNS Manager from the Administrative Tools. Create a host (A or AAAA) record in DNS with name **SDK** and IP Address **10.10.0.90**.
10. Start Operations Manager console and connect it to the NLB cluster using the DNS name specified in step 6. If a node becomes unreachable, the console is redirected automatically to another node in that NLB cluster.

## Optional: Network Load Balancing the Web Console
As the Web console is nothing but a web service, it is a perfect candidate for NLB, which would make it highly available as well. The procedure required to network load balance the Web console is similar to that used for the System Center Data Access Service.
1. Enable NLB for each web console server participating in the NLB cluster.
2. Create the NLB cluster with a new IP address.
3. Add one or more additional hosts (running the OpsMgr Web console) to the NLB cluster.
4. Create a host record in DNS referring to the new IP address.
5. Open a web browser and specify the new name you created in the previuos step.
