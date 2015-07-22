# Getting Started with PoshStack
## 1. PoshStack Configuration

PoshStack allows you to configure several accounts from which you can choose during runtime. For example, you may have
an account that has "IAD" as it's default region, whereas a different account may have "DFW" as it's default region.

To configure the accounts, you must edit the file "CloudAccounts.csv" in the PoshStack folder. It's a comma-separated
values file that contains your user name, API key and tenant id, as well as other information.

You will give the accounts a name, and use that name in your PoshStack cmdlets. For example, if
you have an account named "demo", you would use the -Account parameter as follows:

```PowerShell
-Account demo
```



## 2. How to create a Virtual Machine using PoshStack

Once you've installed PoshStack on your system, you need to reference it using the following Powershell command:

```PowerShell
Import-Module PoshStack
```

Once you've done that, you're ready to use PoshStack. Creating a virtual machine, also
know has "spinning up a server", is as simple as using the New-OpenStackComputeServer cmdlet:

```PowerShell
New-OpenStackComputeServer -Account demo -ServerName MyNewServer -ImageId d69d55ef-cb4c-4787-9f1b-2de41ecac9a1 -FlavorId Performance1-2 -AttachToServiceNetwork $true -AttachToPublicNetwork $true
```

Rather than explain this command here, use the following cmdlet in Powershell to get more information about New-ComputeServer:

```PowerShell
Get-Help New-OpenStackComputeServer -Full
```


## 3. How to use Containers using PoshStack
Cloud Object Storage Containers allow you to store and retrieve objects in the cloud.

### Creating a Cloud Object Storage Container
You can create a Cloud Object Storage Container using the New-OpenStackObjectStorageContainer cmdlet. The only required information is the PoshStack account name and the name of the container:
```PowerShell
New-OpenStackObjectStorageContainer -Account demo -ContainerName MyNewContainer
```

### Uploading an Object to a Container
Objects are uploaded to a container using the Add-OpenStackObjectStorageObjectFromFile cmdlet:
```PowerShell
Add-OpenStackObjectStorageObjectFromFile -Account demo -FilePath C:\temp\kittens.jpg -ContainerName MyNewContainer
```

### Downloading an Object from a Container
Objects are downloaded from a container using the Copy-OpenStackObjectStorageObject cmdlet:
```Powershell
Copy-OpenStackObjectStorageObject -Account demo -ContainerName MyNewContainer -Object kittens.jpg
```
