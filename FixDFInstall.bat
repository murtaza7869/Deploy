@sc stop DFServ
@TIMEOUT 10
@sc delete DFServ
@TIMEOUT 5
@reg delete HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\DFServ /f
@TIMEOUT 2
@rmdir /Q /S "%systemdrive%\Program Files (x86)\Faronics\Deep Freeze"

