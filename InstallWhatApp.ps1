Invoke-WebRequest 'http://tlu.dl.delivery.mp.microsoft.com/filestreamingservice/files/e1d3c771-f9a9-499f-bfe1-f200bb0c2f37?P1=1608000055&P2=402&P3=2&P4=K05QdmRt1kg1SZ%2bMUpjNQakSY3WEG9P9h8LgBY6SiWGfOZrqXjtw1kxr53SFVLDCzCMXv46I7tAA1e%2fhC5NhMQ%3d%3d' -OutFile 'C:\whatsAppAppx'
Get-AppxPackage -allusers | foreach {Add-AppxPackage -Path "C:\whatsAppAppx"}
