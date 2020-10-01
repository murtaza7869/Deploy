REG ADD "HKEY_LOCAL_MACHINE\SOFTWARE\Wow6432Node\Faronics\Faronics Core 3\Storage Spaces\Spaces\IMG" /v Path /d "C:\ProgramData\Faronics\StorageSpace\IMG" /f
REG ADD "HKEY_LOCAL_MACHINE\SOFTWARE\Wow6432Node\Faronics\Faronics Core 3\Storage Spaces\Spaces\IMG" /v Size /t REG_DWORD /d 00000200 /f	
REG ADD "HKEY_LOCAL_MACHINE\SOFTWARE\Wow6432Node\Faronics\Faronics Core 3\Storage Spaces\Spaces\IMG" /v Status /t REG_DWORD /d 00000004 /f
REG ADD "HKEY_LOCAL_MACHINE\SOFTWARE\Wow6432Node\Faronics\Faronics Core 3\Storage Spaces\Spaces\IMG" /v DriveLetter /d "C:\ProgramData\Faronics\StorageSpace" /f
REG ADD "HKEY_LOCAL_MACHINE\SOFTWARE\Wow6432Node\Faronics\Faronics Core 3\Storage Spaces\Spaces\IMG" /v Type /t REG_DWORD /d 00000004 /f
REG ADD "HKEY_LOCAL_MACHINE\SOFTWARE\Wow6432Node\Faronics\Faronics Core 3\Storage Spaces\Spaces\IMG" /v MigratorDllPath /d "C:\Program Files (x86)\Faronics\Imaging\IMGMigrator.dll" /f
REG ADD "HKEY_LOCAL_MACHINE\SOFTWARE\Wow6432Node\Faronics\Faronics Core 3\Storage Spaces\Spaces\IMG" /v ProductDataMigrationSupported /t REG_DWORD /d 00000001 /f

REG ADD "HKEY_LOCAL_MACHINE\SOFTWARE\Wow6432Node\Faronics\Faronics Core 3\Storage Spaces\Spaces\SUC" /v Path /d "C:\ProgramData\Faronics\StorageSpace\SUC" /f
REG ADD "HKEY_LOCAL_MACHINE\SOFTWARE\Wow6432Node\Faronics\Faronics Core 3\Storage Spaces\Spaces\SUC" /v Size /t REG_DWORD /d 00000200 /f
REG ADD "HKEY_LOCAL_MACHINE\SOFTWARE\Wow6432Node\Faronics\Faronics Core 3\Storage Spaces\Spaces\SUC" /v Status /t REG_DWORD /d 00000004 /f
REG ADD "HKEY_LOCAL_MACHINE\SOFTWARE\Wow6432Node\Faronics\Faronics Core 3\Storage Spaces\Spaces\SUC" /v DriveLetter /d "C:\ProgramData\Faronics\StorageSpace" /f
REG ADD "HKEY_LOCAL_MACHINE\SOFTWARE\Wow6432Node\Faronics\Faronics Core 3\Storage Spaces\Spaces\SUC" /v Type /t REG_DWORD /d 00000004 /f
REG ADD "HKEY_LOCAL_MACHINE\SOFTWARE\Wow6432Node\Faronics\Faronics Core 3\Storage Spaces\Spaces\SUC" /v MigratorDllPath /d "C:\Program Files\Faronics\Software Updater\SUCMigrator.dll" /f
REG ADD "HKEY_LOCAL_MACHINE\SOFTWARE\Wow6432Node\Faronics\Faronics Core 3\Storage Spaces\Spaces\SUC" /v ProductDataMigrationSupported /t REG_DWORD /d 00000001 /f

taskkill.exe /F /IM FWAService.exe
sc start FWUSvc
sc start USEngine
