# Network Load Balancing the Data Access Service

Before we can use Network Load Balancing (NLB) on virtual machines we have to inform the hypervisor that MAC addresses can be spoofed. To do this open the Settings of the LON-SV1, select the Network adapter, select Advanced Features and select Enable MAC address spoofing. Repeat this procedure for the LON-SV2.
Here are the high-level steps to set up NLB for the Data Access Service:
1. Configure static IP addresses for all nodes participating in the NLB cluster.
2. Open Server Manager and install the Network Load Balancing Feature for each management server participating in the NLB cluster.
If you want to do this from PowerShell you can enter this command:
Import-Module ServerManager; Add-WindowsFeature NLB
3. Open the Network Load Balancing Manager from Administrative Tools and select the Cluster Menu, and select New.
4. Specify LON-SV1 and click Connect and click Next.
5. Click Next in the Host Parameters dialog box.
6. In the Cluster IP Addresses dialog box, click Add and enter the following IP address: 10.10.0.90 with subnet mask: 255.255.0.0. Finish the Wizard.
7. Add one or more additional hosts—running the System Center Data Access Service (this could be any OpsMgr management server)—to the NLB cluster.
8. Open DNS Manager from the Administrative Tools. Create a host (A or AAAA) record in DNS with name SDK and IP Address 10.10.0.90 (specified in step 3).
The next time the Operations console runs, connect it to the NLB cluster using the DNS name specified in step 6. If a node becomes unreachable, the console is redirected automatically to another node in that NLB cluster.

## Network Load Balancing the Web Console
As the Web console is nothing but a web service, it is a perfect candidate for NLB, which would make it highly available as well.
The procedure required to network load balance the Web console is similar to that used for the System Center Data Access Service. Here are the high-level steps:
1. Configure static IP addresses for all nodes participating in the NLB cluster.
2. Enable NLB for each management server participating in the NLB cluster.
3. Create the NLB cluster with its VIP address.
4. Add one or more additional hosts—running the OpsMgr Web console—to the NLB cluster.
5. Create a host record in DNS referring to the VIP address.
