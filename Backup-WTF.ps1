#Script to backup WTF folder once per day

#region Script Variables
$7Zipcli = Get-Item 'C:\Program Files\7-Zip\7z.exe' -ErrorAction SilentlyContinue
$WarcraftDir = Get-Item 'D:\World of Warcraft' -ErrorAction SilentlyContinue
$ArchiveLocation = "WTF Backups"
$Date = Get-Date -UFormat %Y-%m-%d #Date format to use in filename
#endregion


if ($7Zipcli -eq $null) {
    "7-Zip not found - exiting"
    "Please download 7-zip from http://www.7-zip.org"
    "Press any key to exit ..."
    $x = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    break
}
if ((Get-Item "$($WarcraftDir.FullName)\Wow.exe" -ErrorAction SilentlyContinue) -eq $null) {
    "WoW.exe not found - exiting"
    'Please review $WarcraftDir variable in line 5'
    $x = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    break
}

$WoWVersion = (Get-Item "$($WarcraftDir.FullName)\Wow.exe").VersionInfo.FileVersion.Split(".") #Full WoW Version
$WoWVersionMajor = $WoWVersion[0]
$WoWVersionMinor = $WoWVersion[1]
$WoWVersionPatch = $WoWVersion[2]
$WoWVersionBuild = $WoWVersion[3]
$WoWVersionDir = $WoWVersionMajor + "." + $WoWVersionMinor + "." + $WoWVersionPatch

#$WoWVersion.Substring(0,$WoWVersion.LastIndexOf(".")) #WoWVersion excluding Build number

#region Check directory structure exists, create if not
if (!(Test-Path "$($WarcraftDir.FullName)\$ArchiveLocation")) {
    New-Item "$($WarcraftDir.FullName)\$ArchiveLocation" -ItemType Directory
}

if (!(Test-Path "$($WarcraftDir.FullName)\$ArchiveLocation\$WoWVersionDir")){
    New-Item "$($WarcraftDir.FullName)\$ArchiveLocation\$WoWVersionDir" -ItemType Directory
}
#endregion


$ArchiveFolder = "$($WarcraftDir.FullName)\$ArchiveLocation\$WoWVersionDir"
$ArchiveFile = "$ArchiveFolder\$($WoWVersionBuild + "-" + $Date).7z"

if (!(Test-Path $ArchiveFile)) {
    & "$7Zipcli" a "$ArchiveFile" "$($WarcraftDir.FullName)\WTF" -r "-x!*.bak" "-x!*.old" "-x!*.md5"  -snh -snl #Symlinks can be archived on Windows (-snh) but not extracted
}
else {
    "WTF Folder already backed up today"
}
