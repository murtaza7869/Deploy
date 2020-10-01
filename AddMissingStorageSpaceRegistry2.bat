REG ADD "HKEY_LOCAL_MACHINE\SOFTWARE\Wow6432Node\Faronics\Faronics Core 3\Storage Spaces\Spaces\IMG" /v Path /d "C:\ProgramData\Faronics\StorageSpace\IMG"
REG ADD "HKEY_LOCAL_MACHINE\SOFTWARE\Wow6432Node\Faronics\Faronics Core 3\Storage Spaces\Spaces\IMG" /v Size /t REG_DWORD /d 00000200
REG ADD "HKEY_LOCAL_MACHINE\SOFTWARE\Wow6432Node\Faronics\Faronics Core 3\Storage Spaces\Spaces\IMG" /v Status /t REG_DWORD /d 00000004
REG ADD "HKEY_LOCAL_MACHINE\SOFTWARE\Wow6432Node\Faronics\Faronics Core 3\Storage Spaces\Spaces\IMG" /v DriveLetter /d "C:\ProgramData\Faronics\StorageSpace"
REG ADD "HKEY_LOCAL_MACHINE\SOFTWARE\Wow6432Node\Faronics\Faronics Core 3\Storage Spaces\Spaces\IMG" /v Type /t REG_DWORD /d 00000004
REG ADD "HKEY_LOCAL_MACHINE\SOFTWARE\Wow6432Node\Faronics\Faronics Core 3\Storage Spaces\Spaces\IMG" /v MigratorDllPath /d "C:\Program Files (x86)\Faronics\Imaging\IMGMigrator.dll"
REG ADD "HKEY_LOCAL_MACHINE\SOFTWARE\Wow6432Node\Faronics\Faronics Core 3\Storage Spaces\Spaces\IMG" /v ProductDataMigrationSupported /t REG_DWORD /d 00000001

REG ADD "HKEY_LOCAL_MACHINE\SOFTWARE\Wow6432Node\Faronics\Faronics Core 3\Storage Spaces\Spaces\SUC" /v Path /d "C:\ProgramData\Faronics\StorageSpace\SUC"
REG ADD "HKEY_LOCAL_MACHINE\SOFTWARE\Wow6432Node\Faronics\Faronics Core 3\Storage Spaces\Spaces\SUC" /v Size /t REG_DWORD /d 00000200
REG ADD "HKEY_LOCAL_MACHINE\SOFTWARE\Wow6432Node\Faronics\Faronics Core 3\Storage Spaces\Spaces\SUC" /v Status /t REG_DWORD /d 00000004
REG ADD "HKEY_LOCAL_MACHINE\SOFTWARE\Wow6432Node\Faronics\Faronics Core 3\Storage Spaces\Spaces\SUC" /v DriveLetter /d "C:\ProgramData\Faronics\StorageSpace"
REG ADD "HKEY_LOCAL_MACHINE\SOFTWARE\Wow6432Node\Faronics\Faronics Core 3\Storage Spaces\Spaces\SUC" /v Type /t REG_DWORD /d 00000004
REG ADD "HKEY_LOCAL_MACHINE\SOFTWARE\Wow6432Node\Faronics\Faronics Core 3\Storage Spaces\Spaces\SUC" /v MigratorDllPath /d "C:\Program Files\Faronics\Software Updater\SUCMigrator.dll"
REG ADD "HKEY_LOCAL_MACHINE\SOFTWARE\Wow6432Node\Faronics\Faronics Core 3\Storage Spaces\Spaces\SUC" /v ProductDataMigrationSupported /t REG_DWORD /d 00000001

taskkill.exe /F /IM FWAService.exe
sc start FWUSvc
sc start USEngine
