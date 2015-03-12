Remove-Module PoshStack
Import-Module PoshStack
Clear

$acct = "workshop"
$UserNameStartsWith = "workshop"

$userlist = Get-OpenStackIdentityUser -Account $acct

foreach ($user in $userlist) {
    if ($user.username -like "$UserNameStartsWith*") {
        Write-Host "Removing..."
        Remove-OpenStackIdentityUser -Account $acct -UserID $user.id
        Write-Host $user.id
        Write-Host $user.username
        Start-Sleep -Seconds 1
    }
}