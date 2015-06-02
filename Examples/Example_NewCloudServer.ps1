Clear
Remove-Module PoshStack
Import-Module PoshStack
$Servername = Read-Host 'What is the name of the server you wish to create?'
$Flavor = '5'
$Image = Get-OpenStackComputeServerImage -Account rackiad | WHERE {$_.Name -eq 'Windows Server 2012 R2'}

$meta = New-Object net.openstack.Core.Domain.Metadata
$meta.Add("first","1")
$meta.Add("second","2")
$MyNewServer = New-OpenStackComputeServer -Account rackiad -ServerName $Servername -ImageId $Image[0].Id -FlavorId $Flavor -AttachToServiceNetwork $true -AttachToPublicNetwork $true
$MyNewServer.AdminPassword