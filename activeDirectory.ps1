# Set proxyAddresses attribute with multiple entries for users via CSV
Import-CSV "C:\import.csv" | ForEach-Object {
    $name = $_.samName
    $proxy = $_.proxyAddresses -split ';'
    Set-ADUser -Identity $name -Add @{proxyAddresses = $proxy}
}

# Set the custom attribute for users via CSV
Import-CSV "C:\import.csv" | ForEach-Object {
    Set-ADUser -Identity $_.user -Add @{extensionAttribute1 = $_.mail}
}

# Get report of AD users (sample 1)
Get-ADUser -Filter * -SearchBase ‘OU=Personnel,DC=contoso,DC=com’ -Properties * | select-object name, samaccountname, mail, enabled, extensionattribute1, UserPrincipalName, @{"name"="proxyaddresses";"expression"={$_.proxyaddresses}} | Export-CSV -Path "C:\export.csv"

# Get report of AD users (sample 2)
Get-ADGroup -Filter * -SearchBase ‘OU=Distribution Lists,DC=contoso,DC=com’ -Properties * | select-object name, samaccountname, mail, @{"name"="proxyaddresses";"expression"={$_.proxyaddresses}} | Export-CSV -Path "C:\export.csv"

# Upload user's manager
Import-CSV "C:\import.csv" | ForEach-Object {
    Set-ADUser $_.user -Manager $_.manager
}

# Update user's mail
Import-CSV "C:\import.csv" | ForEach-Object {
    Set-ADUser -Identity $_.user -EmailAddress $_.email
}

# Remove old Primary SMTP from proxyAddresses
Import-CSV "C:\import.csv" | ForEach-Object {
    Set-ADUser -Identity $_.name -Remove @{proxyAddresses = $_.proxy}
}

# Update proxyAddresses list
Import-CSV "C:\import.csv" | ForEach-Object {
    $name = $_.samName
    $proxy = $_.proxyAddresses -split ';'
    Set-ADUser -Identity $name -Add @{proxyAddresses = $proxy }
}

# Remove SIP from proxyAddresses
Import-CSV "C:\import.csv" | ForEach-Object {
    Set-ADUser -Identity $_.name -Remove @{proxyAddresses = $_.proxy}
}

# Add SIP from proxyAddresses
Import-CSV "C:\import.csv" | ForEach-Object {
    Set-ADUser -Identity $_.name -Add @{proxyAddresses = $_.proxy}
}

# Change all user's UPN
Import-CSV "C:\import.csv" | ForEach-Object {
    Set-ADUser -Identity $_.samName -UserPrincipalName $_.upn
}

Import-CSV "C:\import.csv" | ForEach-Object {
    Set-ADUser -Identity $_.samName -UserPrincipalName $_.upn
}
