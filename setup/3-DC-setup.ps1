# run this script from the domain controller

# init
$domainName = 'adatum.msft'
$adminPassword = 'Pa55w.rd'

# set static IP
New-NetIPAddress -InterfaceAlias Ethernet -IPAddress 10.0.0.10 -AddressFamily IPv4 -PrefixLength 24 -DefaultGateway 10.0.0.1

# install ADDS + DHCP
Install-WindowsFeature AD-Domain-Services, DHCP -IncludeManagementTools -IncludeAllSubFeature
Install-ADDSForest -DomainName $domainName -SafeModeAdministratorPassword (ConvertTo-SecureString $adminPassword -AsPlainText -Force)
# DC restarts automatically

# https://blogs.technet.microsoft.com/uktechnet/2016/06/08/setting-up-active-directory-via-powershell/
Add-DhcpServerInDC
Add-DhcpServerv4Scope -Name 'default scope' -StartRange 10.0.0.101 -EndRange 10.0.0.200 -SubnetMask 255.255.255.0
Set-DhcpServerv4OptionValue -DnsServer 10.0.0.10 -DnsDomain 'adatum.msft' -Router 10.0.0.1
Get-DhcpServerv4Lease -ScopeId 10.0.0.0
Remove-DnsServerForwarder   # remove all forwarders
# https://devblogs.microsoft.com/scripting/use-powershell-to-create-ipv4-scopes-on-your-dhcp-server/
# https://docs.microsoft.com/en-us/powershell/module/dhcpserver/set-dhcpserverv4optionvalue?view=win10-ps
