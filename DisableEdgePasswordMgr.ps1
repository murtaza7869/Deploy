$registryPath = "HKLM:\SOFTWARE\Policies\Microsoft\MicrosoftEdge\Main"

$Name = "FormSuggest Passwords"

$value = "no"

IF(!(Test-Path $registryPath))

  {

    New-Item -Path $registryPath -Force | Out-Null

    New-ItemProperty -Path $registryPath -Name $name -Value $value -PropertyType String -Force | Out-Null}

 ELSE {

    New-ItemProperty -Path $registryPath -Name $name -Value $value -PropertyType String -Force | Out-Null}
    # apply the new policy immediately
gpupdate.exe /force