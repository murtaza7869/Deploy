 New-LocalUser -AccountNeverExpires:$true -Password ( ConvertTo-SecureString -AsPlainText -Force 'Password123!') -Name 'nwcaluser' | Add-LocalGroupMember -Group administrators
