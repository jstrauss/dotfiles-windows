$machineName    = "PROMETHEUS"

# Get the ID and security principal of the current user account
$myIdentity=[System.Security.Principal.WindowsIdentity]::GetCurrent()
$myPrincipal=new-object System.Security.Principal.WindowsPrincipal($myIdentity)

# Check to see if we are currently running "as Administrator"
if (!$myPrincipal.IsInRole([System.Security.Principal.WindowsBuiltInRole]::Administrator)) {
   $newProcess = new-object System.Diagnostics.ProcessStartInfo "PowerShell";
   $newProcess.Arguments = $myInvocation.MyCommand.Definition;
   $newProcess.Verb = "runas";
   [System.Diagnostics.Process]::Start($newProcess);

   exit
}

## Set DisplayName for my account
## Useful for setting up Account information if you are not using a Microsoft Account
#$userFullName   = "Jeff Strauss"
#$user = Get-WmiObject Win32_UserAccount | Where {$_.Caption -eq $myIdentity.Name}
#$user.FullName = $userFullName
#$user.Put() | Out-Null
#Remove-Variable userFullName
#Remove-Variable user

# Set Computer Name
(Get-WmiObject Win32_ComputerSystem).Rename($machineName) | Out-Null

Remove-Variable machineName
Remove-Variable myPrincipal
Remove-Variable myIdentity


# HKUsers drive for Registry
if ((Get-PSDrive HKUsers -ErrorAction SilentlyContinue) -eq $null) { New-PSDrive -Name HKUSERS -PSProvider Registry -Root Registry::HKEY_USERS | Out-Null }


### Devices, Power, and Startup
### --------------------------

# Sound: Disable Startup Sound
Set-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" "DisableStartupSound" 1
Set-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Authentication\LogonUI\BootAnimation" "DisableStartupSound" 1

# Power: Disable Hibernation
powercfg /hibernate off

# Power Set standby delay to 24 hours
powercfg /change /standby-timeout-ac 1440

# SSD: Disable SuperFetch
Set-ItemProperty "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management\PrefetchParameters" "EnableSuperfetch" 0

# Network: Disable WiFi Sense. 0=Disabled, 1=Enabled
Set-ItemProperty "HKLM:\SOFTWARE\Microsoft\WcmSvc\wifinetworkmanager\config" "AutoConnectAllowedOEM" 0


### Explorer, Taskbar, and System Tray
### --------------------------
if (!(Test-Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer")) {New-Item -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" -Type Folder | Out-Null}
if (!(Test-Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\CabinetState")) {New-Item -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\CabinetState" -Type Folder | Out-Null}
if (!(Test-Path "HKLM:\Software\Policies\Microsoft\Windows\Windows Search")) {New-Item -Path "HKLM:\Software\Policies\Microsoft\Windows\Windows Search" -Type Folder | Out-Null}

# Explorer: Show hidden files by default (1: Show Files, 2: Hide Files)
Set-ItemProperty "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" "Hidden" 1

# Explorer: show file extensions by default (0: Show Extensions, 1: Hide Extensions)
Set-ItemProperty "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" "HideFileExt" 0

# Explorer: show path in title bar
Set-ItemProperty "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\CabinetState" "FullPath" 1

# Explorer: Avoid creating Thumbs.db files on network volumes
Set-ItemProperty "HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" "DisableThumbnailsOnNetworkFolders" 1

# Taskbar: use small icons (0: Large Icons, 1: Small Icons)
Set-ItemProperty "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" "TaskbarSmallIcons" 1

# Taskbar: Don't show Windows Store Apps on Taskbar
Set-ItemProperty "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" "StoreAppsOnTaskbar" 0

# Taskbar: Disable Bing Search
# Set-ItemProperty "HKCU:\Software\Microsoft\Windows\CurrentVersion\ConnectedSearch" "ConnectedSearchUseWeb" 0 # For Windows 8.1
Set-ItemProperty "HKCU:\Software\Microsoft\Windows\CurrentVersion\Search" "BingSearchEnabled" 0 # For Windows 10

# Taskbar: Disable Cortana
Set-ItemProperty "HKLM:\Software\Policies\Microsoft\Windows\Windows Search" "AllowCortana" 0

# SysTray: hide the Action Center, Network, and Volume icons
Set-ItemProperty "HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" "HideSCAHealth" 1  # Action Center
Set-ItemProperty "HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" "HideSCANetwork" 1 # Network
#Set-ItemProperty "HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" "HideSCAVolume" 1  # Volume
#Set-ItemProperty "HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" "HideSCAPower" 1  # Power

# Recycle Bin: Disable Delete Confirmation Dialog
Set-ItemProperty "HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" "ConfirmFileDelete" 0


### Lock Screen
### --------------------------

## Enable Custom Background on the Login / Lock Screen
## Background file: C:\someDirectory\someImage.jpg
## File Size Limit: 256Kb
# Set-ItemProperty "HKLM:\Software\Policies\Microsoft\Windows\Personalization" "LockScreenImage" "C:\someDirectory\someImage.jpg"


### Accessibility
### --------------------------

# Turn Off Windows Narrator
if (!(Test-Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\Narrator.exe")) {New-Item -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\Narrator.exe" -Type Folder | Out-Null}
Set-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\Narrator.exe" "Debugger" "%1"


### Windows Update
### --------------------------

if (!(Test-Path "HKLM:\Software\Policies\Microsoft\Windows\WindowsUpdate")) {New-Item -Path "HKLM:\Software\Policies\Microsoft\Windows\WindowsUpdate" -Type Folder | Out-Null}
if (!(Test-Path "HKLM:\Software\Policies\Microsoft\Windows\WindowsUpdate\AU")) {New-Item -Path "HKLM:\Software\Policies\Microsoft\Windows\WindowsUpdate\AU" -Type Folder | Out-Null}

# Windows Update: Enable Automatic Updates. 0=Enabled, 1=Disabled
Set-ItemProperty "HKLM:\Software\Policies\Microsoft\Windows\WindowsUpdate\AU" "NoAutoUpdate" 0

# Windows Update: Don't automatically reboot after install
Set-ItemProperty "HKLM:\Software\Policies\Microsoft\Windows\WindowsUpdate" "NoAutoRebootWithLoggedOnUsers" 1d
Set-ItemProperty "HKLM:\Software\Policies\Microsoft\Windows\WindowsUpdate\AU" "NoAutoRebootWithLoggedOnUsers" 1

# Windows Update: Auto-Download but not Install. 0=NotConfigured, 1=Disabled, 2=NotifyBeforeDownload, 3=NotifyBeforeInstall, 4=ScheduledInstall
Set-ItemProperty "HKLM:\Software\Policies\Microsoft\Windows\WindowsUpdate\AU" "AUOptions" 3

# Windows Update: Include Recommended Updates
Set-ItemProperty "HKLM:\Software\Policies\Microsoft\Windows\WindowsUpdate\AU" "IncludeRecommendedUpdates" 1

# Windows Update: Opt-In to Microsoft Update
$MU = New-Object -ComObject Microsoft.Update.ServiceManager -Strict
$MU.AddService2("7971f918-a847-4430-9279-4a52d1efe18d",7,"") | Out-Null
Remove-Variable MU


### Internet Explorer
### --------------------------

# Set home page to `about:blank` for faster loading
Set-ItemProperty "HKCU:\Software\Microsoft\Internet Explorer\Main" "Start Page" "about:blank"


### PowerShell Console
### --------------------------

# Custom Path for PSReadLine Settings
if (!(Test-Path "HKCU:\Console\PSReadLine")) {New-Item -Path "HKCU:\Console\PSReadLine" -Type Folder | Out-Null}

$settings = @{
# Console: Dimensions of window, in characters. (8-byte; 4b height, 4b width. Max: 0x7FFF7FFF (32767h x 32767w))
"WindowSize"           = 0x00320078; # 50h x 120w
# Console: Dimensions of screen buffer in memory, in characters. (8-byte; 4b height, 4b width. Max: 0x7FFF7FFF (32767h x 32767w))
"ScreenBufferSize"     = 0x0BB80078; # 3000h x 120w
# Console: Percentage of Character Space for Cursor (25: Small, 50: Medium, 100: Large)
"CursorSize"           = 100; # 100
# Console: Name of display font (TrueType)
"FaceName"             = "Lucida Console";
# Console: Font Family. (0: Raster, 54: TrueType)
"FontFamily"           = 54;
# Console: Dimensions of font character in pixels. (8-byte; 4b height, 4b width. 0: Auto)
"FontSize"             = 0x000F0000; # 15px height x auto width
# Console: Boldness of font. Raster=(0: Normal, 1: Bold). TrueType=(100-900, 400: Normal)
"FontWeight"           = 400;
# Console: Number of commands in history buffer. (50: Default)
"HistoryBufferSize"    = 50;
# Console: Discard duplicate commands (0: Disabled, 1: Enabled)
"HistoryNoDup"         = 1;
# Console: Typing Mode. (0: Overtype, 1: Insert)
"InsertMode"           = 1;
# Console: Allow Copy/Paste using Mouse (0: Disabled, 1:Enabled)
"QuickEdit"            = 1;
# Console: Colors for Window. (8-byte; 4b background, 4b foreground. 0-15: Color, 0x07: Default)
"ScreenColors"         = 0x0F;
# Console: Colors for Popup Windows. (8-byte; 4b background, 4b foreground. 0-15: Color, 0xF7: Default)
"PopupColors"          = 0xF0;

# Console: The 16 colors in the Console color well (BGR).
# Jellybeans
"ColorTable00"         = Convert-ConsoleColor "#151515"; # Black (0)
"ColorTable01"         = Convert-ConsoleColor "#8197bf"; # DarkBlue (1)
"ColorTable02"         = Convert-ConsoleColor "#437019"; # DarkGreen (2)
"ColorTable03"         = Convert-ConsoleColor "#556779"; # DarkCyan (3)
"ColorTable04"         = Convert-ConsoleColor "#902020"; # DarkRed (4)
"ColorTable05"         = Convert-ConsoleColor "#540063"; # DarkMagenta (5)
"ColorTable06"         = Convert-ConsoleColor "#dad085"; # DarkYellow (6)
"ColorTable07"         = Convert-ConsoleColor "#888888"; # Gray (7)
"ColorTable08"         = Convert-ConsoleColor "#606060"; # DarkGray (8)
"ColorTable09"         = Convert-ConsoleColor "#7697d6"; # Blue (9)
"ColorTable10"         = Convert-ConsoleColor "#99ad6a"; # Green (A)
"ColorTable11"         = Convert-ConsoleColor "#c6b6ee"; # Cyan (B)
"ColorTable12"         = Convert-ConsoleColor "#cf6a4c"; # Red (C)
"ColorTable13"         = Convert-ConsoleColor "#f0a0c0"; # Magenta (D)
"ColorTable14"         = Convert-ConsoleColor "#fad07a"; # Yellow (E)
"ColorTable15"         = Convert-ConsoleColor "#e8e8d3"; # White (F)
}

# PSReadLine: Normal syntax color. vim Normal group. (Default: Foreground)
Set-ItemProperty "HKCU:\Console\PSReadLine" "NormalForeground" 0xF
# PSReadLine: Comment Token syntax color. vim Comment group. (Default: 0x2)
Set-ItemProperty "HKCU:\Console\PSReadLine" "CommentForeground" 0x7
# PSReadLine: Keyword Token syntax color. vim Statement group. (Default: 0xA)
Set-ItemProperty "HKCU:\Console\PSReadLine" "KeywordForeground" 0x1
# PSReadLine: String Token syntax color. vim String [or Constant] group. (Default: 0x3)
Set-ItemProperty "HKCU:\Console\PSReadLine" "StringForeground"  0xA
# PSReadLine: Operator Token syntax color. vim Operator [or Statement] group. (Default: 0x8)
Set-ItemProperty "HKCU:\Console\PSReadLine" "OperatorForeground" 0xB
# PSReadLine: Variable Token syntax color. vim Identifier group. (Default: 0xA)
Set-ItemProperty "HKCU:\Console\PSReadLine" "VariableForeground" 0xB
# PSReadLine: Command Token syntax color. vim Function [or Identifier] group. (Default: 0xE)
Set-ItemProperty "HKCU:\Console\PSReadLine" "CommandForeground" 0x1
# PSReadLine: Parameter Token syntax color. vim Normal group. (Default: 0x8)
Set-ItemProperty "HKCU:\Console\PSReadLine" "ParameterForeground" 0xF
# PSReadLine: Type Token syntax color. vim Type group. (Default: 0x7)
Set-ItemProperty "HKCU:\Console\PSReadLine" "TypeForeground" 0xE
# PSReadLine: Number Token syntax color. vim Number [or Constant] group. (Default: 0xF)
Set-ItemProperty "HKCU:\Console\PSReadLine" "NumberForeground" 0xC
# PSReadLine: Member Token syntax color. vim Function [or Identifier] group. (Default: 0x7)
Set-ItemProperty "HKCU:\Console\PSReadLine" "MemberForeground" 0xE
# PSReadLine: Emphasis syntax color. vim Search group. (Default: 0xB)
Set-ItemProperty "HKCU:\Console\PSReadLine" "EmphasisForeground" 0xD
# PSReadLine: Error syntax color. vim Error group. (Default: 0xC)
Set-ItemProperty "HKCU:\Console\PSReadLine" "ErrorForeground" 0x4

$registryPaths=@(`
"HKCU:\Console\%SystemRoot%_System32_WindowsPowerShell_v1.0_powershell.exe",`
"HKCU:\Console\%SystemRoot%_SysWOW64_WindowsPowerShell_v1.0_powershell.exe",`
"HKCU:\Console\Windows PowerShell (x86)",`
"HKCU:\Console\Windows PowerShell"`
)

$registryPaths | ForEach {
    If (!(Test-Path $_)) {
        New-Item -path $_ -ItemType Folder | Out-Null
    }

    ForEach ($setting in $settings.GetEnumerator()) {
        Set-ItemProperty -Path $_ -Name $($setting.Name) -Value $($setting.Value)
    }
}

Reset-AllPowerShellShortcuts

echo "Done. Note that some of these changes require a logout/restart to take effect."
