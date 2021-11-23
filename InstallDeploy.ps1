md c:\Deploy
Invoke-WebRequest 'https://deploy.faronics.com/api/GetProductInstaller?fn=29377C76DFF311102139291C4111021392D33911102139063497CFB25F0&pt=0' -Outfile 'C:\Deploy\FaronicsDeployAgent_Manual.exe'
ping -n 5 127.0.0.1
Invoke-WebRequest 'https://github.com/murtaza7869/Deploy/raw/fd55ce82a56d3f1d3d0818f46dabc48ce53d6b38/RunAsSpc.exe' -Outfile 'C:\Deploy\RunAsSpc.exe'
ping -n 5 127.0.0.1
Invoke-WebRequest 'https://github.com/murtaza7869/Deploy/raw/master/crypt.spc' -Outfile 'C:\Deploy\crypt.spc'
Start-Process -FilePath "C:\Deploy\RunAsSpc.exe" "C:\Deploy\crypt.spc"