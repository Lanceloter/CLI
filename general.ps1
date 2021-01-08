# Set proxyAddresses attribute with multiple entries for users via CSV
Import-CSV "C:\file.csv" | ForEach-Object {
    $name = $_.samName
    $proxy = $_.proxyAddresses -split ';'
    Set-ADUser -Identity $name -Add @{proxyAddresses = $proxy}
}

#Set the custom attribute for users via CSV
Import-CSV "C:\file.csv" | ForEach-Object {
    Set-ADUser -Identity $_.user -add @{extensionAttribute1 = $_.mail}
}

#Report of all users who have Full Access permission on this mailbox
Get-MailboxPermission -Identity santarosasub@esba.org | Where { ($_.IsInherited -eq $False) -and -not ($_.User -like "NT AUTHORITY\SELF") } | Export-Csv -Path "C:\Users\Tung.Mach\Downloads\mailboxCheck.csv"

#Report of all users who have
Get-Mailbox -Identity santarosasub@esba.org | select PrimarySmtpAddress,GrantSendOnBehalfTo | export-csv -path “C:\Users\Tung.Mach\Downloads\userSendOnBehalfReport.csv”

#Set Password Never Expires to True
Import-CSV "C:\temp\passwordExpiration.csv" | ForEach-Object {
    Set-MsolUser -UserPrincipalName $_.upn -PasswordNeverExpires $true
}


#Step 28 - Change service account emails to their respective company domain
Connect-EXOPSSession
Import-CSV "C:\temp\svcUpdate.csv" | ForEach-Object {
    Set-Mailbox $_.svc -WindowsEmailAddress $_.email
}

#Step 29 - For new hires, update email address to the custom attribute (extensionAttribute1)
#DONE
Import-CSV "C:\temp\28setAttribute.csv" | ForEach-Object {
    Set-ADUser -Identity $_.user -add @{extensionAttribute1 = $_.mail}
}






#Get AD Users report
Get-ADUser -Filter * -SearchBase ‘OU=Personnel,DC=esba,DC=internal’ -Properties * | select-object name, samaccountname, mail, enabled, extensionattribute1, UserPrincipalName, @{"name"="proxyaddresses";"expression"={$_.proxyaddresses}} | Export-CSV -Path "C:\Users\Tung.Mach\Downloads\FOCReport.csv"

#Get AD DL report
Get-ADGroup -Filter * -SearchBase ‘OU=Distribution Lists,OU=Personnel,DC=esba,DC=internal’ -Properties * | select-object name, samaccountname, mail, @{"name"="proxyaddresses";"expression"={$_.proxyaddresses}} | Export-CSV -Path "C:\Users\Tung.Mach\Downloads\ADGroupReport.csv"

# Manager upload
Import-CSV "C:\Users\infra_ops_admin.EASTERS\Downloads\managerUpload.csv" | ForEach-Object {
    Set-ADUser $_.user -Manager $_.manager
}


Import-CSV "C:\addGuests.csv" | ForEach-Object {
    # Add ESH guest users to All Easterseals Hawaii team
    Add-TeamUser -GroupId ffc1c10d-f3d7-4613-b802-18feb708a71d -User $_.email
    # Add ESH guest users to All Family of Companies team
    Add-TeamUser -GroupId d801a620-ed4e-464a-af96-e7d3f2b04110 -User $_.email
}



#Step 32 - Update user's mail attribute field with a new one (DONE)
Import-CSV "C:\temp\32newEmailAddresses.csv" | ForEach-Object {
    Set-ADUser -Identity $_.user -EmailAddress $_.email
}

#Step 33 - Remove old Primary SMTP from proxyAddresses (DONE)
Import-CSV "C:\temp\33dropSMTP.csv" | ForEach-Object {
    Set-ADUser -Identity $_.name -Remove @{proxyAddresses = $_.proxy}
}

#Step 34 - Update proxyAddresses list (new SMTP, previous primary as smtp)
Import-CSV "C:\temp\34addProxyAddresses.csv" | ForEach-Object {
    $name = $_.samName
    $proxy = $_.proxyAddresses -split ';'
    Set-ADUser -Identity $name -Add @{proxyAddresses = $proxy }
}

#Step 35 - Remove SIP
Import-CSV "C:\temp\35removeSIP.csv" | ForEach-Object {
    Set-ADUser -Identity $_.name -Remove @{proxyAddresses = $_.proxy}
}

#Step 35 - Add SIP
Import-CSV "C:\temp\35addSIP.csv" | ForEach-Object {
    Set-ADUser -Identity $_.name -Add @{proxyAddresses = $_.proxy}
}

#Step 36 - Change all user's UPN
Import-CSV "C:\temp\changeADupn2.csv" | ForEach-Object {
    Set-ADUser -Identity $_.samName -UserPrincipalName $_.upn
}

#Step 37 - Change UPN on Office 365 for all users
Connect-MsolService
Import-CSV "C:\temp\37changeO365upn.csv" | ForEach-Object {
    Set-MsolUserPrincipalName -UserPrincipalName $_.oldUPN -NewUserPrincipalName $_.newUPN
}



Import-CSV "C:\temp\newHiresTeams.csv" | ForEach {Add-TeamUser -GroupId $_.groupID -User $_.member}


#Microsoft Teams for ESH
Import-CSV "C:\addTeamsESH.csv" | ForEach {New-Team -MailNickname $_.mailName -displayname $_.displayName -Visibility "private" -Owner "svc_teams_admin@familyofcompanies.org"}

Import-CSV "C:\addChannelsESH.csv" | ForEach {New-TeamChannel -GroupId $_.groupID -DisplayName $_.displayName}


Import-CSV "C:\Users\Tung.Mach\Downloads\o365group.csv" | ForEach-Object {
    Remove-UnifiedGroupLinks -Identity $_.group -LinkType Members -Links svc_MailMig@eshawaii.onmicrosoft.com
}

Remove-UnifiedGroupLinks



Import-CSV "C:\Users\Tung.Mach\Downloads\upnChange.csv" | ForEach-Object {
    Set-ADUser -Identity $_.samName -UserPrincipalName $_.upn
}

# Add ESH users to our AAD
Connect-AzureAD
New-AzureADMSInvitation -InvitedUserEmailAddress KBuenafe@eastersealshawaii.org -InvitedUserType Guest -SendInvitationMessage $False -InviteRedirectUrl "https://www.office.com/"


# ESH Unification Project __________________________________________________________________________________________________________________________________________

# Add ESH guest users to FOC tenant
Connect-AzureAD
Import-CSV "C:\Users\Tung.Mach\Downloads\guestESH.csv" | ForEach-Object {
    New-AzureADMSInvitation -InvitedUserEmailAddress $_.email -InvitedUserType Guest -SendInvitationMessage $False -InviteRedirectUrl "https://www.office.com/"
}

# Add FOC guest users to ESH tenant
Connect-AzureAD
Import-CSV "C:\Users\Tung.Mach\Downloads\guestFOC.csv" | ForEach-Object {
    New-AzureADMSInvitation -InvitedUserEmailAddress $_.email -InvitedUserType Guest -SendInvitationMessage $False -InviteRedirectUrl "https://www.office.com/"
}

# Populate info for ESH guest users
Connect-AzureAD
Import-CSV "C:\Users\Tung.Mach\Downloads\infoESH.csv" | ForEach-Object {
    Set-AzureADUser -ObjectId $_.userID -JobTitle $_.title -TelephoneNumber $_.phone -PhysicalDeliveryOfficeName $_.location -Department $_.department -CompanyName $_.company
}

# Populate info for FOC guest users
Connect-AzureAD
Import-CSV "C:\Users\Tung.Mach\Downloads\infoFOC.csv" | ForEach-Object {
    Set-AzureADUser -ObjectId $_.userID -JobTitle $_.title -TelephoneNumber $_.phone -PhysicalDeliveryOfficeName $_.location -Department $_.department -CompanyName $_.company
}

# Unhide ESH guest email from GAL/Teams
Connect-EXOPSSession
Import-CSV "C:\Users\Tung.Mach\Downloads\guestESH.csv" | ForEach-Object {
    Set-MailUser $_.email -HiddenFromAddressListsEnabled $false
}

# Unhide FOC guest email from GAL/Teams
Connect-EXOPSSession
Import-CSV "C:\Users\Tung.Mach\Downloads\guestFOC.csv" | ForEach-Object {
    Set-MailUser $_.email -HiddenFromAddressListsEnabled $false
}

# Get hidden from GAL
Get-Recipient -ResultSize unlimited | FT Name, recipientType, primarySMTPaddress, *hidden*


Get-AzureADUser -Filter "UserType eq 'Member'" | Export-Csv -Path "C:\Users\Tung.Mach\Downloads\eshAADreport.csv"


grep adam.martin /etc/passwd
useradd -d /home/Justin.Griffin -m -c "ISOS Consultant SRE-286" -s /bin/bash Justin.Griffin
mkdir -v -m 0755 /mnt/data/consultants/Justin.Griffin
chown -v Justin.Griffin: /mnt/data/consultants/Justin.Griffin
su - Justin.Griffin
ln -s /mnt/data/consultants/Justin.Griffin/workdir
ssh-keygen -b 2048 -t rsa -C "Justin.Griffin@prd-jira-01"
cat ~/.ssh/id_rsa.pub > ~/.ssh/authorized_keys

Get-MailUser dtse@eastersealshawaii.org | FL *hidden*
Get-AzureADUser -ObjectId 963b9dff-e74a-47dd-aa58-6e92b1564359 | FL
Set-AzureADUser -ObjectId 963b9dff-e74a-47dd-aa58-6e92b1564359 -ShowInAddressList $true
ShowInAddressList 



Get-Mailbox -Identity CBrooks@eastersealshawaii.org | Search-Mailbox -SearchQuery {Subject: "* joined the All Easterseals Hawaii group" AND Received:12/16/20} –TargetMailbox lmach@eastersealshawaii.org -TargetFolder "Deleted Items" -DeleteContent
