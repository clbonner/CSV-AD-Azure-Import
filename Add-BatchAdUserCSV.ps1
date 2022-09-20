# Add-BatchADUserCSV - Bulk user account creation script. 
# This script takes a CSV input file and creates Active Directory accounts with appropriate groups specified in a seperate CSV file.
# Created by Christopher L Bonner 2022.

if ($args.count -ne 2) {
    "Usage: Add-BatchADUserCSV {users.csv} {groups.csv}"
    ""
    "Users CSV file must contain the following columns: fullname, firstname, lastname, email, password"
    "Groups CSV file must contain the following column: name"
    exit
}

$user_csv = $args[0]
$group_csv = $args[1]

$users = Import-Csv -Path $user_csv
$groups = Import-Csv -Path $group_csv

foreach($user in $users) {
    # get sam account name from email
    $sam = $user.email.split("@")[0]
    
    # shorten username if greater than 20 characters
    if ($sam.Length -gt 20) {
        $new = ""
        for ($i = 0; $i -lt 20; $i++) {
            $new += $sam[$i]
        }
        $sam = $new
        "WARNING: Username shortend to " + $sam
    }

    # create account
    "Creating account for: " + $user.fullname
    New-ADUser -Name $user.fullname -GivenName $user.firstname -Surname $user.lastname -DisplayName $user.fullname -SamAccountName $sam -EmailAddress $user.email -UserPrincipalName $user.email -Enabled $True -AccountPassword (ConvertTo-SecureString -AsPlainText $user.password -Force) -ChangePasswordAtLogon $True
    
    # get new user object
    $newuser = Get-ADUser $sam

    # add to groups
    foreach($group in $groups) {
        "Adding to group: " + $group.name
        Add-ADGroupMember -Identity $group.name -Members $newuser.ObjectGUID
    }
}

"Complete"
