<#
In this scenario, a company is going through a rebrand in addition to branching out to multiple subsidiaries.
The extensionAttribute1 is used as a proprietary attribute for SSO where some apps are still using the old email address.
#>

# Update email attribute with the new email address for all service accounts via Office 365.
# Update email attribute with the new email address for all service accounts.
Connect-EXOPSSession
Import-CSV "C:\import.csv" | ForEach-Object {
    Set-Mailbox $_.svc -WindowsEmailAddress $_.email
}

# Populate old email address to the extensionAttribute1 field for all recent new hires.
# Update email address to the custom attribute for any recent new hires.
Import-CSV "C:\import.csv" | ForEach-Object {
    Set-ADUser -Identity $_.user -add @{extensionAttribute1 = $_.mail}
}

# Populate both email and SIP addresses to the proxyAddresses attribute for all recent new hires.
# Populate additional alias for users that have both legal and preferred names.

# Update email attribute with the new email address for all users.
# Update user's mail attribute.
Import-CSV "C:\import.csv" | ForEach-Object {
    Set-ADUser -Identity $_.user -EmailAddress $_.email
}

# Remove old primary SMTP from proxyAddresses for all users.
# Remove old primary SMTP address from proxyAddresses attribute.
Import-CSV "C:\import.csv" | ForEach-Object {
    Set-ADUser -Identity $_.name -Remove @{proxyAddresses = $_.proxy}
}

# Add the previous primary email as an alias (smtp) and add the new email as the primary SMTP via proxyAddresses attribute.
Import-CSV "C:\import.csv" | ForEach-Object {
    $name = $_.samName
    $proxy = $_.proxyAddresses -split ';'
    Set-ADUser -Identity $name -Add @{proxyAddresses = $proxy }
}

# Change SIP addresses to be the same as the new email for all users.
# Remove SIP
Import-CSV "C:\import.csv" | ForEach-Object {
    Set-ADUser -Identity $_.name -Remove @{proxyAddresses = $_.proxy}
}

# Add SIP
Import-CSV "C:\import.csv" | ForEach-Object {
    Set-ADUser -Identity $_.name -Add @{proxyAddresses = $_.proxy}
}

# Change all user's UPN
Import-CSV "C:\import.csv" | ForEach-Object {
    Set-ADUser -Identity $_.samName -UserPrincipalName $_.upn
}

# Set all users the new UPN/email addresses to match that of newly set in AD.
# Change UPN on Office 365 for all users
Connect-MsolService
Import-CSV "C:\import.csv" | ForEach-Object {
    Set-MsolUserPrincipalName -UserPrincipalName $_.oldUPN -NewUserPrincipalName $_.newUPN
}
