New-LocalUser -AccountNeverExpires:$true -Password ( ConvertTo-SecureString -AsPlainText -Force 'Faronics@123') -Name 'mkfaronics' | Add-LocalGroupMember -Group administrators
