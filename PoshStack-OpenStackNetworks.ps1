<############################################################################################

PoshStack
                                                    Networks

    
Description
-----------
**TODO**

############################################################################################>


function Get-OpenStackNetworkProvider {
    Param(
        [Parameter (Mandatory=$True)] [string] $Account = $(throw "Please specify required OpenStack Account by using the -Account parameter")
    )

    # The Account comes from the file CloudAccounts.csv
    # It has information regarding credentials and the type of provider (Generic or Rackspace)

    Get-OpenStackAccount -Account $Account

    # Is this Rackspace or Generic OpenStack?
    switch ($Credentials.Type)
    {
        "Rackspace" {
            # Get Identity Provider
            $OpenStackId    = New-Object net.openstack.Core.Domain.CloudIdentity
            $OpenStackId.Username = $Credentials.CloudUsername
            $OpenStackId.APIKey   = $Credentials.CloudAPIKey
            $Global:OpenStackId = New-Object net.openstack.Providers.Rackspace.CloudIdentityProvider($OpenStackId)
            Return New-Object net.openstack.Providers.Rackspace.CloudNetworksProvider($OpenStackId)
        }
        "OpenStack" {
            $OpenStackIdentityWithProject = New-Object net.openstack.Core.Domain.CloudIdentityWithProject
            $OpenStackIdentityWithProject.Password = $Credentials.CloudPassword
            $OpenStackIdentityWithProject.Username = $Credentials.CloudUsername
            $OpenStackIdentityWithProject.ProjectId = New-Object net.openstack.Core.Domain.ProjectId($Credentials.TenantId)
            $OpenStackIdentityWithProject.ProjectName = $Credentials.TenantId
            $Uri = New-Object System.Uri($Credentials.IdentityEndpointUri)
            $OpenStackIdentityProvider = New-Object net.openstack.Core.Providers.OpenStackIdentityProvider($Uri, $OpenStackIdentityWithProject)
            Return New-Object net.openstack.Providers.Rackspace.CloudNetworksProvider($Null, $OpenStackIdentityProvider)
        }
    }
}

# List account networks
function Get-OpenStackNetworks {
    
        Param(
        [Parameter (Mandatory=$True)] [string] $Account = $(throw "Please specify required OpenStack Account with -Account parameter"),
        [Parameter (Mandatory=$False)][string] $RegionOverride
    )

    $OpenStackNetworkProvider = Get-OpenStackNetworkProvider -Account $Account

    if ($RegionOverride){
        $Global:RegionOverride = $RegionOverride
    }

    # Use Region code associated with Account, or was an override provided?
    if ($RegionOverride) {
        $Region = $Global:RegionOverride
    } else {
        $Region = $Credentials.Region
    }

    # DEBUGGING             
    Write-Debug -Message "Account.: $Account"
    Write-Debug -Message "Region..: $Region"


    # Get the list of servers
    $OpenStackNetworkProvider.ListNetworks($Region)

<#
 .SYNOPSIS
 The Get-OpenStackNetworks cmdlet will pull down a list of detailed information of all account networks.

 .DESCRIPTION
 This command is executed against provided region or all regions.

 .PARAMETER Account
 Use this parameter to indicate which account you would like to execute this request against. 
 Valid choices are defined in PoshStack configuration file.

 .PARAMETER RegionOverride
 This parameter will temporarily override the default region set in PoshStack configuration file. 

 .EXAMPLE
 > Get-OpenStackNetworks -Account your_account_name

 Id                                    Cidr                Label             ExtensionData
--                                     ----                -----             -------------
98765432-1111-2121-abcd-212312121212   192.168.100.0/23    RC-CLOUD-DMZ-V3   {}
00000000-0000-0000-0000-000000000000                       public            {}
11111111-1111-1111-1111-111111111111                       private           {}


 .LINK
 http://docs.rackspace.com/servers/api/v2/cs-gettingstarted/content/summary_networks.html

#>
}


# Get one network with id
function Get-OpenStackNetwork {
    
        Param(
        [Parameter (Mandatory=$True)] [string] $Account = $(throw "Please specify required OpenStack Account with -Account parameter"),
        [Parameter (Mandatory=$True)][string] $NetworkId = $(throw "Please specify required OpenStack Network ID with -NetworkId parameter"),
        [Parameter (Mandatory=$False)][string] $RegionOverride
    )

    $OpenStackNetworkProvider = Get-OpenStackNetworkProvider -Account $Account

    if ($RegionOverride){
        $Global:RegionOverride = $RegionOverride
    }

    # Use Region code associated with Account, or was an override provided?
    if ($RegionOverride) {
        $Region = $Global:RegionOverride
    } else {
        $Region = $Credentials.Region
    }

    # DEBUGGING             
    Write-Debug -Message "Account.: $Account"
    Write-Debug -Message "NetworkId.: $NetworkId"
    Write-Debug -Message "Region..: $Region"


    # Get network
    $OpenStackNetworkProvider.ShowNetwork($NetworkId, $Region)

<#
 .SYNOPSIS
 The Get-OpenStackNetwork cmdlet let you fetch information of one network with ID.

 .DESCRIPTION
 This command is executed against provided region with network ID.

 .PARAMETER Account
 Use this parameter to indicate which account you would like to execute this request against. 
 Valid choices are defined in PoshStack configuration file.

 .PARAMETER NetworkId
 Use this parameter to identify network be fetched

 .PARAMETER RegionOverride
 This parameter will temporarily override the default region set in PoshStack configuration file. 

 .EXAMPLE
 > Get-OpenStackNetwork -Account your_account_name -NetworkId "98765432-1111-2121-abcd-212312121212"

 Id                                    Cidr                Label             ExtensionData
--                                     ----                -----             -------------
98765432-1111-2121-abcd-212312121212   192.168.100.0/23    RC-CLOUD-DMZ-V3   {}


 .LINK
 http://docs.rackspace.com/servers/api/v2/cs-gettingstarted/content/summary_networks.html

#>
}



# Create new network
function New-OpenStackNetwork {
    
        Param(
        [Parameter (Mandatory=$True)] [string] $Account = $(throw "Please specify required OpenStack Account with -Account parameter"),
        [Parameter (Mandatory=$True)] [string] $CIDR = $(throw "Please specify required CIDR with -CIDR parameter"),
        [Parameter (Mandatory=$True)] [string] $Label = $(throw "Please specify required name with -Label parameter"),
        [Parameter (Mandatory=$False)] [string] $RegionOverride
    )

    Show-UntestedWarning

    $OpenStackNetworkProvider = Get-OpenStackNetworkProvider -Account $Account

    if ($RegionOverride){
        $Global:RegionOverride = $RegionOverride
    }

    # Use Region code associated with Account, or was an override provided?
    if ($RegionOverride) {
        $Region = $Global:RegionOverride
    } else {
        $Region = $Credentials.Region
    }

    # DEBUGGING             
    Write-Debug -Message "Account.: $Account"
    Write-Debug -Message "CIDR..: $CIDR"
    Write-Debug -Message "Label..: $Label"
    Write-Debug -Message "Region..: $Region"

    # Get the list of servers
    $OpenStackNetworkProvider.CreateNetwork($CIDR, $Label, $Region)

<#
 .SYNOPSIS
 The New-OpenStackNetwork cmdlet will let you create new cloud network.

 .DESCRIPTION
 This command is creating new cloud network with provided CIDR and label (name).

 .PARAMETER Account
 Use this parameter to indicate which account you would like to execute this request against. 
 Valid choices are defined in PoshStack configuration file.

 .PARAMETER CIDR
 Classless Inter-Domain Routing (CIDR). A method for allocating IP addresses and routing Internet Protocol packets. Used with Cloud Networks.
 Example: 192.168.0.0/24

 .PARAMETER Label
 Label is used as a network name

 .PARAMETER RegionOverride
 This parameter will temporarily override the default region set in PoshStack configuration file. 

 .EXAMPLE
 > Get-OpenStackNetworks -Account your_account_name -

 .LINK
 http://docs.rackspace.com/servers/api/v2/cs-gettingstarted/content/summary_networks.html

#>
}



# Remove network with id
function Remove-OpenStackNetwork {
    
        Param(
        [Parameter (Mandatory=$True)] [string] $Account = $(throw "Please specify required OpenStack Account with -Account parameter"),
        [Parameter (Mandatory=$True)][string] $NetworkId = $(throw "Please specify required OpenStack Network ID with -NetworkId parameter"),
        [Parameter (Mandatory=$False)][string] $RegionOverride
    )

    Show-UntestedWarning

    $OpenStackNetworkProvider = Get-OpenStackNetworkProvider -Account $Account

    if ($RegionOverride){
        $Global:RegionOverride = $RegionOverride
    }

    # Use Region code associated with Account, or was an override provided?
    if ($RegionOverride) {
        $Region = $Global:RegionOverride
    } else {
        $Region = $Credentials.Region
    }

    # DEBUGGING             
    Write-Debug -Message "Account.: $Account"
    Write-Debug -Message "NetworkId.: $NetworkId"
    Write-Debug -Message "Region..: $Region"


    # Get network
    $OpenStackNetworkProvider.DeleteNetwork($NetworkId, $Region)

<#
 .SYNOPSIS
 The Remove-OpenStackNetwork cmdlet let you delete network with ID.

 .DESCRIPTION
 This command is executed against provided region with network ID.

 .PARAMETER Account
 Use this parameter to indicate which account you would like to execute this request against. 
 Valid choices are defined in PoshStack configuration file.

 .PARAMETER NetworkId
 Use this parameter to identify network to be removed

 .PARAMETER RegionOverride
 This parameter will temporarily override the default region set in PoshStack configuration file. 

 .EXAMPLE
 > Remove-OpenStackNetwork -Account your_account_name -NetworkId "98765432-1111-2121-abcd-212312121212"


 .LINK
 http://docs.rackspace.com/servers/api/v2/cs-gettingstarted/content/summary_networks.html

#>
}