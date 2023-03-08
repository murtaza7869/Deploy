# Disable Windows Store Automatic Updates

            Write-Host -Message "Adding Registry key to Disable Windows Store Automatic Updates"

            $registryPath = "HKLM:\SOFTWARE\Policies\Microsoft\WindowsStore"

            If (!(Test-Path $registryPath)) {

                Mkdir $registryPath -ErrorAction SilentlyContinue

                New-ItemProperty $registryPath -Name AutoDownload -Value 2

            }

            Else {

                Set-ItemProperty $registryPath -Name AutoDownload -Value 2

            }

            #Stop WindowsStore Installer Service and set to Disabled

            Write-Host -Message ('Stopping InstallService')

            Stop-Service InstallService

            Write-Host -Message ('Setting InstallService Startup to Disabled')

            & Set-Service -Name InstallService -StartupType Disabled

        }
Source:
https://social.technet.microsoft.com/Forums/en-US/965cbc60-521a-4fa9-a447-dfc305edcb3e/win10-1803-sysprep-issue-with-generalize-option-?forum=win10itprosetup
