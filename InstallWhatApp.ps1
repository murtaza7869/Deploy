Invoke-WebRequest 'Invoke-WebRequest 'http://tlu.dl.delivery.mp.microsoft.com/filestreamingservice/files/e1d3c771-f9a9-499f-bfe1-f200bb0c2f37?P1=1608004943&P2=402&P3=2&P4=RDLAl6k4QFClKavOFRdGDho1uzwlKHopttVjtevxy%2bakkZSnWNfrmxYxzC7fumbwU8UiV1J1j3X7jluQgbZ3GA%3d%3d' -OutFile 'C:\whatsAppAppx'
Get-AppxPackage -allusers | foreach {Add-AppxPackage -Path "C:\whatsAppAppx"}
