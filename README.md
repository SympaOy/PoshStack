[![Stories in Ready](https://badge.waffle.io/donschenck/poshstack.png?label=ready&title=Ready)](https://waffle.io/donschenck/poshstack)
#PoshStack

#Description
PoshStack is a Microsoft PowerShell v3 (or higher) client for OpenStack, built on the OpenStack.NET SDK v1.

The goal of this project is to give complete command line access to the OpenStack automation environment from the Windows PowerShell client, allowing Windows system administrators, DevOps engineers and developers to easily and quickly manage and automate their work.

## Installation is so easy...

### Prerequisite
PoshStack requires Windows Management Framework 3.0 (or newer).

### Installation and Configuration
Installation requires two steps: Install and Configure. PoshStack is installed using PsGet

#### Install
Open a PowerShell prompt and run the following two lines:
```bash
(new-object Net.WebClient).DownloadString("http://psget.net/GetPsGet.ps1") | Invoke-Expression
install-module PoshStack
```
#### Configure
##### Important Note: The CloudAccounts.csv file location and name is specified in the user profile, using the variable "$openstackAccounts". See the included file profile.ps1 for an example

Update the CloudAccounts.csv file with your cloud account credentials:  
  * _Type_ - Is this account targeting Rackspace, specifically, or another OpenStack provider? Valid entries are "Rackspace" or "OpenStack".
  * _AccountName_ - User-defined name for the account. This can be pretty much anything you desire, and it's only used in the context of PoshStack. For example, you may choose to name the accounts based on the default regions you assign to them. This _CloudName_ is **not** the same as your _CloudUsername_.
  * _CloudUsername_ - This is your Rackspace or Openstack user name.
  * _CloudPassword_ - This is your password. This is not used for Rackspace type accounts.
  * _CloudAPIKey_ - This is your API key. This is not used for OpenStack type accounts.
  * _IdentityEndpointUri_ - This is the endpoint. It is required for OpenStack type accounts. It is not used for Rackspace type accounts.
  * _CloudDDI_ - This is your account number.
  * _Region_ - This is your default region. Hint: For DevStack, this is "RegionOne".

You can see your cloud accounts configuration by running
```bash
Show-OpenStackAccounts
```

##### An example of the contents of CloudAccounts.csv

Type,AccountName,CloudUsername,CloudPassword,CloudAPIKey,IdentityEndpointUri,Region,TenantId
Rackspace,rackIAD,username_here,password_here,apikey_here,foo,IAD,123456
Rackspace,rackDFW,username_here,password_here,apikey_here,foo,dfw,123456
Rackspace,rackORD,username_here,password_here,apikey_here,foo,ord,123456
OpenStack,devstack,username_here,password_here,foo,http://99.99.99.99:5000/v2.0/tokens/,RegionOne,username_here

## Contributing is a cinch as well...
Make your contribution to the goodness. Fork the code, pick an issue, and get coding. If you're unsure where to start or what it all means, choose an issue and leave a comment, asking for assistance.
