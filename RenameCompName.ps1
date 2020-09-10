$namelist= ConvertFrom-StringData -StringData $args[0]

if ($namelist.ContainsKey($env:computername)) {
Rename-Computer -NewName $namelist[$env:computername] -Force -Restart
}