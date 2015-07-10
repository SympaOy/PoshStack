<############################################################################################

PoshStack
Load Balancers

    
Description
-----------
**TODO**

############################################################################################>

function Get-OpenStackLBProvider {
    Param(
        [Parameter (Mandatory=$True)] [string] $Account = $(throw "Please specify required Cloud Account by using the -Account parameter"),
        [Parameter (Mandatory=$false)] [string] $RegionOverride = $null
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
            Return New-Object net.openstack.Providers.Rackspace.CloudLoadBalancerProvider($cloudId, $Region, $null)

        }
        "OpenStack" {
            $CloudIdentityWithProject = New-Object net.openstack.Core.Domain.CloudIdentityWithProject
            $CloudIdentityWithProject.Password = $Credentials.CloudPassword
            $CloudIdentityWithProject.Username = $Credentials.CloudUsername
            $CloudIdentityWithProject.ProjectId = New-Object net.openstack.Core.Domain.ProjectId($Credentials.TenantId)
            $CloudIdentityWithProject.ProjectName = $Credentials.TenantId
            $Uri = New-Object System.Uri($Credentials.IdentityEndpointUri)
            $OpenStackIdentityProvider = New-Object net.openstack.Core.Providers.OpenStackIdentityProvider($Uri, $CloudIdentityWithProject)
            Return New-Object net.openstack.Providers.Rackspace.CloudLoadBalancerProvider($null, $Region, $OpenStackIdentityProvider)
        }
    }
}

# Issue 49 Implement Add-CloudLoadBalancerMetadata
function Add-OpenStackLBMetadata {
    Param(
        [Parameter (Mandatory=$True)] [string] $Account = $(throw "Please specify required Cloud Account by using the -Account parameter"),
        [Parameter (Mandatory=$True)] [net.openstack.Providers.Rackspace.Objects.LoadBalancers.LoadBalancerId] $LBID = $(throw "Please specify the required Load Balancer ID by using the -LBID parameter"),
        [Parameter (Mandatory=$True)] [string[]] $Metadata = $(throw "Please specify the required metadata by using the -Metadata parameter"),
        [Parameter (Mandatory=$False)][bool]   $WaitForTask = $False,
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


    $LBProvider = Get-OpenStackLBProvider -Account rackiad -RegionOverride $Region

    try {

        # DEBUGGING       
        Write-Debug -Message "Add-OpenStackLBMetadata"
        Write-Debug -Message "Account.........................: $Account" 
        Write-Debug -Message "LBID............................: $LBID"
        Write-Debug -Message "Metaadata.......................: $Metadata"
        Write-Debug -Message "WaitForTask.....................: $WaitForTask" 
        Write-Debug -Message "Region..........................: $Region" 

        $CancellationToken = New-Object ([System.Threading.CancellationToken]::None)

        if($WaitForTask) {
            $LBProvider.AddLoadBalancerMetadataAsync($LBID, $Metadata, [net.openstack.Core.AsyncCompletionOption]::RequestCompleted, $CancellationToken, $null).Result
        } else {
            $LBProvider.AddLoadBalancerMetadataAsync($LBID, $Metadata, [net.openstack.Core.AsyncCompletionOption]::RequestSubmitted, $CancellationToken, $null).Result
        }

    }
    catch {
        Invoke-Exception($_.Exception)
    }
<#
 .SYNOPSIS
 Add metadata

 .DESCRIPTION
 The Add-OpenStackLBMetadata cmdlet will add metadata to an existing Load Balancer.
 
 .PARAMETER Account
 Use this parameter to indicate which account you would like to execute this request against.
 Valid choices are defined in PoshStack configuration file.

 .PARAMETER LBID
 An object of type net.openstack.Providers.Rackspace.Objects.LoadBalancers.LoadBalancerID that identifies the existing Load Balancer.
 
 .PARAMETER Metadata
 An array of key-value pairs containing the metadata.

 .PARAMETER WaitForTask
 Use this parameter to specify whether you want to wait for the task to complete or return control to the script immediately.

  .PARAMETER RegionOverride
 This parameter will temporarily override the default region set in PoshStack configuration file.

 .EXAMPLE
 PS C:\Users\Administrator>


 .LINK
 http://api.rackspace.com/api-ref-load-balancers.html
#>
}

# Issue 50 Implement Add-CloudLoadBalancerNode
function Add-OpenStackLBNode {
    Param(
        [Parameter (Mandatory=$True)] [string] $Account = $(throw "Please specify required Cloud Account by using the -Account parameter"),
        [Parameter (Mandatory=$True)] [net.openstack.Providers.Rackspace.Objects.LoadBalancers.LoadBalancerId] $LBID = $(throw "Please specify the required Load Balancer ID by using the -LBID parameter"),
        [Parameter (Mandatory=$True)] [net.openstack.Providers.Rackspace.Objects.LoadBalancers.NodeConfiguration] $NodeConfig = $(throw "Please specify the required Node Configuration by using the -NodeConfig parameter"),
        [Parameter (Mandatory=$False)][bool]   $WaitForTask = $False,
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


    $LBProvider = Get-OpenStackLBProvider -Account rackiad -RegionOverride $Region

    try {

        # DEBUGGING       
        Write-Debug -Message "Add-OpenStackLBNode"
        Write-Debug -Message "Account.........................: $Account" 
        Write-Debug -Message "LBID............................: $LBID"
        Write-Debug -Message "NodeConfig......................: $NodeConfig"
        Write-Debug -Message "WaitForTask.....................: $WaitForTask" 
        Write-Debug -Message "Region..........................: $Region" 

        $CancellationToken = New-Object ([System.Threading.CancellationToken]::None)

        if($WaitForTask) {
            $LBProvider.AddNodeAsync($LBID, $NodeConfig, [net.openstack.Core.AsyncCompletionOption]::RequestCompleted, $CancellationToken, $null).Result
        } else {
            $LBProvider.AddNodeAsync($LBID, $NodeConfig, [net.openstack.Core.AsyncCompletionOption]::RequestSubmitted, $CancellationToken, $null).Result
        }

    }
    catch {
        Invoke-Exception($_.Exception)
    }
<#
 .SYNOPSIS
 Add LB Node

 .DESCRIPTION
 The Add-OpenStackLBNode cmdlet will add a Node to an existing Load Balancer.
 
 .PARAMETER Account
 Use this parameter to indicate which account you would like to execute this request against.
 Valid choices are defined in PoshStack configuration file.

 .PARAMETER LBID
 An object of type net.openstack.Providers.Rackspace.Objects.LoadBalancers.LoadBalancerID that identifies the existing Load Balancer.
 
 .PARAMETER NodeConfig
 An object of type net.openstack.Providers.Rackspace.Objects.LoadBalancers.NodeConfiguration that contains configuration data for new new Node.

 .PARAMETER WaitForTask
 Use this parameter to specify whether you want to wait for the task to complete or return control to the script immediately.

  .PARAMETER RegionOverride
 This parameter will temporarily override the default region set in PoshStack configuration file.

 .EXAMPLE
 PS C:\Users\Administrator>


 .LINK
 http://api.rackspace.com/api-ref-load-balancers.html
#>
}

# Issue 51 Implement Add-CloudLoadBalancerNodeMetadata
function Add-OpenStackLBNodeMetadata {
    Param(
        [Parameter (Mandatory=$True)] [string] $Account = $(throw "Please specify required Cloud Account by using the -Account parameter"),
        [Parameter (Mandatory=$True)] [net.openstack.Providers.Rackspace.Objects.LoadBalancers.LoadBalancerId] $LBID = $(throw "Please specify the required Load Balancer ID by using the -LBID parameter"),
        [Parameter (Mandatory=$True)] [net.openstack.Providers.Rackspace.Objects.LoadBalancers.NodeId] $NodeID = $(throw "Please specify the required Node ID by using the -NodeID parameter"),
        [Parameter (Mandatory=$True)] [string[]] $Metadata = $(throw "Please specify the required metadata by using the -Metadata parameter"),
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


    $LBProvider = Get-OpenStackLBProvider -Account rackiad -RegionOverride $Region

    try {

        # DEBUGGING       
        Write-Debug -Message "New-OpenStackLBNodeMetadatda"
        Write-Debug -Message "Account.........................: $Account" 
        Write-Debug -Message "LBID............................: $LBID"
        Write-Debug -Message "NodeID..........................: $NodeID"
        Write-Debug -Message "Metadata........................: $Metadata"
        Write-Debug -Message "WaitForTask.....................: $WaitForTask" 
        Write-Debug -Message "Region..........................: $Region" 

        $CancellationToken = New-Object ([System.Threading.CancellationToken]::None)

        if($WaitForTask) {
            $LBProvider.AddNodeMetadataAsync($LBID, $NodeID, $Metadata, [net.openstack.Core.AsyncCompletionOption]::RequestCompleted, $CancellationToken, $null).Result
        } else {
            $LBProvider.AddNodeMetadataAsync($LBID, $NodeID, $Metadata, [net.openstack.Core.AsyncCompletionOption]::RequestSubmitted, $CancellationToken, $null).Result
        }

    }
    catch {
        Invoke-Exception($_.Exception)
    }
<#
 .SYNOPSIS
 Add metadata to node

 .DESCRIPTION
 The New-OpenStackLBNodeMetadata cmdlet will add metadata to an existing Load Balancer Node.
 
 .PARAMETER Account
 Use this parameter to indicate which account you would like to execute this request against.
 Valid choices are defined in PoshStack configuration file.

 .PARAMETER LBID
 An object of type net.openstack.Providers.Rackspace.Objects.LoadBalancers.LoadBalancerId that identifies the Load Balancer.

 .PARAMETER NodeID
 An object of type net.openstack.Providers.Rackspace.Objects.LoadBalancers.NodeId that identifies the Node.

 .PARAMETER Metadata
 An array of key-value pairs that contains the metadata.
 
 .PARAMETER WaitForTask
 Use this parameter to specify whether you want to wait for the task to complete or return control to the script immediately.

  .PARAMETER RegionOverride
 This parameter will temporarily override the default region set in PoshStack configuration file.

 .EXAMPLE
 PS C:\Users\Administrator>


 .LINK
 http://api.rackspace.com/api-ref-load-balancers.html
#>
}

# Issue 52 Implement Add-CloudLoadBalancerNodeRange
function Add-OpenStackLBNodeRange {
    Param(
        [Parameter (Mandatory=$True)] [string] $Account = $(throw "Please specify required Cloud Account by using the -Account parameter"),
        [Parameter (Mandatory=$True)] [net.openstack.Providers.Rackspace.Objects.LoadBalancers.LoadBalancerId] $LBID = $(throw "Please specify the required Load Balancer ID by using the -LBID parameter"),
        [Parameter (Mandatory=$True)] [net.openstack.Providers.Rackspace.Objects.LoadBalancers.NodeConfiguration[]] $NodeConfigurations = $(throw "Please specify the required Node Configurations by using the -NodeConfigurations parameter"),
        [Parameter (Mandatory=$False)][bool]   $WaitForTask = $False,
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


    $LBProvider = Get-OpenStackLBProvider -Account rackiad -RegionOverride $Region

    try {

        # DEBUGGING       
        Write-Debug -Message "Add-OpenStackLBNodeRange"
        Write-Debug -Message "Account.........................: $Account" 
        Write-Debug -Message "LBID............................: $LBID"
        Write-Debug -Message "NodeConfigurations..............: $NodeConfigurations"
        Write-Debug -Message "WaitForTask.....................: $WaitForTask" 
        Write-Debug -Message "Region..........................: $Region" 

        $CancellationToken = New-Object ([System.Threading.CancellationToken]::None)

        if($WaitForTask) {
            $LBProvider.AddNodeRangeAsync($LBID, $NodeConfigurations, [net.openstack.Core.AsyncCompletionOption]::RequestCompleted, $CancellationToken, $null).Result
        } else {
            $LBProvider.AddNodeRangeAsync($LBID, $NodeConfigurations, [net.openstack.Core.AsyncCompletionOption]::RequestSubmitted, $CancellationToken, $null).Result
        }

    }
    catch {
        Invoke-Exception($_.Exception)
    }
<#
 .SYNOPSIS
 Add node range

 .DESCRIPTION
 The Add-OpenStackLBNodeRange cmdlet will add one or more nodes to a load balancer.
 
 .PARAMETER Account
 Use this parameter to indicate which account you would like to execute this request against.
 Valid choices are defined in PoshStack configuration file.

 .PARAMETER LBID
 An object of type net.openstack.Providers.Rackspace.Objects.LoadBalancers.LoadBalancerId that identifies the Load Balancer.

 .PARAMETER NodeConfigurations
 An array of objects of type net.openstack.Providers.Rackspace.Objects.LoadBalancers.NodeConfiguration containing the nodes to be added.
 
 .PARAMETER WaitForTask
 Use this parameter to specify whether you want to wait for the task to complete or return control to the script immediately.

  .PARAMETER RegionOverride
 This parameter will temporarily override the default region set in PoshStack configuration file.

 .EXAMPLE
 PS C:\Users\Administrator>


 .LINK
 http://api.rackspace.com/api-ref-load-balancers.html
#>
}

# Issue 53 Implement Add-CloudLoadBalancerVirtualAddress
function Add-OpenStackLBVirtualAddress {
    Param(
        [Parameter (Mandatory=$True)] [string] $Account = $(throw "Please specify required Cloud Account by using the -Account parameter"),
        [Parameter (Mandatory=$True)] [net.openstack.Providers.Rackspace.Objects.LoadBalancers.LoadBalancerId] $LBID = $(throw "Please specify the required Load Balancer ID by using the -LBID parameter"),
        [Parameter (Mandatory=$True)] [net.openstack.Providers.Rackspace.Objects.LoadBalancers.LoadBalancerVirtualAddressType] $LBVirtAddrType = $(throw "Please specify the required Load Balancer Virtual Address Type to using the -LBVirtAddrType parameter"),
        [Parameter (Mandatory=$True)] [System.Net.Sockets.AddressFamily] $AddressFamily = $(throw "Please specify the required Address Family by using the required -AddressFamily parameter"),
        [Parameter (Mandatory=$False)][bool]   $WaitForTask = $False,
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


    $LBProvider = Get-OpenStackLBProvider -Account rackiad -RegionOverride $Region

    try {

        # DEBUGGING       
        Write-Debug -Message "Add-OpenStackLBVirtualAddress"
        Write-Debug -Message "Account.........................: $Account" 
        Write-Debug -Message "LBID............................: $LBID"
        Write-Debug -Message "LBVirtAddrType..................: $LBVirtAddrType"
        Write-Debug -Message "AddressType.....................: $AddressType"
        Write-Debug -Message "WaitForTask.....................: $WaitForTask" 
        Write-Debug -Message "Region..........................: $Region" 

        $CancellationToken = New-Object ([System.Threading.CancellationToken]::None)

        if($WaitForTask) {
            $LBProvider.AddVirtualAddressAsync($LBID, $LBVirtAddrType, $AddressFamily, [net.openstack.Core.AsyncCompletionOption]::RequestCompleted, $CancellationToken, $null).Result
        } else {
            $LBProvider.AddVirtualAddressAsync($LBID, $LBVirtAddrType, $AddressFamily, [net.openstack.Core.AsyncCompletionOption]::RequestSubmitted, $CancellationToken, $null).Result
        }

    }
    catch {
        Invoke-Exception($_.Exception)
    }
<#
 .SYNOPSIS
 Create Load Balancer

 .DESCRIPTION
 The New-OpenStackLoadBalancer cmdlet will create a new load balancer.
 
 .PARAMETER Account
 Use this parameter to indicate which account you would like to execute this request against.
 Valid choices are defined in PoshStack configuration file.

 .PARAMETER LBConfig
 An object of type net.openstack.Providers.Rackspace.Objects.LoadBalancers.LoadBalancerConfiguration that describes the new Load Balancer.
 
 .PARAMETER WaitForTask
 Use this parameter to specify whether you want to wait for the task to complete or return control to the script immediately.

  .PARAMETER RegionOverride
 This parameter will temporarily override the default region set in PoshStack configuration file.

 .EXAMPLE
 PS C:\Users\Administrator>


 .LINK
 http://api.rackspace.com/api-ref-load-balancers.html
#>
}

# Issue 55 Implement New-CloudLoadBalancer
function New-OpenStackLoadBalancer {
    Param(
        [Parameter (Mandatory=$True)] [string] $Account = $(throw "Please specify required Cloud Account by using the -Account parameter"),
        [Parameter (Mandatory=$True)] [net.openstack.Providers.Rackspace.Objects.LoadBalancers.LoadBalancerConfiguration] $LBConfig = $(throw "Please specify the required Load Balancer Configuration by using the -LBConfig parameter"),
        [Parameter (Mandatory=$False)][bool]   $WaitForTask = $False,
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


    $LBProvider = Get-OpenStackLBProvider -Account rackiad -RegionOverride $Region

    try {

        # DEBUGGING       
        Write-Debug -Message "New-OpenStackLoadBalancer"
        Write-Debug -Message "Account.........................: $Account" 
        Write-Debug -Message "LBConfig........................: $LBConfig"
        Write-Debug -Message "WaitForTask.....................: $WaitForTask" 
        Write-Debug -Message "Region..........................: $Region" 

        $CancellationToken = New-Object ([System.Threading.CancellationToken]::None)

        if($WaitForTask) {
            $LBProvider.CreateLoadBalancerAsync($LBConfig, [net.openstack.Core.AsyncCompletionOption]::RequestCompleted, $CancellationToken, $null).Result
        } else {
            $LBProvider.CreateLoadBalancerAsync($LBConfig, [net.openstack.Core.AsyncCompletionOption]::RequestSubmitted, $CancellationToken, $null).Result
        }

    }
    catch {
        Invoke-Exception($_.Exception)
    }
<#
 .SYNOPSIS
 Create Load Balancer

 .DESCRIPTION
 The New-OpenStackLoadBalancer cmdlet will create a new load balancer.
 
 .PARAMETER Account
 Use this parameter to indicate which account you would like to execute this request against.
 Valid choices are defined in PoshStack configuration file.

 .PARAMETER LBConfig
 An object of type net.openstack.Providers.Rackspace.Objects.LoadBalancers.LoadBalancerConfiguration that describes the new Load Balancer.
 
 .PARAMETER WaitForTask
 Use this parameter to specify whether you want to wait for the task to complete or return control to the script immediately.

  .PARAMETER RegionOverride
 This parameter will temporarily override the default region set in PoshStack configuration file.

 .EXAMPLE
 PS C:\Users\Administrator>


 .LINK
 http://api.rackspace.com/api-ref-load-balancers.html
#>
}

# Issue 56 Implement Get-CloudLoadBalancerConnectionLogging
function Get-OpenStackLBConnectionLogging {
    Param(
        [Parameter (Mandatory=$True)] [string] $Account = $(throw "Please specify required Cloud Account by using the -Account parameter"),
        [Parameter (Mandatory=$True)] [net.openstack.Providers.Rackspace.Objects.LoadBalancers.LoadBalancerId] $LBID = $(throw "Please specify the required Load Balancer ID by using the -LBID parameter"),
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


    $LBProvider = Get-OpenStackLBProvider -Account rackiad -RegionOverride $Region

    try {

        # DEBUGGING       
        Write-Debug -Message "Get-OpenStackLBConnectionLogging"
        Write-Debug -Message "Account.........................: $Account" 
        Write-Debug -Message "LBID............................: $LBID"
        Write-Debug -Message "Region..........................: $Region" 

        $CancellationToken = New-Object ([System.Threading.CancellationToken]::None)

        $LBProvider.GetConnectionLoggingAsync($LBID, $CancellationToken).Result

    }
    catch {
        Invoke-Exception($_.Exception)
    }
<#
 .SYNOPSIS
 Get logging status

 .DESCRIPTION
 The Get-OpenStackLBConnectionLogging cmdlet will allow you to query to see if the Load Balancer has connection logging enabled.
 
 .PARAMETER Account
 Use this parameter to indicate which account you would like to execute this request against.
 Valid choices are defined in PoshStack configuration file.

 .PARAMETER LBID
 An object of type net.openstack.Providers.Rackspace.Objects.LoadBalancers.LoadBalancerID that identifies the Load Balancer.
 
  .PARAMETER RegionOverride
 This parameter will temporarily override the default region set in PoshStack configuration file.

 .EXAMPLE
 PS C:\Users\Administrator>


 .LINK
 http://api.rackspace.com/api-ref-load-balancers.html
#>
}

# Issue 57 Implement Get-CloudLoadBalancerContentCaching
function Get-OpenStackLBContentCaching {
    Param(
        [Parameter (Mandatory=$True)] [string] $Account = $(throw "Please specify required Cloud Account by using the -Account parameter"),
        [Parameter (Mandatory=$True)] [net.openstack.Providers.Rackspace.Objects.LoadBalancers.LoadBalancerId] $LBID = $(throw "Please specify the required Load Balancer ID by using the -LBID parameter"),
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


    $LBProvider = Get-OpenStackLBProvider -Account rackiad -RegionOverride $Region

    try {

        # DEBUGGING       
        Write-Debug -Message "Get-OpenStackLBContentCaching"
        Write-Debug -Message "Account.........................: $Account" 
        Write-Debug -Message "LBID............................: $LBID"
        Write-Debug -Message "Region..........................: $Region" 

        $CancellationToken = New-Object ([System.Threading.CancellationToken]::None)

        $LBProvider.GetContentCachingAsync($LBID, $CancellationToken).Result

    }
    catch {
        Invoke-Exception($_.Exception)
    }
<#
 .SYNOPSIS
 Get content caching status

 .DESCRIPTION
 The Get-OpenStackLBContentCaching cmdlet will allow you to query to see if the Load Balancer has content caching enabled.
 
 .PARAMETER Account
 Use this parameter to indicate which account you would like to execute this request against.
 Valid choices are defined in PoshStack configuration file.

 .PARAMETER LBID
 An object of type net.openstack.Providers.Rackspace.Objects.LoadBalancers.LoadBalancerID that identifies the Load Balancer.
 
  .PARAMETER RegionOverride
 This parameter will temporarily override the default region set in PoshStack configuration file.

 .EXAMPLE
 PS C:\Users\Administrator>


 .LINK
 http://api.rackspace.com/api-ref-load-balancers.html
#>
}

# Issue 58 Implement Get-CloudLoadBalancerErrorPage
function Get-OpenStackLBErrorPage {
    Param(
        [Parameter (Mandatory=$True)] [string] $Account = $(throw "Please specify required Cloud Account by using the -Account parameter"),
        [Parameter (Mandatory=$True)] [net.openstack.Providers.Rackspace.Objects.LoadBalancers.LoadBalancerId] $LBID = $(throw "Please specify the required Load Balancer ID by using the -LBID parameter"),
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


    $LBProvider = Get-OpenStackLBProvider -Account rackiad -RegionOverride $Region

    try {

        # DEBUGGING       
        Write-Debug -Message "Get-OpenStackLBErrorPage"
        Write-Debug -Message "Account.........................: $Account" 
        Write-Debug -Message "LBID............................: $LBID"
        Write-Debug -Message "Region..........................: $Region" 

        $CancellationToken = New-Object ([System.Threading.CancellationToken]::None)

        $LBProvider.GetErrorPageAsync($LBID, $CancellationToken).Result

    }
    catch {
        Invoke-Exception($_.Exception)
    }
<#
 .SYNOPSIS
 Get error page

 .DESCRIPTION
 The Get-OpenStackLBErrorPage cmdlet gets the HTML content of the page which is shown to an end user who is attempting to access a load balancer node that is offline or unavailable.
 
 .PARAMETER Account
 Use this parameter to indicate which account you would like to execute this request against.
 Valid choices are defined in PoshStack configuration file.

 .PARAMETER LBID
 An object of type net.openstack.Providers.Rackspace.Objects.LoadBalancers.LoadBalancerID that identifies the Load Balancer.
 
  .PARAMETER RegionOverride
 This parameter will temporarily override the default region set in PoshStack configuration file.

 .EXAMPLE
 PS C:\Users\Administrator>


 .LINK
 http://api.rackspace.com/api-ref-load-balancers.html
#>
}

# Issue 59 Implement Get-CloudLoadBalancerHealthMonitor
function Get-OpenStackLBHealthMonitor {
    Param(
        [Parameter (Mandatory=$True)] [string] $Account = $(throw "Please specify required Cloud Account by using the -Account parameter"),
        [Parameter (Mandatory=$True)] [net.openstack.Providers.Rackspace.Objects.LoadBalancers.LoadBalancerId] $LBID = $(throw "Please specify the required Load Balancer ID by using the -LBID parameter"),
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


    $LBProvider = Get-OpenStackLBProvider -Account rackiad -RegionOverride $Region

    try {

        # DEBUGGING       
        Write-Debug -Message "c"
        Write-Debug -Message "Account.........................: $Account" 
        Write-Debug -Message "LBID............................: $LBID"
        Write-Debug -Message "Region..........................: $Region" 

        $CancellationToken = New-Object ([System.Threading.CancellationToken]::None)

        $LBProvider.GetHealthMonitorAsync($LBID, $CancellationToken).Result

    }
    catch {
        Invoke-Exception($_.Exception)
    }
<#
 .SYNOPSIS
 Get health monitor

 .DESCRIPTION
 The GetHealthMonitorAsync cmdlet gets the health monitor currently configured for a load balancer.
 
 .PARAMETER Account
 Use this parameter to indicate which account you would like to execute this request against.
 Valid choices are defined in PoshStack configuration file.

 .PARAMETER LBID
 An object of type net.openstack.Providers.Rackspace.Objects.LoadBalancers.LoadBalancerID that identifies the Load Balancer.
 
  .PARAMETER RegionOverride
 This parameter will temporarily override the default region set in PoshStack configuration file.

 .EXAMPLE
 PS C:\Users\Administrator>


 .LINK
 http://api.rackspace.com/api-ref-load-balancers.html
#>

}

# Issue 60 Implement Get-CloudLoadBalancer
# Issue 75 Implement Get-CloudLoadBalancers
function Get-OpenStackLoadBalancer {
    Param(
        [Parameter (Mandatory=$True)] [string] $Account = $(throw "Please specify required Cloud Account by using the -Account parameter"),
        [Parameter (Mandatory=$False)][net.openstack.Providers.Rackspace.Objects.LoadBalancers.LoadBalancerId] $LBID = $null,
        [Parameter (Mandatory=$False)][net.openstack.Providers.Rackspace.Objects.LoadBalancers.LoadBalancerId] $Marker = $null,
        [Parameter (Mandatory=$False)][int]    $Limit = 100,
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


    $LBProvider = Get-OpenStackLBProvider -Account rackiad -RegionOverride $Region

    try {

        # DEBUGGING       
        Write-Debug -Message "Get-OpenStackLoadBalancer"
        Write-Debug -Message "Account.........................: $Account" 
        Write-Debug -Message "LBID............................: $LBID"
        Write-Debug -Message "Marker..........................: $Marker"
        Write-Debug -Message "Limit...........................: $Limit"
        Write-Debug -Message "WaitForTask.....................: $WaitForTask" 
        Write-Debug -Message "Region..........................: $Region" 

        $CancellationToken = New-Object ([System.Threading.CancellationToken]::None)

        IF([string]::IsNullOrEmpty($LBID)) {    
            $LBProvider.ListLoadBalancersAsync($Marker, $Limit, $CancellationToken).Result
        } else {
            $LBProvider.GetLoadBalancerAsync($LBID, $CancellationToken).Result
        }

    }
    catch {
        Invoke-Exception($_.Exception)
    }
<#
 .SYNOPSIS
 Create Load Balancer

 .DESCRIPTION
 The New-OpenStackLoadBalancer cmdlet will create a new load balancer.
 
 .PARAMETER Account
 Use this parameter to indicate which account you would like to execute this request against.
 Valid choices are defined in PoshStack configuration file.

 .PARAMETER LBConfig
 An object of type net.openstack.Providers.Rackspace.Objects.LoadBalancers.LoadBalancerConfiguration that describes the new Load Balancer.
 
 .PARAMETER WaitForTask
 Use this parameter to specify whether you want to wait for the task to complete or return control to the script immediately.

  .PARAMETER RegionOverride
 This parameter will temporarily override the default region set in PoshStack configuration file.

 .EXAMPLE
 PS C:\Users\Administrator>


 .LINK
 http://api.rackspace.com/api-ref-load-balancers.html
#>
}

# Issue 62 Implement Get-CloudLoadBalancerNode
function Get-OpenStackLBNode {
    Param(
        [Parameter (Mandatory=$True)] [string] $Account = $(throw "Please specify required Cloud Account by using the -Account parameter"),
        [Parameter (Mandatory=$True)] [net.openstack.Providers.Rackspace.Objects.LoadBalancers.LoadBalancerId] $LBID = $(throw "Please specify the required Load Balancer ID by using the -LBID parameter"),
        [Parameter (Mandatory=$False)][net.openstack.Providers.Rackspace.Objects.LoadBalancers.NodeID] $NodeID = $null,
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


    $LBProvider = Get-OpenStackLBProvider -Account rackiad -RegionOverride $Region

    try {

        # DEBUGGING       
        Write-Debug -Message "Get-OpenStackLBNode"
        Write-Debug -Message "Account.........................: $Account" 
        Write-Debug -Message "LBID............................: $LBID"
        Write-Debug -Message "NodeID..........................: $NodeID"
        Write-Debug -Message "Region..........................: $Region" 

        $CancellationToken = New-Object ([System.Threading.CancellationToken]::None)

        IF([string]::IsNullOrEmpty($NodeID)) {    
            $LBProvider.ListNodesAsync($LBID, $CancellationToken).Result
        } else {
            $LBProvider.GetNodeAsync($LBID, $NodeID, $CancellationToken).Result
        }

    }
    catch {
        Invoke-Exception($_.Exception)
    }
<#
 .SYNOPSIS
 Get a node

 .DESCRIPTION
 The Get-OpenStackLBNode cmdlet will create one or more Load Balancer Nodes.
 
 .PARAMETER Account
 Use this parameter to indicate which account you would like to execute this request against.
 Valid choices are defined in PoshStack configuration file.

 .PARAMETER LBID
 An object of type net.openstack.Providers.Rackspace.Objects.LoadBalancers.LoadBalancerId that identifies the Load Balancer.
 
 .PARAMETER NodeID
 An object of type net.openstack.Providers.Rackspace.Objects.LoadBalancers.NodeId that identifies a specific Load Balancer Node.

  .PARAMETER RegionOverride
 This parameter will temporarily override the default region set in PoshStack configuration file.

 .EXAMPLE
 PS C:\Users\Administrator>


 .LINK
 http://api.rackspace.com/api-ref-load-balancers.html
#>
}

# Issue 74 Implement Get-CloudLoadBalancerMetadata
function Get-OpenStackLBMetadata {
    Param(
        [Parameter (Mandatory=$True)] [string] $Account = $(throw "Please specify required Cloud Account by using the -Account parameter"),
        [Parameter (Mandatory=$True)] [net.openstack.Providers.Rackspace.Objects.LoadBalancers.LoadBalancerId] $LBID = $(throw "Please specify the required Load Balancer ID by using the -LBID parameter"),
        [Parameter (Mandatory=$False)][net.openstack.Providers.Rackspace.Objects.LoadBalancers.MetadataId] $MetadataID = $null,
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


    $LBProvider = Get-OpenStackLBProvider -Account rackiad -RegionOverride $Region

    try {

        # DEBUGGING       
        Write-Debug -Message "Get-OpenStackLBMetadata"
        Write-Debug -Message "Account.........................: $Account" 
        Write-Debug -Message "LBID............................: $LBID"
        Write-Debug -Message "MetadataID......................: $MetadataID"
        Write-Debug -Message "Region..........................: $Region" 

        $CancellationToken = New-Object ([System.Threading.CancellationToken]::None)

        IF([string]::IsNullOrEmpty($MetadataID)) {    
            $LBProvider.ListLoadBalancerMetadataAsync($LBID, $CancellationToken).Result
        } else {
            $LBProvider.GetLoadBalancerMetadataItemAsync($LBID, $MetadataID, $CancellationToken).Result
        }

    }
    catch {
        Invoke-Exception($_.Exception)
    }
<#
 .SYNOPSIS
 Get metadata.

 .DESCRIPTION
 The Get-OpenStackLBMetadata cmdlet will get metadata for a Load Balancer.
 
 .PARAMETER Account
 Use this parameter to indicate which account you would like to execute this request against.
 Valid choices are defined in PoshStack configuration file.

 .PARAMETER LBID
 An object of type net.openstack.Providers.Rackspace.Objects.LoadBalancers.LoadBalancerId that identifies the Load Balancer.
 
 .PARAMETER MetadataID
 An object of type net.openstack.Providers.Rackspace.Objects.LoadBalancers.MetadataId that identifies a specific Load Balancer metadata item.

  .PARAMETER RegionOverride
 This parameter will temporarily override the default region set in PoshStack configuration file.

 .EXAMPLE
 PS C:\Users\Administrator>


 .LINK
 http://api.rackspace.com/api-ref-load-balancers.html
#>
}

Export-ModuleMember -Function *
