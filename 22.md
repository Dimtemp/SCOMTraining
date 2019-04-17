# Chapter: Implementing the Gateway server (optional)

The following exercises are about deploying agents through gateway servers, combined with a Public Key Infrastructure (PKI) for certificate authentication. It consists of the following sections:
1.	Configuring DNS on LON-DC1 and NYC-DC1
2.	Deploying the Certificate Authority
3.	Creating the certificate template
4.	Issuing the certificates
5.	Install the Gateway service on NYC-SVR1
6.	Deploying an Agent to NYC-DC1

## DNS
Name resolution is not provided between the two domains. We’re creating a conditional forwarder for each domain.
Log on to LON-DC1 and open the DNS Manager from Administrative tools. Navigate to the Conditional Forwarders section and create a new forwarder for domain contoso.com, IP address: 10.10.10.10. Open the Windows Firewall and turn the firewall Off for all network profiles (domain, private, public).
Log on to NYC-DC1 and open the DNS Manager from Administrative tools. Navigate to the Conditional Forwarders section and create a new forwarder for domain adatum.com, IP address: 10.10.0.10. Open the Windows Firewall and turn the firewall Off for all network profiles (domain, private, public).
To verify the forwarder, open a prompt on LON-DC1 and run NSLookup nyc-dc1.contoso.com. It should return 10.10.10.10.
Open a prompt on NYC-DC1 and run NSLookup LON-DC1.adatum.com. It should return 10.10.0.10.

## Deploying the Certificate Authority
Since we will utilize the Web enrollment feature, the web server role (IIS) must be preinstalled. Be aware you cannot change the name of a computer once the CA role is installed.
Perform the following steps to deploy an enterprise root CA on the Domain Controller:
1. On LON-DC1, run the Add Roles Wizard and set up the following components of the Active Directory Certificate Service: Certification authority and Certification authority Web enrollment. For this training these components are already installed so you can skip to step 6.
2. During CA setup, specify to install an Enterprise CA of the Root CA type. The common name of the CA is a descriptive string such as Adatum Service Provider Root CA .
3. Select the longest desired validity period for the root certificate, at least 5 years.
4. Place the CA database and log in the default path.
5. After installation, the Enterprise CA root certificate is automatically distributed via AD group policy to all domain-joined computers, and placed in the Trusted Root Certification Authorities certificate store of the local computer.
6. Export the root CA certificate to a .CER file; this file will be required later to import into the gateway server computer. Run this command line on the enterprise CA computer and save the resulting file:
certutil  -ca.cert  c:\CA-root-certificate.cer
This command does not work in PowerShell in older versions of Windows. Please run this command from a command prompt.

## Creating and Preparing the OpsMgr Certificate Template
This section adds the functionality to the Enterprise CA needed for the service provider model. Specifically, the CA will be able to issue a custom certificate type recognized by OpsMgr components such as agent, gateway, and management server. Follow these steps:
1. On the CA computer (LON-DC1), go to Start and type MMC. In the MMC snap-in, select File -> Add/Remove Snap-in -> Certificate Templates and Certification Authority (local computer). Click OK.
2. Select Certificate Templates; in the console right-click on IPSec (Offline request) and select Duplicate Template.
3. When prompted, select Windows Server 2003 Enterprise.
4. Name the certificate something descriptive like OpsMgr.
5. On the Request Handling tab, select Allow the private key to be exported. Also on the Request Handling tab, click the CSPs button and select Microsoft Enhanced Cryptographic Provider v1.0, taking care not to remove the option Microsoft RSA SChannel Cryptographic Provider.
6. On the Extensions tab, edit the Applications Policies. Remove IP security IKE intermediate and add Client Authentication and Server Authentication policies.
7. On the Security tab, confirm that Authenticated Users have Read permissions for the new template. Also on the Security tab, add the computer account of LON-DC1, and grant that account Read and Enroll permission on the certificate. (This is necessary to issue the certificate using the CA Web enrollment method.)
8. Click OK to create the template. The template now can be added to the CA.
9. In the MMC, go to Certification Authority. Right-click on Certificate Templates -> New -> Certificate Template To Issue.
10. Select the OpsMgr certificate and click OK. The CA can now issue OpsMgr certificates.

## Active Directory Enrollment Policy for NYC-SVR1
You can issue certificates for any use using the Certificates MMC and Active Directory Enrollment Policy, including customer OpsMgr gateway servers and agent computers. Because the IPSEC (Offline request) certificate template was copied to use as the starting model for the certificate, the certificate is configured to allow the details of the certificate to be manually provided rather than automatically by AD. The output of this process is a certificate file with private key with a .PFX extension that is ready to use with OpsMgr.
Follow these steps to issue an OpsMgr authentication certificate using Active Directory Enrollment Policy and the Certificates MMC:
1. On LON-DC1, go to Start and type MMC. In the MMC snap-in, select File -> Add/Remove Snap-in -> select Certificates -> Add Computer Account -> for Local Computer. Click Finish and then OK.
2. Expand the Certificates\Personal\Certificates store. Right-click and select All Tasks -> Request new certificate. Click Next.
3. You should see the Select Certificate Enrollment Policy screen appear with the Active Directory Enrollment Policy selected. Click Next.
4. At the Request Certificates page of the Certificate Enrollment Wizard, click on the More information is required to enroll for this certificate link.
5. In the Subject name: Type: drop-down list, select Common name . In the Value: field, type the fully qualified domain name of the computer the certificate is being issued for, nyc-svr1.contoso.com in this example. Click Add and the FQDN appears in the right side of the Certificate Properties. Click OK. Make sure the OpsMgr certificate is selected and click Enroll.
6. The certificate is issued by Active Directory using the credentials of the logged on user with the certificate request processed and installed in the Computer certificates store. The certificate is ready to be exported to a .PFX file and transported to the customer.
▶ Export the .PFX file from the Certificates MMC by right-clicking the certificate and selecting All Tasks -> Export , and then click Next.
▶ Select Yes , export the private key, and then click Next.
▶ Select to Export all extended properties and click Next.
▶ Assign and confirm a password for the .PFX file and click Next.
▶ Select a folder and file name for the certificate, such as nyc-svr1.contoso.com.PFX, basing the certificate name on the computer name for which it is issued. Click Next and Finish.
7. After confirming a timely and successful transport of the file to the customer environment, delete the certificate from the certificate store of the service provider’s domain computer where it was issued. This is a housekeeping issue and has customer privacy considerations.

## Web Enrollment for NYC-SVR1
A second means to obtain OpsMgr authentication certificates with a GUI, in addition to Active Directory domain policy, is the Web enrollment feature of the Microsoft CA installed along with the CA role. You can use this self-service web portal to install Windows Server 2003 Enterprise CA format certificates on the computer running the web browser. (If the service provider template is based on Windows Server 2008 CA format, the certificate does not appear in the web enrollment site.) The web enrollment method is available both with stand-alone and enterprise CAs.
Follow these steps from NYC-SVR1 to issue an OpsMgr authentication certificate using web enrollment:
Unlike the \CertEnroll virtual folder seen in IIS on the CA that requires anonymous public access for the CRL, the \CertSrv virtual folder is secured by Windows authentication (Kerberos and NTLM). To obtain a certificate using this method from the desktop of a Windows server, you must disable Internet Explorer Enhanced Security Configuration (IE ESC) for the administrator while performing the work. This is because an ActiveX control is downloaded to the web browser that does the work to request the certificate, receives the response, and installs it on the computer. With IE ESC enabled, the ActiveX control cannot download. Click Configure IE ESC from the main page in Server Manager and set both to Off.
1. Open Internet Explorer on the computer where the certificate will be installed: NYC-SVR1. This can be any computer, not just the computer to which the certificate is being issued, as you can export and import the resulting certificate to the actual destination computer separately.
2. Browse to https://LON-DC1.adatum.com/CertSrv. Certificate request and issue functions will not work using HTTP (TCP port 80).
3. You will be prompted for Windows credentials to access the website. When you see the Microsoft Active Directory Certificate Services portal, click the Request a certificate link.
4. Click the advanced certificate request link, and then click the Create and submit a request to this CA link. You may see a Web Access Confirmation dialog about this website attempting to perform a digital certificate operation on your behalf; click Yes.
5. On the Advanced Certificate Request page, in the Certificate Template drop-down list, select the OpsMgr template. Type the FQDN of the gateway computer in the Name field:
nyc-svr1.contoso.com. All other fields are optional. 
6. Click the Submit button at the bottom of the Advanced Certificate Request page.
7. After a moment, you should see Certificate Issued; proceed to click on Install this certificate.
8. You should see the message Your new certificate has been successfully installed; you can either close IE or click the Home link in the upper-right corner if you want to issue another certificate.
Something to be aware of is which local certificate store the certificate was saved to by IE. Most likely, it is the Current User Personal certificate store rather than the Local Computer Personal store. OpsMgr certificates are not useful in the User store and must be exported to a .PFX file.
9. Export the .PFX file from the Certificates MMC by right-clicking the certificate and selecting All Tasks -> Export -> Next .
10. Select Yes, export the private key, and then click Next.
11. Select to Export all extended properties and click Next.
12. Assign and confirm a password for the .PFX file and click Next.
13. Select a folder and file name for the certificate, such as nyc-svr1.contoso.com.PFX, basing the certificate name on the computer name for which it is issued. Click Next and Finish.
14. After confirming a successful export, delete the certificate in the Current User Personal certificate store. The exported .PFX file is ready to use with OpsMgr on the computer in whose name the certificate was issued.

## Command Line and Request File for NYC-SVR1
A third means to obtain OpsMgr authentication certificates does not require a GUI and works with a stand-alone as well as an enterprise CA. This method does not produce any .PFX files and delivers the private key directly to the requesting computer in the form of a response to the request.
Follow these steps to issue an OpsMgr authentication certificate using the command line and a request file:
1. Create a file named RequestPolicy.INF on the computer that will be requesting the certificate.
Here are the contents of the RequestPolicy.INF file. You may need to modify the certificate template name to match the name of your gateway certificate template.
[Version]
Signature="$Windows NT$"
[NewRequest]
Subject = "CN=nyc-svr1.contoso.com"
Exportable = TRUE
KeyLength = 2048
KeySpec = 1
KeyUsage = 0xA0
MachineKeySet = True
ProviderName = "Microsoft RSA SChannel Cryptographic Provider"
RequestType = PKCS10
[RequestAttributes]
certificateTemplate = "OpsMgr"
2. Open an elevated command prompt on the computer and change directory to where the RequestPolicy.INF file was saved. Run this command:
CertReq.exe -new RequestPolicy.inf CertificateRequest.req
3. The resulting certificate request file CertificateRequest.REQ is a text file containing a 2048-bit key that also lends itself to copy-and-paste using the clipboard in a remote desktop scenario, as well as conventional file copy or emailing of attachments.
4. Copy the request file to LON-DC1; open an elevated command prompt to the folder where the CertificateRequest.REQ file was saved, and run this command (execute both lines as one command):
Certreq.exe -submit -config "LON-DC1\adatum-LON-DC1-CA" CertificateRequest.req CertificateResponse.cer
5. Copy the CertificateResponse.CER file back to the requesting computer. Open an elevated command prompt on the computer and change directory to where the CertificateResponse.CER file was saved. Run this command:
CertReq.exe -accept -config "LON-DC1\adatum-LON-DC1-CA" CertificateResponse.cer
The OpsMgr authentication certificate now resides in the Local Computer Personal Certificates store. If you will be installing an OpsMgr gateway or agent computer manually, you can run the MomCertImport.exe utility interactively and select the OpsMgr authentication certificate directly from the certificate store. If you plan to install OpsMgr features programmatically, you may need to export the certificate to a .PFX file. Follow the same procedures as steps 9 to 14 of the “Web Enrollment” section to export a certificate copy with private key.

## Gateway server on NYC-SVR1
Follow these steps to install a gateway server on NYC-SVR1:
1. The .NET Framework 4 (4.5 for Windows 2012 Server systems) is required on gateway servers to support network monitoring and UNIX/Linux computer monitoring. In Operations Manager, the gateway servers must have .NET Framework 4.x installed if using the networking monitoring feature in a management group and the devices managed are behind gateway servers. The prerequisite checker does not check for.NET Framework 4.x when you install a gateway server. If appropriate, install the .NET Framework 4.x.
2. Run the gateway approval tool on an existing management server. First copy Microsoft.EnterpriseManagement.GatewayApprovalTool.exe and Microsoft.EnterpriseManagement.GatewayApprovalTool.exe.config from the \SupportTools folder on the Operations Manager DVD to %ProgramFiles%\System Center 2012\Operations Manager\Server.
▶ Open an elevated command prompt on the management server, and change directory to the OpsMgr program files server folder.
▶ Run the tool with command line switches to assign the new gateway to an existing management server or gateway. This creates the computer object in OpsMgr for the gateway. The following lines should be executed as one command:
Microsoft.EnterpriseManagement.GatewayApprovalTool.exe
/ManagementServerName=LON-SV1.Adatum.com
/GatewayName=NYC-SVR1.contoso.com
/Action=Create
3. On the prospective gateway server, from the Operations Manager DVD, run Setup; at the splash screen, click the Gateway management server link in the Optional Installations section to start a setup wizard.
4. The Welcome to the System Center 2012 – Operations Manager Gateway Server Setup wizard appears. Click Next.
5. Select Installation location. The default location is %ProgramFiles%\System Center 2012\Operations Manager. Click Next.
6. At the Management Group Configuration page, enter the name of the management group and management sever name (specify the FQDN!) to which the gateway will report. This will be the same management server name used when running the gateway approval tool on the management server. This gateway (NYC-SVR1.Contoso.com) will report to LON-SV1.Adatum.com. Click Next.
7. At the Gateway Action Account page, select to use Local System if the gateway will not be pushing agents to other computers. Click Next.
8. At the Ready to Install page, confirm settings and click the Install button. When installation completes, click the Finish button.
9. If you are using certificates for authentication, import the Operations Manager client certificate on the gateway server as follows:
▶ Copy the MOMCertImport.exe file from the \SupportTools folder on the OpsMgr installation media to the OpsMgr program files gateway folder, such as %ProgramFiles% \System Center Operations Manager\Gateway.
▶ Open an elevated command prompt on the gateway server, and change directory to the OpsMgr program files gateway folder.
▶ Run the tool with command line switches to import the certificate.
MOMCertImport.exe nyc-svr1.contoso.com.pfx /Password Password1
10. You must enable the Server Proxy setting on the new gateway server. (This setting is automatically enabled for management servers but not gateways.) Navigate in the Operations console to Administration -> Device Management -> Management Servers, select and right-click the new gateway, and select Properties. On the Security tab, tick the option to Allow this server to act as a proxy and discover managed objects on other computers. Click OK.
11. Within several minutes of importing the certificate on the gateway, the computer object for the gateway in the Operations console should appear as healthy.

## Installing an Agent in an Untrusted Domain or Workgroup
This next procedure deploys an agent on NYC-DC1 that is not a member of a trusted domain. Perform the following steps:
1. Begin with enabling manual agents to be installed in your management group. If you don’t perform this step, manual agents are automatically rejected, which is the default behavior of OpsMgr. Navigate to Administration -> Settings -> Security in the Operations console and select Review new manual agent installations in pending management view. Click OK.
2. On the computer to be managed (NYC-DC1), run Setup from the Operations Manager DVD. Then from the splash screen, click the Local agent link in the Optional Installations section.
3. The Welcome to the System Center 2012 – Operations Manager Agent Setup wizard appears. Click Next.
4. Select the default Installation location. Click Next.
5. At the Specify Management Group information page, accept the default to Specify Management Group information and click Next.
6. At the Management Group Configuration page, enter the name of the management group and management server or gateway sever name to which the agent will report. In this example, use NYC-SVR1. Click Next.
7. At the Agent Action Account page, select the default to use Local System and click Next.
8. At the Ready to Install page, confirm settings and click the Install button. When installation completes, click the Finish button.
9. Import the Operations Manager client certificate on the agent:
▶ Copy the MOMCertImport.exe file from the \SupportTools folder on the OpsMgr installation media to the Operations Manager program files client folder.
▶ Open an elevated command prompt on the agent computer, and change directory to the OpsMgr program files server folder (%ProgramFiles%\System Center 2012\Operations Manager\Agent).
▶ Run the tool with command line switches to import the certificate when installing a gateway server.
MOMCertImport.exe nyc-svr1.adatum.com.pfx /Password Password1
10. Within several minutes of importing the certificate on the agent, the computer object for the agent should appear in the Operations console in the Administration -> Device Management -> Pending Management view. Right-click and select Approve.
It is often necessary to enable the Server Proxy setting on new manually installed agents. Server Proxy is disabled for agents by default, but required for many management packs to function. Navigate in the Operations console to Administration -> Device Management -> Agent Managed, select and right-click each new agent and select Properties. On the Security tab, tick the option to Allow this server to act as a proxy and discover managed objects on other computers. Click OK.
