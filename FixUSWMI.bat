sc stop USEngine
TIMEOUT /T 60
REG ADD "HKEY_LOCAL_MACHINE\SOFTWARE\Classes\CLSID\{5FA226A6-169D-458E-9816-28EA32A326AA}" /f
del /Q "%ProgramData%\Faronics\StorageSpace\USC\USAuth.dat"
sc start USEngine
taskkill.exe /F /IM FWAService.exe