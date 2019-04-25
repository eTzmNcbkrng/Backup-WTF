#Script to backup WTF folder once per day

#region Script Variables
$7Zipcli = Get-Item 'C:\Program Files\7-Zip\7z.exe' -ErrorAction SilentlyContinue
$WarcraftPath = Get-Item 'D:\World of Warcraft\Retail\_retail_' -ErrorAction SilentlyContinue
$ArchiveFolder = "Backups"
$Date = Get-Date -UFormat %Y-%m-%d #Date format to use in filename
#endregion

function Create-DirStructure {
	param($Path)
	if (!(Test-Path "$Path")) {
		New-Item "$Path" -ItemType Directory
	}
}


if ($7Zipcli -eq $null) {
    "7-Zip not found - exiting"
    break
}
if ((Get-Item "$($WarcraftPath.FullName)\Wow.exe" -ErrorAction SilentlyContinue) -eq $null) {
    "WoW.exe not found - exiting"
    break
}

$WoWVersion = (Get-Item "$($WarcraftPath.FullName)\Wow.exe").VersionInfo.FileVersion.Split(".") #Full WoW Version
$WoWVersionMajor = $WoWVersion[0]
$WoWVersionMinor = $WoWVersion[1]
$WoWVersionPatch = $WoWVersion[2]
$WoWVersionBuild = $WoWVersion[3]

#region Expansion Mapping
 switch ($WoWVersionMajor) {
	1 {$Expac = "Classic"}
	2 {$Expac = "BC"}
	3 {$Expac = "WotLK"}
	4 {$Expac = "Cata"}
	5 {$Expac = "MoP"}
	6 {$Expac = "WoD"}
	7 {$Expac = "Legion"}
	8 {$Expac = "BfA"}
	9 {$Expac = "Tiamat's Revenge"}
}
#endregion

$ArchivePath = "$WarcraftPath\$ArchiveFolder"
Create-DirStructure "$ArchivePath"

$ArchivePath = "$ArchivePath\$Expac"
Create-DirStructure "$ArchivePath"

$ArchivePath = "$ArchivePath\$WoWVersionMajor.$WoWVersionMinor.$WoWVersionPatch"
Create-DirStructure "$ArchivePath"

$ArchiveFile = "$ArchivePath\$($WoWVersionBuild + "-" + $Date).7z"

if (!(Test-Path $ArchiveFile)) {
    & "$7Zipcli" a "$ArchiveFile" "$($WarcraftPath.FullName)\WTF" -r "-x!*.bak" "-x!*.old" "-x!*.md5"  -snh -snl #Symlinks can be archived on Windows (-snh) but not extracted
}
else {
    "WTF Folder already backed up today"
}
