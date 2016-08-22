#Requires -Modules MSOnline
#Requires -Version 2.0

# Script prerequisites
# Follow instructions from https://technet.microsoft.com/en-us/library/dn975125.aspx?f=255&MSPPError=-2147217396

# Type of deployment: single / multi / password
$deployment = 'test'

<# Get account to authenticate to O365. This will open a GUI window and prompt
for the account. It has to have the appropriate credentials to be able to
create new users.
#>
$UserCredential = Get-Credential

# Connect to O365 using the previously introduced credentials
Connect-MsolService -Credential $UserCredential

<# Set the domain variable for the account.
Domains in use:
  nobelbiz.com
  nobelusa.com
#>
$domain = 'nobelbiz.com'

<# Set the license associated with the account.

Licenses in use:
NobelBiz:VISIOCLIENT
NobelBiz:DESKLESSPACK
NobelBiz:O365_BUSINESS_PREMIUM
NobelBiz:OFFICESUBSCRIPTION
NobelBiz:O365_BUSINESS_ESSENTIALS

To get the current licenses, connect to O365 with PowerShell and execute:
Get-MsolAccountSku
#>
$license = 'NobelBiz:O365_BUSINESS_ESSENTIALS'

# Define User Name
$name = "Albert Einstei" ## <-- Modify this with your username.
$principalname = $name.replace(' ','.')
$pos = $name.IndexOf(" ")
$firstname = $name.Substring(0, $pos)
$lastname = $name.Substring($pos+1)
# Create users from CSV file
$users = Import-Csv -Path ".\O365_Accounts.csv"

# Create single user. Check deployment type variable first to select the correct section to run.
if (($deployment) -eq 'single')
  {
    New-MsolUser -DisplayName "$name" `
                 -FirstName "$firstname" `
                 -LastName "$lastname" `
                 -UserPrincipalName "$principalname@$domain" `
                 -UsageLocation US `
                 #-LicenseAssignment "$license" `
  }
  Elseif (($deployment) -eq 'multi')
  {
    $users | ForEach-Object {

    New-MsolUser -UserPrincipalName ($_.UserPrincipalName + '@nobelbiz.com') -FirstName $_.FirstName -LastName $_.LastName -UsageLocation $_.UsageLocation -DisplayName $_.DisplayName }
  }
  Else
  {
    Write-Output 'Unknown deployment type selected, please check the $deployment parameter in the script.'
  }

# To change a user password
#Set-MsolUserPassword -UserPrincipalName "$principalname@$domain" -NewPassword ww@322x -ForceChangePassword $True
