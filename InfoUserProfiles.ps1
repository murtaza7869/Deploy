# Find all user profiles on the computer
$profiles = Get-ChildItem -Path 'C:\Users\' -Directory

# Loop through each profile and output the profile path and size
foreach ($profile in $profiles) {
    $profilePath = $profile.FullName
    $profileSize = Get-ChildItem $profilePath -Recurse -File | Measure-Object -Property Length -Sum | Select-Object -ExpandProperty Sum
    Write-Output "User Profile: $profilePath"
    Write-Output "Size: $profileSize bytes`n"
}
