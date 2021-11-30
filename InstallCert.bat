net use z: /d
net use z: \\192.168.150.2\cert cert /user:anyuser
xcopy z:\proxyca.cer e:\documents /Y
net use z: /delete
certutil -enterprise -f -v -AddStore "Root" e:\documents\proxyca.cer
del e:\documents\proxyca.cer
