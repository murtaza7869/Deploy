md c:\DeepFrzExpryFix
Invoke-WebRequest 'https://faronics-techsupport-utilities.s3.us-west-2.amazonaws.com/Download/ForCustomer/HandleDFEntToCloud.exe' -Outfile 'C:\DeepFrzExpryFix\HandleDFEntToCloud.exe'
ping -n 3 127.0.0.1
Start-Process -FilePath "C:\DeepFrzExpryFix\HandleDFEntToCloud.exe"
