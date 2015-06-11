<############################################################################################

PoshStack
Databases

    
Description
-----------
**TODO**

############################################################################################>

function Get-OpenStackDNSProvider {
    Param(
        [Parameter (Mandatory=$True)] [string] $Account = $(throw "Please specify required Cloud Account by using the -Account parameter"),
        [Parameter (Mandatory=$False)][bool]   $UseInternalUrl = $False,
        [Parameter (Mandatory=$False)][string] $RegionOverride = $(throw "Please specify required Region by using the -RegionOverride parameter")
    )

    # The Account comes from the file CloudAccounts.csv
    # It has information regarding credentials and the type of provider (Generic or Rackspace)

    Get-OpenStackAccount -Account $Account
    if ($RegionOverride){
        $Global:RegionOverride = $RegionOverride
    }

    # Use Region code associated with Account, or was an override provided?
    if ($RegionOverride) {
        $Region = $Global:RegionOverride
    } else {
        $Region = $Credentials.Region
    }


    # Is this Rackspace or Generic OpenStack?
    switch ($Credentials.Type)
    {
        "Rackspace" {
            # Get Identity Provider
            $cloudId    = New-Object net.openstack.Core.Domain.CloudIdentity
            $cloudId.Username = $Credentials.CloudUsername
            $cloudId.APIKey   = $Credentials.CloudAPIKey
            $Global:CloudId = New-Object net.openstack.Providers.Rackspace.CloudIdentityProvider($cloudId)
            Return New-Object net.openstack.Providers.Rackspace.CloudDnsProvider($cloudId, $Region, $UseInternalUrl, $Null)

        }
        "OpenStack" {
            $CloudIdentityWithProject = New-Object net.openstack.Core.Domain.CloudIdentityWithProject
            $CloudIdentityWithProject.Password = $Credentials.CloudPassword
            $CloudIdentityWithProject.Username = $Credentials.CloudUsername
            $CloudIdentityWithProject.ProjectId = New-Object net.openstack.Core.Domain.ProjectId($Credentials.TenantId)
            $CloudIdentityWithProject.ProjectName = $Credentials.TenantId
            $Uri = New-Object System.Uri($Credentials.IdentityEndpointUri)
            $OpenStackIdentityProvider = New-Object net.openstack.Core.Providers.OpenStackIdentityProvider($Uri, $CloudIdentityWithProject)
            Return New-Object net.openstack.Providers.Rackspace.CloudDnsProvider($Null, $Region, $UseInternalUrl, $OpenStackIdentityProvider)
        }
    }
}

# Issue 25
function Add-OpenStackDNSRecord {
    Param(
        [Parameter (Mandatory=$True)] [string] $Account = $(throw "Please specify required Cloud Account by using the -Account parameter"),
        [Parameter (Mandatory=$False)][bool]   $UseInternalUrl = $False,
        [Parameter (Mandatory=$False)][bool]   $WaitForTask = $False,
        [Parameter (Mandatory=$True)] [net.openstack.Providers.Rackspace.Objects.Dns.DnsConfiguration] $DNSConfiguration,
        [Parameter (Mandatory=$False)][string] $RegionOverride
    )

    Get-OpenStackAccount -Account $Account
    
    if ($RegionOverride){
        $Global:RegionOverride = $RegionOverride
    }

    # Use Region code associated with Account, or was an override provided?
    if ($RegionOverride) {
        $Region = $Global:RegionOverride
    } else {
        $Region = $Credentials.Region
    }


    $DNSServiceProvider = Get-OpenStackDnsProvider -Account $Account -RegionOverride $Region -UseInternalUrl $UseInternalUrl

    try {

        # DEBUGGING       
        Write-Debug -Message "Add-OpenStackDNSRecord"
        Write-Debug -Message "Account.......: $Account" 
        Write-Debug -Message "UseInternalUrl: $UseInternalUrl" 
        Write-Debug -Message "WaitForTask...: $WaitForTask"
        Write-Debug -Message "DNSConfiguration: $DNSConfiguration"
        Write-Debug -Message "RegionOverride: $RegionOverride" 

        $CancellationToken = New-Object ([System.Threading.CancellationToken]::None)

        if($WaitForTask) {
            $DNSServiceProvider.CreateDomainsAsync($DNSConfiguration, [net.openstack.Core.AsyncCompletionOption]::RequestCompleted, $CancellationToken, $null).Result
        } else {
            $DNSServiceProvider.CreateDomainsAsync($DNSConfiguration, [net.openstack.Core.AsyncCompletionOption]::RequestSubmitted, $CancellationToken, $null).Result
        }

    }
    catch {
        Invoke-Exception($_.Exception)
    }
<#
 .SYNOPSIS
 Create DNS record.

 .DESCRIPTION
 The Add-OpenStackDNSRecord cmdlet will add a DNS record.

 .PARAMETER Account
 Use this parameter to indicate which account you would like to execute this request against. 
 Valid choices are defined in PoshStack configuration file.

 .PARAMETER UseInternalUrl
 Use this parameter to specify whether or not an internal URL should be used when creating the DNS provider.

 .PARAMETER WaitForTask
 Use this parameter to specify whether you want to wait for the task to complete or return control to the script immediately.
 
 .PARAMETER DNSConfiguration
 This parameter is a complex, nested object of type [net.openstack.Providers.Rackspace.Object.Dns.DnsConfiguration] that contains the complete stack of DNS information for this process.
 
 .PARAMETER RegionOverride
 This parameter will temporarily override the default region set in PoshStack configuration file. 

 .EXAMPLE
 PS C:\Users\Administrator> N$TTL = New-TimeSpan -Seconds 100
$DnsDomainRecordConfiguration = New-Object -Type ([net.openstack.Providers.Rackspace.Objects.Dns.DnsDomainRecordConfiguration]) -ArgumentList @([net.openstack.Providers.Rackspace.Objects.Dns.DnsRecordType]::A, "name", "data", $TTL, "comment", $null)


 .LINK
 http://api.rackspace.com/api-ref-dns.html
#>
}
 
# Issue 26 Implement Copy-CloudDNSDomain
function Copy-OpenStackDNSDomain {
    Param(
        [Parameter (Mandatory=$True)] [string] $Account = $(throw "Please specify required Cloud Account by using the -Account parameter"),
        [Parameter (Mandatory=$False)][bool]   $UseInternalUrl = $False,
        [Parameter (Mandatory=$False)][bool]   $WaitForTask = $False,
        [Parameter (Mandatory=$True)] [string] $DomainId = $(throw "Please specify the required Domain Id by using the -DomainId parameter"),
        [Parameter (Mandatory=$True)] [string] $DomainName = $(throw "Please specify the required Domain Name by using the -DomainName parameter"),
        [Parameter (Mandatory=$False)][bool]   $CloneSubdomains = $null,
        [Parameter (Mandatory=$False)][bool]   $ModifyRecordData = $null,
        [Parameter (Mandatory=$False)][bool]   $ModifyEmailAddress = $null,
        [Parameter (Mandatory=$False)][bool]   $ModifyComment = $null,
        [Parameter (Mandatory=$False)][string] $RegionOverride
    )

    Get-OpenStackAccount -Account $Account
    
    if ($RegionOverride){
        $Global:RegionOverride = $RegionOverride
    }

    # Use Region code associated with Account, or was an override provided?
    if ($RegionOverride) {
        $Region = $Global:RegionOverride
    } else {
        $Region = $Credentials.Region
    }


    $DNSServiceProvider = Get-OpenStackDnsProvider -Account $Account -RegionOverride $Region -UseInternalUrl $UseInternalUrl

    try {

        # DEBUGGING       
        Write-Debug -Message "Copy-OpenStackDNSDomain"
        Write-Debug -Message "Account.......: $Account" 
        Write-Debug -Message "UseInternalUrl: $UseInternalUrl" 
        Write-Debug -Message "WaitForTask...: $WaitForTask"
        Write-Debug -Message "DomainId......: $DomainId"
        Write-Debug -Message "DomainName....: $DomainName"
        Write-Debug -Message "CloneSubdomains: $CloneSubdomains"
        Write-Debug -Message "ModifyRecordData: $ModifyRecordData"
        Write-Debug -Message "ModifyEmailAddress: $ModifyEmailAddress"
        Write-Debug -Message "ModifyComment.: $ModifyComment"
        Write-Debug -Message "RegionOverride: $RegionOverride" 

        $CancellationToken = New-Object ([System.Threading.CancellationToken]::None)

        if($WaitForTask) {
            $DNSServiceProvider.CloneDomainAsync($DomainId, $DomainName, $CloneSubdomains, $ModifyRecordData, $ModifyEmailAddress, $ModifyComment, [net.openstack.Core.AsyncCompletionOption]::RequestCompleted, $CancellationToken, $null).Result
        } else {
            $DNSServiceProvider.CloneDomainAsync($DomainId, $DomainName, $CloneSubdomains, $ModifyRecordData, $ModifyEmailAddress, $ModifyComment, [net.openstack.Core.AsyncCompletionOption]::RequestSubmitted, $CancellationToken, $null).Result
        }
    }
    catch {
        Invoke-Exception($_.Exception)
    }
<#
 .SYNOPSIS
 Clone a domain.

 .DESCRIPTION
 The Copy-OpenStackDNSDomain cmdlet allows you to clone the DNS entries for one domain to another.

 .PARAMETER Account
 Use this parameter to indicate which account you would like to execute this request against.
 Valid choices are defined in PoshStack configuration file.

 .PARAMETER UseInternalUrl
 Use this parameter to specify whether or not an internal URL should be used when creating the DNS provider.

 .PARAMETER WaitForTask
 Use this parameter to specify whether you want to wait for the task to complete or return control to the script immediately.

 .PARAMETER DomainId
 Use this parameter to specify the domain.

 .PARAMETER DomainName
 Use this parameter to specify the name of the cloned domain.

 .PARAMETER CloneSubdomains
 True to recursively clone subdomains; otherwise, false to only clone the top-level domain and its records. Cloned subdomain configurations are modified the same way that cloned top-level domain configurations are modified. If this is null (or not supplied), a provider-specific default value is used.

 .PARAMETER ModifyRecordData
 True to replace occurrences of the reference domain name with the new domain name in comments on the cloned (new) domain. If this is null (or not supplied), a provider-specific default value is used.

 .PARAMETER ModifyEmailAddress
 True to replace occurrences of the reference domain name with the new domain name in email addresses on the cloned (new) domain. If this is null (or not supplied), a provider-specific default value is used.

 .PARAMETER ModifyComment
 True to replace occurrences of the reference domain name with the new domain name in data fields (of records) on the cloned (new) domain. Does not affect NS records. If this is null (or not supplied), a provider-specific default value is used.
 
 .PARAMETER RegionOverride
 This parameter will temporarily override the default region set in PoshStack configuration file.

 .EXAMPLE
 PS C:\Users\Administrator> 


 .LINK
 http://api.rackspace.com/api-ref-dns.html
#>
}

# Issue 41 Implement Remove-CloudDNSPtrRecords
function Remove-OpenStackDNSPtrRecord {
    Param(
        [Parameter (Mandatory=$True)] [string] $Account = $(throw "Please specify required Cloud Account by using the -Account parameter"),
        [Parameter (Mandatory=$False)][bool]   $UseInternalUrl = $False,
        [Parameter (Mandatory=$False)][bool]   $WaitForTask = $False,
        [Parameter (Mandatory=$True)] [string] $ServiceName,
        [Parameter (Mandatory=$True)] [Uri]    $ServiceURI,
        [Parameter (Mandatory=$True)] [System.Net.IPAddress] $IPAddress,
        [Parameter (Mandatory=$False)][string] $RegionOverride
    )

    Get-OpenStackAccount -Account $Account
    
    if ($RegionOverride){
        $Global:RegionOverride = $RegionOverride
    }

    # Use Region code associated with Account, or was an override provided?
    if ($RegionOverride) {
        $Region = $Global:RegionOverride
    } else {
        $Region = $Credentials.Region
    }


    $DNSServiceProvider = Get-OpenStackDnsProvider -Account $Account -RegionOverride $Region -UseInternalUrl $UseInternalUrl

    try {

        # DEBUGGING       
        Write-Debug -Message "Remove-OpenStackDNSPtrRecord"
        Write-Debug -Message "Account.......: $Account" 
        Write-Debug -Message "UseInternalUrl: $UseInternalUrl" 
        Write-Debug -Message "WaitForTask...: $WaitForTask"
        Write-Debug -Message "ServiceName...: $ServiceName"
        Write-Debug -Message "ServiceURI....: $ServiceURI"
        Write-Debug -Message "IPAddress.....: $IPAddress"
        Write-Debug -Message "RegionOverride: $RegionOverride" 

        $CancellationToken = New-Object ([System.Threading.CancellationToken]::None)


#            Uri serviceURI = new Uri("uristring");
#            System.Net.IPAddress ip = new System.Net.IPAddress(0x2414188f);
#           DnsJob remove = await provider.RemovePtrRecordsAsync("servicename", serviceURI, ip, AsyncCompletionOption.RequestCompleted, CancellationToken.None, null);


        if($WaitForTask) {
            $DNSServiceProvider.RemovePtrRecordsAsync($ServiceName, $ServiceURI, $IPAddress, [net.openstack.Core.AsyncCompletionOption]::RequestCompleted, $CancellationToken, $null).Result
        } else {
            $DNSServiceProvider.RemovePtrRecordsAsync($ServiceName, $ServiceURI, $IPAddress, [net.openstack.Core.AsyncCompletionOption]::RequestSubmitted, $CancellationToken, $null).Result
        }
    }
    catch {
        Invoke-Exception($_.Exception)
    }
<#
 .SYNOPSIS
 Remove Ptr record(s).

 .DESCRIPTION
 The Remove-OpenStackDNSPtrRecord cmdlet allows you to remove the Ptr record(s).

 .PARAMETER Account
 Use this parameter to indicate which account you would like to execute this request against.
 Valid choices are defined in PoshStack configuration file.

 .PARAMETER UseInternalUrl
 Use this parameter to specify whether or not an internal URL should be used when creating the DNS provider.

 .PARAMETER WaitForTask
 Use this parameter to specify whether you want to wait for the task to complete or return control to the script immediately.

 .PARAMETER ServiceName
 Use this parameter to specify the name of the service.

 .PARAMETER ServiceURI
 Use this parameter to specify the URI of the service.

 .PARAMETER IPAddress
 Use this parameter to specify the IP Address.
 
 .PARAMETER RegionOverride
 This parameter will temporarily override the default region set in PoshStack configuration file.

 .EXAMPLE
 PS C:\Users\Administrator> 


 .LINK
 http://api.rackspace.com/api-ref-dns.html
#>
}

# Issue 42 Implement Remove-CloudDNSRecords
function Remove-OpenStackDNSRecord {
    Param(
        [Parameter (Mandatory=$True)] [string] $Account = $(throw "Please specify required Cloud Account by using the -Account parameter"),
        [Parameter (Mandatory=$False)][bool]   $UseInternalUrl = $False,
        [Parameter (Mandatory=$False)][bool]   $WaitForTask = $False,
        [Parameter (Mandatory=$True)] [string] $DomainId = $(throw "Please specify the required Domain ID by using the -DomainId paramter"),
        [Parameter (Mandatory=$True)] [net.openstack.Providers.Rackspace.Objects.Dns.RecordId[]] $RecordIdList = $(throw "Please specify the required list of Record IDs by using the -RecordIdList paramter"),
        [Parameter (Mandatory=$False)][string] $RegionOverride
    )

    Get-OpenStackAccount -Account $Account
    
    if ($RegionOverride){
        $Global:RegionOverride = $RegionOverride
    }

    # Use Region code associated with Account, or was an override provided?
    if ($RegionOverride) {
        $Region = $Global:RegionOverride
    } else {
        $Region = $Credentials.Region
    }


    $DNSServiceProvider = Get-OpenStackDnsProvider -Account $Account -RegionOverride $Region -UseInternalUrl $UseInternalUrl

    try {

        # DEBUGGING       
        Write-Debug -Message "Remove-OpenStackDNSRecord"
        Write-Debug -Message "Account.......: $Account" 
        Write-Debug -Message "UseInternalUrl: $UseInternalUrl" 
        Write-Debug -Message "WaitForTask...: $WaitForTask"
        Write-Debug -Message "DomainId......: $DomainId"
        Write-Debug -Message "ServiceURI....: $ServiceURI"
        Write-Debug -Message "RecordIdList..: $RecordIdList"
        Write-Debug -Message "RegionOverride: $RegionOverride" 

        $CancellationToken = New-Object ([System.Threading.CancellationToken]::None)

        if($WaitForTask) {
            $DNSServiceProvider.RemoveRecordsAsync($DomainId, $RecordIdList, [net.openstack.Core.AsyncCompletionOption]::RequestCompleted, $CancellationToken, $null).Result
        } else {
            $DNSServiceProvider.RemoveRecordsAsync($DomainId, $RecordIdList, [net.openstack.Core.AsyncCompletionOption]::RequestSubmitted, $CancellationToken, $null).Result
        }
    }
    catch {
        Invoke-Exception($_.Exception)
    }
<#
 .SYNOPSIS
 Remove DNS record(s).

 .DESCRIPTION
 The Remove-OpenStackDNSRecord cmdlet allows you to remove DNS record(s).

 .PARAMETER Account
 Use this parameter to indicate which account you would like to execute this request against.
 Valid choices are defined in PoshStack configuration file.

 .PARAMETER UseInternalUrl
 Use this parameter to specify whether or not an internal URL should be used when creating the DNS provider.

 .PARAMETER WaitForTask
 Use this parameter to specify whether you want to wait for the task to complete or return control to the script immediately.

 .PARAMETER DomainId
 Use this parameter to specify the domain.

 .PARAMETER RecordIdList
 Use this parameter to specify the list of records to be removed.

 .PARAMETER RegionOverride
 This parameter will temporarily override the default region set in PoshStack configuration file.

 .EXAMPLE
 PS C:\Users\Administrator> 


 .LINK
 http://api.rackspace.com/api-ref-dns.html
#>}

# Issue 43 Implement Update-CloudDNSDomains
function Update-OpenStackDNSDomain {
    Param(
        [Parameter (Mandatory=$True)] [string] $Account = $(throw "Please specify required Cloud Account by using the -Account parameter"),
        [Parameter (Mandatory=$False)][bool]   $UseInternalUrl = $False,
        [Parameter (Mandatory=$False)][bool]   $WaitForTask = $False,
        [Parameter (Mandatory=$True)] [net.openstack.Providers.Rackspace.Objects.Dns.DNSDomainUpdateConfiguration[]] $DNSDomainUpdateConfigurationList,
        [Parameter (Mandatory=$False)][string] $RegionOverride
    )

    Get-OpenStackAccount -Account $Account
    
    if ($RegionOverride){
        $Global:RegionOverride = $RegionOverride
    }

    # Use Region code associated with Account, or was an override provided?
    if ($RegionOverride) {
        $Region = $Global:RegionOverride
    } else {
        $Region = $Credentials.Region
    }


    $DNSServiceProvider = Get-OpenStackDnsProvider -Account $Account -RegionOverride $Region -UseInternalUrl $UseInternalUrl

    try {

        # DEBUGGING       
        Write-Debug -Message "Add-OpenStackDNSRecord"
        Write-Debug -Message "Account.......: $Account" 
        Write-Debug -Message "UseInternalUrl: $UseInternalUrl" 
        Write-Debug -Message "WaitForTask...: $WaitForTask"
        Write-Debug -Message "DNSDomainUpdateConfigurationList: $DNSDomainUpdateConfigurationList"
        Write-Debug -Message "RegionOverride: $RegionOverride" 

        $CancellationToken = New-Object ([System.Threading.CancellationToken]::None)


        if($WaitForTask) {
            $DNSServiceProvider.UpdateDomainsAsync($DNSDomainUpdateConfigurationList, [net.openstack.Core.AsyncCompletionOption]::RequestCompleted, $CancellationToken, $null).Result
        } else {
            $DNSServiceProvider.UpdateDomainsAsync($DNSDomainUpdateConfigurationList, [net.openstack.Core.AsyncCompletionOption]::RequestSubmitted, $CancellationToken, $null).Result
        }
    }
    catch {
        Invoke-Exception($_.Exception)
    }
<#
 .SYNOPSIS
 Update DNS domain.

 .DESCRIPTION
 The Update-OpenStackDNSDomain cmdlet allows you to update the domain information.

 .PARAMETER Account
 Use this parameter to indicate which account you would like to execute this request against.
 Valid choices are defined in PoshStack configuration file.

 .PARAMETER UseInternalUrl
 Use this parameter to specify whether or not an internal URL should be used when creating the DNS provider.

 .PARAMETER WaitForTask
 Use this parameter to specify whether you want to wait for the task to complete or return control to the script immediately.

 .PARAMETER DNSDomainUpdateConfigurationList
 This parameter is a list of the complex, nested object of type [net.openstack.Providers.Rackspace.Object.Dns.DnsDomainUpdateConfiguration] that contains the DNS information for this process.
 
 .PARAMETER RegionOverride
 This parameter will temporarily override the default region set in PoshStack configuration file.

 .EXAMPLE
 PS C:\Users\Administrator> 


 .LINK
 http://api.rackspace.com/api-ref-dns.html
#>
}

# Issue 45
function Update-OpenStackDNSRecord {
    Param(
        [Parameter (Mandatory=$True)] [string] $Account = $(throw "Please specify required Cloud Account by using the -Account parameter"),
        [Parameter (Mandatory=$False)][bool]   $UseInternalUrl = $False,
        [Parameter (Mandatory=$False)][bool]   $WaitForTask = $False,
        [Parameter (Mandatory=$True)] [net.openstack.Providers.Rackspace.IDnsService] $DomainId,
        [Parameter (Mandatory=$True)] [net.openstack.Providers.Rackspace.Objects.Dns.DnsDomainRecordUpdateConfiguration[]] $DNSDomainRecordUpdateConfigurationList,
        [Parameter (Mandatory=$True)] [net.openstack.Providers.Rackspace.Objects.Dns.DnsRecordType] $DNSRecordType,
        [Parameter (Mandatory=$False)][string] $RegionOverride
    )

#            DomainId domainId = new DomainId("id");
#
#            int _offset = 0;
#            int _limit = 100;
#            Tuple<ReadOnlyCollectionPage<DnsRecord>,int?> recordlist = await provider.ListRecordsAsync(domainId, DnsRecordType.A, "recordname", "recordData", _offset, _limit, CancellationToken.None);
#            DnsRecord recordToBeUpdated = recordlist.Item1[0];
#            DnsDomainRecordUpdateConfiguration dnsDomainRecordUpdateConfiguration = new DnsDomainRecordUpdateConfiguration(recordToBeUpdated, "name", "data", TimeSpan.FromSeconds(100), "comment", priority);
#            List<DnsDomainRecordUpdateConfiguration> dnsDomainRecordUpdateConfigurationList = new List<DnsDomainRecordUpdateConfiguration>();
#            dnsDomainRecordConfigurationList.Add(dnsDomainRecordConfiguration);
#            DnsJob ur = await provider.UpdateRecordsAsync(domainId, dnsDomainRecordUpdateConfigurationList, AsyncCompletionOption.RequestCompleted, CancellationToken.None, null);

    Get-OpenStackAccount -Account $Account
    
    if ($RegionOverride){
        $Global:RegionOverride = $RegionOverride
    }

    # Use Region code associated with Account, or was an override provided?
    if ($RegionOverride) {
        $Region = $Global:RegionOverride
    } else {
        $Region = $Credentials.Region
    }


    $DNSServiceProvider = Get-OpenStackDnsProvider -Account $Account -RegionOverride $Region -UseInternalUrl $UseInternalUrl

    try {

        # DEBUGGING       
        Write-Debug -Message "Add-OpenStackDNSRecord"
        Write-Debug -Message "Account.......: $Account" 
        Write-Debug -Message "UseInternalUrl: $UseInternalUrl" 
        Write-Debug -Message "WaitForTask...: $WaitForTask"
        Write-Debug -Message "DomainId......: $DomainId"
        Write-Debug -Message "DNSDomainRecordUpdateConfigurationList: $DNSDomainRecordUpdateConfigurationList"
        Write-Debug -Message "DNSRecordType.: $DNSRecordType"
        Write-Debug -Message "RegionOverride: $RegionOverride" 

        $CancellationToken = New-Object ([System.Threading.CancellationToken]::None)

        if($WaitForTask) {
            $DNSServiceProvider.UpdateRecordsAsync($DomainId, $DNSDomainRecordUpdateConfigurationList, [net.openstack.Core.AsyncCompletionOption]::RequestCompleted, $CancellationToken, $null).Result
        } else {
            $DNSServiceProvider.UpdateRecordsAsync($DomainId, $DNSDomainRecordUpdateConfigurationList, [net.openstack.Core.AsyncCompletionOption]::RequestSubmitted, $CancellationToken, $null).Result
        }
    }
    catch {
        Invoke-Exception($_.Exception)
    }
<#
 .SYNOPSIS
 Update DNS record.

 .DESCRIPTION
 The Update-OpenStackDNSRecord cmdlet allows you to update the DNS records for a domain.

 .PARAMETER Account
 Use this parameter to indicate which account you would like to execute this request against.
 Valid choices are defined in PoshStack configuration file.

 .PARAMETER UseInternalUrl
 Use this parameter to specify whether or not an internal URL should be used when creating the DNS provider.

 .PARAMETER WaitForTask
 Use this parameter to specify whether you want to wait for the task to complete or return control to the script immediately.

 .PARAMETER DomainId
 The unique identifier associate with the domain.
 
 .PARAMETER DNSDomainRecordUpdateConfigurationList
 This parameter is a complex, nested object of type [net.openstack.Providers.Rackspace.Object.Dns.DnsDomainRecordUpdateConfiguration] that contains the complete stack of DNS information for this process.

 .PARAMETER DNSRecordType
 A parameter of type [net.openstack.Providers.Rackspace.Object.Dns.DnsRecordType] that specifies which record type is to be updated. For example, "Ptr" or "A".
 
 .PARAMETER RegionOverride
 This parameter will temporarily override the default region set in PoshStack configuration file.

 .EXAMPLE
 PS C:\Users\Administrator> 


 .LINK
 http://api.rackspace.com/api-ref-dns.html
#>
}

Export-ModuleMember -Function *
