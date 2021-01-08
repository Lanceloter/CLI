#Set proxyAddresses attribute for users via CSV
Import-CSV "C:\temp\proxyAddressesUpdate.csv" | ForEach-Object {
    $name = $_.samName
    $proxy = $_.proxyAddresses -split ';'
    Set-ADUser -Identity $name -Add @{proxyAddresses = $proxy}
}
