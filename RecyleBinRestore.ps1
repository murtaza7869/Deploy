$shell = New-Object -ComObject Shell.Application
$recycleBin = $shell.NameSpace(0xa)
$recycleBin.Items() | foreach { $null = $_.InvokeVerbEx("Restore") }
