Clear 
Remove-Module PoshStack
Import-Module PoshStack
Get-OpenStackComputeServerFlavor -Account rackiad -details   #| ConvertTo-Html | Out-File C:\Temp\get_cloudserverflavor.html
#Invoke-Expression C:\Temp\get_cloudserverflavor.html
#Get-OpenStackComputeServerImage -Account rackiad -Verbose