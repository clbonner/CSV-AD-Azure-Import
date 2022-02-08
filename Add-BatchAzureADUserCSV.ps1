# Add-BatchAzureADUserCSV - Adds users to Azure AD groups in bulk. 
# Created by Christopher L Bonner 2022.

if ($args.count -ne 2) {
    "Usage: Add-BatchAzureADGroupsCSV {users.csv} {groups.csv}"
    ""
    "Users CSV file must contains the following columns: email"
    "Groups CSV file must contain the following column: name"
    exit
}

$user_csv = $args[0]
$group_csv = $args[1]

$users = Import-Csv -Path $user_csv
$groups = Import-Csv -Path $group_csv

#Import-Module AzureAD

$credential = Get-Credential
Connect-AzureAD -Credential $credential

foreach($user in $users) {
    # get user object
    $AzureADUser = Get-AzureADUser -SearchString $user.email

    # add to groups/teams
    foreach($group in $groups) {
        "Adding " + $AzureADUser.DisplayName + " to group: " + $group.name
        $AzureADGroup = Get-AzureADGroup -SearchString $group.name
        Add-AzureADGroupMember -ObjectId $AzureADGroup.ObjectID -RefObjectId $AzureADUser.ObjectID
    }
}

"Complete"
