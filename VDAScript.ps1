$regPath = "HKLM:\Software\Citrix\VirtualDesktopAgent"
$valueName = "ListOfDDCs"
$valueData = "ctxVD-DDC01.lawnet.fordham.edu ctxVD-DDC02.lawnet.fordham.edu"

# Set the registry value
New-ItemProperty -Path $regPath `
                 -Name $valueName `
                 -Value $valueData `
                 -PropertyType String `
                 -Force
