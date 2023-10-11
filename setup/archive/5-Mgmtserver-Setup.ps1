#init
$ADAccounts = 'MSAA', 'SDK', 'DRA', 'DWA'
$pw = ConvertTo-SecureString 'Pa55w.rd' -AsPlainText -Force
$scomSetup = 'C:\System Center Operations Manager 2019\Setup.exe'

if (Test-Path $scomSetup) {
    Write-Host "SCOM Setup files found."
} else {
    throw "SCOM Setup files not found! Aborting."
}


# check report viewer!
$ReportViewerFiles = Get-ChildItem C:\Windows\Microsoft.NET\assembly\GAC_MSIL -Recurse -Filter *ReportViewer*
if ($ReportViewerFiles.Count -eq 0) { Throw "ReportViewer not found! Please install." }


# prepare AD
# optionally remove SCOM OU
# Remove-ADOrganizationalUnit -Identity 'SCOM' -Confirm:$false
New-ADOrganizationalUnit 'SCOM'
foreach($ADAccount in $ADAccounts) { New-ADUser -AccountPassword $pw -Name $_ -Path 'OU=SCOM,DC=Adatum,DC=msft' -Enabled $true -PasswordNeverExpires $true }
ADD-ADGroupMember -Identity 'Domain Admins' -Members 'MSAA', 'SDK'


Get-Service SQLSERVERAGENT | Set-Service -StartupType Automatic -Passthru | Start-Service   # tbv Reporting


Start-Job {
    Start-Sleep 3   # wait for processmonitor
    Add-WindowsFeature Web-Metabase   # NLB
    Start-Process -FilePath $scomSetup -ArgumentList '/silent /install /components:OMServer,OMConsole,OMReporting /ManagementGroupName:OM1 /SRSInstance:VAN-OM1 /SqlServerInstance:VAN-OM1 /DatabaseName:OperationsManager /DWSqlServerInstance:VAN-OM1 /DWDatabaseName:OperationsManagerDW /ActionAccountUser:Adatum\MSAA /ActionAccountPassword:Pa$$w0rd /DASAccountUser:Adatum\SDK /DASAccountPassword:Pa$$w0rd /DatareaderUser:Adatum\DRA /DatareaderPassword:Pa$$w0rd /DataWriterUser:Adatum\DWA /DataWriterPassword:Pa$$w0rd /EnableErrorReporting:Always /SendODRReports:1 /SendCEIPReports:0 /UseMicrosoftUpdate:1 /AcceptEndUserLicenseAgreement:1'
}


$start = Get-Date
$p1 = Get-Process
Do {
    Sleep 1
    $p2 = gps
    Compare $p1 $p2 -Property id -passthru | % {
        $msg = "{0} {1,5} pid {2}  {3}" -f ((Get-Date)-$start).ToString(), $_.id, $_.name, $_.path
        if ($_.sideIndicator -eq "=>") { Write-Host $msg -fore green  }
        if ($_.sideIndicator -eq "<=") { Write-Host $msg -fore yellow }
    }
    $p1 = $p2
} until ( $p2 | where { $_.name -match 'monitoringhost' } )

Write-Host -fore green 'health service started!'

