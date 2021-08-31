# How to use this script
# AddWallpaperOptions.ps1 -Position <Tile/Center/Stretch/Fit/Fill> 
#                         -Action   <DisableWallpaper/NewWallpaper> 
#                         -Modify   <Yes/No> 
#                         -ImageURL <Http URL/ UNC Path>

param(
	[string]$JsonFilePath
)

$ScriptRoot = $PSScriptRoot
if([string]::IsNullOrEmpty($ScriptRoot)){
    $ScriptRoot = Split-Path $MyInvocation.MyCommand.Path -Parent
}

# Get each folder under "Users"
$drive = $Env:SystemDrive #(Get-Location).Drive.Root
Write-Host "System Drive: $drive"
$users = Get-ChildItem $("$drive\Users")
$LogDir = "$ScriptRoot\logs"
$LogFile = "$LogDir\ManageConfiguration.Log"
$ERROR_SUCCESS = 0
$ERROR_FAILED = 1
$ERROR_EXCEPTION_OCCURED = -1
$DownloadPath = "$($Env:SystemDrive)\ProgramData\Faronics\"
$DeskTopWallpaperPath = "Registry::HKEY_USERS\Temp\Control Panel\Desktop"
$NoChangeWallpaperPath = "Registry::HKEY_USERS\Temp\Software\Microsoft\Windows\CurrentVersion\Policies\ActiveDesktop"
$SystemWallpaperPath = "Registry::HKEY_USERS\Temp\Software\Microsoft\Windows\CurrentVersion\Policies\System"
$ERROR_PS_VER_LOWER = 20008
$versionMinimum = [Version]'3.0.99999.999'

# Begin {
# Try {
# Add-Type -TypeDefinition @"
# using System;
# using System.Runtime.InteropServices;
# using Microsoft.Win32;
# namespace Wallpaper {
# public class WMIBroadcast {
# [DllImport("user32.dll", SetLastError = true)]
# private static extern IntPtr SendMessageTimeout ( IntPtr hWnd, int Msg, IntPtr wParam, string lParam, uint fuFlags, uint uTimeout, IntPtr lpdwResult );
# private static readonly IntPtr HWND_BROADCAST = new IntPtr(0xffff);
# private const int WM_SETTINGCHANGE = 0x1a;
# private const int SMTO_ABORTIFHUNG = 0x0002;
# public static void SettingChange
# {
# SendMessageTimeout(HWND_BROADCAST, WM_SETTINGCHANGE, IntPtr.Zero, null, SMTO_ABORTIFHUNG, 100, IntPtr.Zero);
# }
# }
# }
# "@ -ErrorAction Stop
# }
# Catch {
# #Write-Warning -Message "Unable to mess with wallpaper settings because $($_.Exception.Message)"
# }
# }

Add-Type -TypeDefinition @"
		using System;
		using System.Runtime.InteropServices;
		using Microsoft.Win32;
		namespace Wallpaper {
				public class Setter {
				public const int SetDesktopWallpaper = 20;
				public const int UpdateIniFile = 0x01;
				public const int SendWinIniChange = 0x02;
				[DllImport("user32.dll", SetLastError = true, CharSet = CharSet.Auto)]
				private static extern int SystemParametersInfo (int uAction, int uParam, string lpvParam, int fuWinIni);
				public static void SetWallpaper ( string path ) {
					SystemParametersInfo( SetDesktopWallpaper, 0, path, UpdateIniFile | SendWinIniChange );
				}
			}		
			public class WMIBroadcast {
				[DllImport("user32.dll", SetLastError = true)]
				private static extern IntPtr SendMessageTimeout ( IntPtr hWnd, int Msg, IntPtr wParam, string lParam, uint fuFlags, uint uTimeout, IntPtr lpdwResult );
				private static readonly IntPtr HWND_BROADCAST = new IntPtr(0xffff);
				private const int WM_SETTINGCHANGE = 0x1a;
				private const int SMTO_ABORTIFHUNG = 0x0002;
				public static void SettingChange()
				{
					SendMessageTimeout(HWND_BROADCAST, WM_SETTINGCHANGE, IntPtr.Zero, null, SMTO_ABORTIFHUNG, 100, IntPtr.Zero);
				}
			}
		}
"@ -ErrorAction SilentlyContinue

Function ExitIfPSVersionLower {

    Log -logstring ("Info: PowerShell version is: " + $PSVersionTable.PSVersion)

    if ($versionMinimum -gt $PSVersionTable.PSVersion){
        Log -logstring "Error: This script requires minimun PowerShell version: $versionMinimum"
        Exit $ERROR_PS_VER_LOWER
    }
}

Function CreateLogDir {
    If (!(Test-Path $LogDir)) {
        mkdir $LogDir | out-null
    }
}
Function Log {
    param(
        [Parameter(Mandatory=$true)][string]$logstring
    )

    $Logtime = Get-Date -Format "dd/MM/yyyy HH:mm:ss:fff"
    $logToWrite = "{$Logtime[PID:$PID]} : $logstring"
    Write-Host($logToWrite)
    Add-content $LogFile -value ($logToWrite)            
}

trap {
    Log -logstring "Exception occured in AddWallpaperOptions Script"
    $message = $Error[0].Exception.Message
    if ($message) {
        Log -logstring "EXCEPTION: $message"
    }

    Log -logstring "Exit from AddWallpaperOptions Script With Exitcode=$ERROR_EXCEPTION_OCCURED `r`n`r`n"
    exit $ERROR_EXCEPTION_OCCURED
}

function IsOsWin8.1orGreather {
    $OSInfo = Get-WmiObject -Class Win32_OperatingSystem 
    if($OSInfo){
       if([int]$OSInfo.BuildNumber -ge 9200){
            Log -logstring "IsOsWin8.1orGreather: Windows OS is Win8.1 or greater than Windows8.1"
            return $true
        }
        else{
            Log -logstring "IsOsWin8.1orGreather: Windows OS less than Win8.1"
            return $false
        }
    }
    Log -logstring "IsOsWin8.1orGreather: Get-WmiObject for class Win32_OperatingSystem failed: So return true as default value"
    return $true
}

function AddDesktopWallpaperRegValues{
    param(  $RegKeyPath,
            $WallpaperFilePath,
            $Style,
            $IsTile)

    if (Test-Path $RegKeyPath) {

        # Set the image
       if(!([string]::IsNullOrEmpty($WallpaperFilePath))){
           Set-ItemProperty -Path $RegKeyPath -Name "Wallpaper" -value $WallpaperFilePath
       }

       # Set the style
       if(!([string]::IsNullOrEmpty($Style))){

           Set-ItemProperty -Path $RegKeyPath -Name "WallpaperStyle" -value $Style
           
           if (!(IsOsWin8.1orGreather)) {
                if($IsTile -eq "1"){
                    Set-ItemProperty -Path $RegKeyPath -Name "TileWallpaper" -value "1"
                }
                else{
                    Set-ItemProperty -Path $RegKeyPath -Name "TileWallpaper" -value "0"
                }
           }
       }            
   }
}

function DisableDesktopWallpaperRegValues{
    param($RegKeyPath)

    if (Test-Path $RegKeyPath) {

        Remove-ItemProperty -Path $RegKeyPath -Name "Wallpaper" -ErrorAction SilentlyContinue
        Remove-ItemProperty -Path $RegKeyPath -Name "WallpaperStyle" -ErrorAction SilentlyContinue
        Remove-ItemProperty -Path $RegKeyPath -Name "TileWallpaper" -ErrorAction SilentlyContinue
   }
}

function PermitModifyWallpaper {
    param(	$RegKeyPath,
			$AllowChange)

    # Set the permit modify wallpaper
    if (!([string]::IsNullOrEmpty($AllowChange))) {
    
        if ( !(Test-Path $RegKeyPath) ) {
            Log -logstring "Creating Active desktop key in reg path"
            New-Item -Path $RegKeyPath -Force
        }
    
        if ($AllowChange -eq "Yes") {
			Log -logstring "Allowing user to change wallpaper. RegKeyPath: $RegKeyPath"
			
            Set-ItemProperty -Path $RegKeyPath  -Name "NoChangingWallPaper" -value 0  
        }
        elseif ($AllowChange -eq "No") {
			Log -logstring "Disallowing user to change wallpaper. RegKeyPath: $RegKeyPath"	
						
            Set-ItemProperty -Path $RegKeyPath -Name "NoChangingWallPaper" -value 1 
        }
    }
}

function SetWallpaperOptions{
    param(  $Action,
            $Path,
            $Style,
            $IsTile,
            $AllowChange)

    Log -logstring "Action: '$Action' Path: '$Path' Style: '$Style' IsTile: '$Istile'  AllowChange: '$AllowChange'"
	
    # For each user, load and edit their registry
    foreach ( $user in $users ) {
        Log -logstring "User: $($user.Name)"

        # If this isn't us, load their hive and set the directory
        # If this is us, use HKEY_CURRENT_USER
        if ( $($user.Name) -ne $env:username ) {
            Log -logstring "Loading user hive"
            reg.exe LOAD HKU\Temp "$($drive)\Users\$($user.Name)\NTUSER.DAT"
            Log -logstring "After loading user hive '$($drive)\Users\$($user.Name)\NTUSER.DAT'"
            $dir2 = "Registry::HKEY_USERS\Temp\Software\Microsoft\Windows\CurrentVersion\Policies"
			

            if ( !(Test-Path $DeskTopWallpaperPath)) {
                Log -logstring " going to Create Reg path '$DeskTopWallpaperPath' "
                New-Item -Path $DeskTopWallpaperPath -Force
            }
				
            if ( !(Test-Path $dir2)) {
                Log -logstring " going to Create Reg path '$dir2' "
                New-Item -Path $dir2 -Force
            }

            if ( !(Test-Path $DeskTopWallpaperPath) -and !(Test-Path $dir2)) {
                Log -logstring "Reg path not exists"
                # Unload user's hive
                if ( $user.Name -ne $env:username ) {
                    Log -logstring "Going to unload  hive"
                    [gc]::Collect()
                    reg.exe UNLOAD HKU\Temp
                }
                
                Log -logstring "====================="
                continue 
            }
        } 
        else {
            Log -logstring "Found current user in users enumeration. Skipped for now"
            continue
        }

        if ($Action -ieq "NewWallpaper") {

            if (IsOsWin8.1orGreather) {
				AddDesktopWallpaperRegValues -RegKeyPath $DeskTopWallpaperPath -WallpaperFilePath $Path -Style $Style 
				AddDesktopWallpaperRegValues -RegKeyPath $SystemWallpaperPath -WallpaperFilePath $Path -Style $Style 
			}	
            else{
				AddDesktopWallpaperRegValues -RegKeyPath $DeskTopWallpaperPath -WallpaperFilePath $Path -Style $Style -IsTile $IsTile
				AddDesktopWallpaperRegValues -RegKeyPath $SystemWallpaperPath -WallpaperFilePath $Path -Style $Style -IsTile $IsTile
			}
        }
        elseif($Action -ieq "DisableWallpaper"){

            DisableDesktopWallpaperRegValues -RegKeyPath $DeskTopWallpaperPath
            DisableDesktopWallpaperRegValues -RegKeyPath $SystemWallpaperPath
        }
   
        PermitModifyWallpaper -RegKeyPath $NoChangeWallpaperPath -AllowChange $AllowChange
        
        # Unload user's hive
        if ( $user.Name -ne $env:username ) {
            [gc]::Collect()
            reg.exe UNLOAD HKU\Temp
        }
				
        Log -logstring "====================="
    }

    Log -logstring "Going to enumerate HKEY_USERS to setwallpaper in currently loaded registry hives"
    $Keys = Get-ChildItem "Registry::HKEY_USERS"

    foreach ( $Key in $Keys ) {
        $LoadedHiveDesktop = "Registry::$Key\Control Panel\Desktop"
        $LoadedHivePolicies = "Registry::$Key\Software\Microsoft\Windows\CurrentVersion\Policies"
        $LoadedHiveSystem = "Registry::$Key\Software\Microsoft\Windows\CurrentVersion\Policies\System"
    
        if ($Action -ieq "NewWallpaper") {
		
            if ( !(Test-Path $LoadedHiveDesktop)) {
			
                Log -logstring " going to Create Reg path '$LoadedHiveDesktop' "
                New-Item -Path $LoadedHiveDesktop -Force 
            }
            if (!(Test-Path $LoadedHiveSystem)) {
			
                Log -logstring " going to Create Reg path '$LoadedHiveSystem' "
                New-Item -Path $LoadedHiveSystem -Force 
            }

            if (IsOsWin8.1orGreather) {
                AddDesktopWallpaperRegValues -RegKeyPath $LoadedHiveDesktop -WallpaperFilePath $Path -Style $Style  
                AddDesktopWallpaperRegValues -RegKeyPath $LoadedHiveSystem -WallpaperFilePath $Path -Style $Style   
            }
            else{
                AddDesktopWallpaperRegValues -RegKeyPath $LoadedHiveDesktop -WallpaperFilePath $Path -Style $Style -IsTile $IsTile
                AddDesktopWallpaperRegValues -RegKeyPath $LoadedHiveSystem -WallpaperFilePath $Path -Style $Style -IsTile $IsTile
            }
        }
        elseif ($Action -ieq "DisableWallpaper") {

            DisableDesktopWallpaperRegValues -RegKeyPath $LoadedHiveDesktop
            DisableDesktopWallpaperRegValues -RegKeyPath $LoadedHiveSystem
        }

        if (Test-Path $LoadedHivePolicies) {

            PermitModifyWallpaper -RegKeyPath "$LoadedHivePolicies\ActiveDesktop" -AllowChange $AllowChange
        }
    }
     
	 Log -logstring "Going to Notify Windows that Wallpaper has been changed."
	#[Wallpaper.Setter]::SetWallpaper($Path)
	[Wallpaper.WMIBroadcast]::SettingChange()	 
	for($i = 0; $i -lt 5; $i++){ 
		Start-Process -FilePath "C:\Windows\System32\RUNDLL32.EXE" -ArgumentList "user32.dll,UpdatePerUserSystemParameters"
	}
    return $ERROR_SUCCESS
}

function DownloadWallpaper {
    param([Parameter(Mandatory=$true)][string]$ImageFileURL)
    
    $PathInfo=[System.Uri]$ImageFileURL

    if($PathInfo.IsUnc){
        Log -logstring  "Download Path is UNC: $ImageFileURL"
        $filename = $ImageFileURL.Substring($ImageFileURL.LastIndexOf("\") + 1)
        $DownloadPath = ($DownloadPath + $filename)
        Copy-Item $ImageFileURL -Destination $DownloadPath -Force
    }
    else {
        Log -logstring  "Download Path is URL: $ImageFileURL"
        [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls, [Net.SecurityProtocolType]::Tls11, [Net.SecurityProtocolType]::Tls12
        $Response = Invoke-WebRequest -Uri $ImageFileURL -UseBasicParsing
        if($Response){
            Log -logstring  "Got response"
            $ContentDisposition = $Response.Headers.'Content-Disposition'
            if($ContentDisposition){
                $filename = $ContentDisposition.Split("=")[1].Replace("`"","")        
            }
        }

        if([string]::IsNullOrEmpty($filename)){
                $filename = "CustomWallpaper.jpg" 
        }
		$DownloadPathWallpaper = ($DownloadPath + $filename)
		$DownloadPathNewWallpaper = ($DownloadPath + "NewCustomWallpaper.jpg")
		
		$DownloadPath = $DownloadPathWallpaper
		if(Test-Path $DownloadPathWallpaper) {
			$DownloadPath = $DownloadPathNewWallpaper
		}
		Remove-Item -Path "$DownloadPathWallpaper" -Force -Confirm:$false -ErrorAction SilentlyContinue
		Remove-Item -Path "$DownloadPathNewWallpaper" -Force -Confirm:$false -ErrorAction SilentlyContinue
		
        #$DownloadPath = ($DownloadPath + $filename)
        Invoke-WebRequest -Uri $ImageFileURL -OutFile $DownloadPath -UseBasicParsing
    }

    if(!(Test-Path $DownloadPath)){
        Log -logstring ("Error: Failed to download image file. Path: " + $DownloadPath)
        $DownloadPath = ""
        return $DownloadPath
    } 
    else {
        Log -logstring  "File downloaded at Path: $DownloadPath"
    }

    return $DownloadPath
}

function GetWallpaperStyle {

    $Style = ""
	if (IsOsWin8.1orGreather) {
		$Style = "3"
	}
	else {
		$Style = "6"
	}
    return $Style
}

try {
    Push-Location $ScriptRoot
    # Create Log directory
    CreateLogDir
    Log -logstring "Inside AddWallpaperOptions Script"
    ExitIfPSVersionLower
    
    $ReturnValue = $ERROR_FAILED
    $IsTile = "0"
    
    $Position = "Fit"
    $Action = "NewWallpaper"
    $Modify = "Yes"
    $ImageURL = "https://github.com/murtaza7869/Deploy/raw/master/Einstein-branded-wallpaper3.png"
  
    if(([string]::IsNullOrEmpty($Position)) -and ([string]::IsNullOrEmpty($Action))-and ([string]::IsNullOrEmpty($Modify))){
        
        Log -logstring "User selected to retain all wallpaper settings."
        $ReturnValue = $ERROR_SUCCESS
    }
    else{

        if(!([string]::IsNullOrEmpty($ImageURL))){
            $DownloadPath = DownloadWallpaper($ImageURL)
        }
        else {
            $DownloadPath = ""
        }
     
        $Style = GetWallpaperStyle
        if($Position -ieq "Tile"){
                $IsTile = "1"
        }
        
		# Essentially, Windows tends to not refresh its cached images. So, delete them first! 
		Log -logstring "Going to clear Windows cached images first!"
		Remove-Item -Path "$($env:APPDATA)\Microsoft\Windows\Themes\CachedFiles" -Recurse -Force -Confirm:$false -ErrorAction SilentlyContinue
		Remove-Item -Path "$($env:APPDATA)\Microsoft\Windows\Themes\*" -Recurse -Force -Confirm:$false -ErrorAction SilentlyContinue
		
		$ReturnValue = SetWallpaperOptions -Action $Action -Path $DownloadPath -Style $Style -IsTile $IsTile -AllowChange $Modify
		    
	}

    Log -logstring "Exit from AddWallpaperOptions Script with Exitcode = $ReturnValue `r`n`r`n"
    Exit $ReturnValue
}
finally {
    Pop-Location
}
