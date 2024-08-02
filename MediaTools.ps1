<#
.Synopsis
Script used to download media from youtube and convert media file types.
.Description
You have options to: Download Youtube Songs and videos, and convert video and audio files into other formats using youtube-dl and ffmpeg in a simple menu
#>
$currentDirectory = (Get-Location)
$version = .\yt-dlp.exe --version
function Show-Menu {
    Clear-Host
    Write-Host -BackgroundColor Blue -ForegroundColor Black "(Ctrl + C CANCELS ANY PROCESS GOING ON, may need to press twice)"
    Write-Host -BackgroundColor Blue -ForegroundColor Black "(If there are any issues, try selecting the UPDATE (7) option)"
    Write-Host "Media Tools Menu"
    Write-Host "$currentDirectory"
    Write-Host "Youtube-dl Version: $version"
    Write-Host "1: Download Audio"
    Write-Host "2: Download Video"
    Write-Host "3: Download Thumbnail"
    Write-Host "4: Download Youtube Playlist (Adds Prefix # to filename (playlist order), Specific Range)"
    Write-Host "5: Convert File"
    Write-Host "6: Custom Commands List"
    Write-Host "7: Update"
    Write-Host "8: Exit"
}


# 1 Downloads songs in mp3 format
function Download-Song {
    $UserInput = Read-Host "Enter A Youtube Link"
    $link = $UserInput
    Write-Host -BackgroundColor Yellow -ForegroundColor Black "Downloading Song(s)"
    .\yt-dlp.exe -f bestaudio --audio-format mp3 $link -o "\Downloads\%(title)s.%(ext)s"
    Write-Host -BackgroundColor Green -ForegroundColor Black "Downloading Song(s) Complete"
    AutoConvert-AudioFiles
}

# 2 Downloads videos in mp4 format
function Download-Video {
     Write-Host "1: H.264, 1080p Max"
    Write-Host "2: VP9, 4k Max"
    $UserInput = Read-Host
    $type = $UserInput
    if (($type -ne 1) -and ($type -ne 2)) { 
        Write-Host "Invalid Input"
        Return
    }

    $UserInput = Read-Host "Enter A Youtube Link"
    $link = $UserInput
    Write-Host -BackgroundColor Yellow -ForegroundColor Black "Downloading Video(s)"
    # -S "+codec:h264" 
    if ($type -eq 1) {
        .\yt-dlp.exe -S "+codec:h264" -f bestvideo+bestaudio $link -o "\Downloads\%(title)s.%(ext)s"
    }
    if ($type -eq 2) {
        .\yt-dlp.exe -f bestvideo+bestaudio $link -o "\Downloads\%(title)s.%(ext)s"
    }
    Write-Host -BackgroundColor Green -ForegroundColor Black "Downloading Video(s) Complete"
    AutoConvert-VideoFiles
}

# 3 Grabs youtube video thumbnail
function Grab-Thumbnail {
    $link = Read-Host "Enter A Youtube Link"
    Write-Host -BackgroundColor Yellow -ForegroundColor Black "Downloading Thumbnail(s)"
    .\yt-dlp.exe $link -o "\Downloads\%(title)s.%(ext)s" --write-thumbnail --skip-download 
    AutoConvert-ImageFiles
    Write-Host -BackgroundColor Green -ForegroundColor Black "Downloading Thumbnail(s) Complete"    
}

# 4 Downloads Youtube Playlist in mp3 format, asks for range of songs (if range is out of bounds only downloads the songs within available range)
function Download-Playlist {
    Write-Host "1: Audio"
    Write-Host "2: Video"
    Write-Host "3: Thumbnail"
    $UserInput = Read-Host
    $type = $UserInput
    if (($type -ne 1) -and ($type -ne 2) -and ($type -ne 3)) { 
        Write-Host "Invalid Input"
        Return
    }
    $UserInput = Read-Host "Enter A Youtube Playlist Link"
    $link = $UserInput
    $UserInput = Read-Host "Enter Custom Prefix # (Usually 1)"
    $autonumber = $UserInput
    $UserInput = Read-Host "Enter Starting Range"
    $start = $UserInput
    $UserInput = Read-Host "Enter Ending Range"
    $end = $UserInput
    Write-Host -BackgroundColor Yellow -ForegroundColor Black "Downloading Song(s)"
    if ($type -eq 1) {
        .\yt-dlp.exe -f bestaudio $link -o "\Downloads\%(autonumber)0d-%(title)s.%(ext)s" --playlist-start $start --playlist-end $end --autonumber-start $autonumber
        AutoConvert-AudioFiles
    }
    if ($type -eq 2) {
        .\yt-dlp.exe -f bestvideo+bestaudio $link -o "\Downloads\%(autonumber)0d-%(title)s.%(ext)s" --playlist-start $start --playlist-end $end --autonumber-start $autonumber
        AutoConvert-VideoFiles
    }
    if ($type -eq 3) {
        .\yt-dlp.exe $link -o "\Downloads\%(autonumber)0d-%(title)s.%(ext)s" --playlist-start $start --playlist-end $end  --autonumber-start $autonumber --write-thumbnail --skip-download 
        AutoConvert-ImageFiles
    }
    Write-Host -BackgroundColor Green -ForegroundColor Black "Downloading Song(s) Complete"
}

# 5 Converts a file type in the current directory
function Convert-File {
    Write-Host "All files in the directory with the initial format will be converted to final format. (.\Downloads\NewFileFormat\)"
    Write-Host "1: Custom Extension"
    Write-Host "2: VP9 To H.264 Compression"
    $UserInput = Read-Host
    $type = $UserInput
    if (($type -ne 1) -and ($type -ne 2)) { 
        Write-Host "Invalid Input"
        Return
    }
    $path = [string](Get-Location) + "\Downloads"
    if ($type -eq 1) {
        $UserInput = Read-Host "Enter Initial Format"
        $formatOne = $UserInput
        $UserInput = Read-Host "Enter Final Format"
        $formatTwo = $UserInput
        Get-ChildItem -Path ($path) -Filter *.$formatOne |
        Foreach-Object {
            $name = "$_"
            $name = $name -replace ".$formatOne", ""
            .\ffmpeg.exe -i $path'\'$_ "$path\NewFileFormat\$name.$formatTwo"
        }
    }
    if ($type -eq 2) {
        Get-ChildItem -Path ($path) -Filter *.mp4 |
        Foreach-Object {
            $name = "$_"
            $name = $name -replace ".mp4", ""
            .\ffmpeg.exe -i $path'\'$_ -vcodec libx264 -acodec aac "$path\NewFileFormat\$name.mp4"
        }
    }# -vcodec libx264 -acodec aac
    Write-Host -BackgroundColor Green -ForegroundColor Black "Conversion Complete"
}

function Custom-Commands-List {
    Clear-Host
    Write-Host -BackgroundColor Blue -ForegroundColor Black "Command Example ($ means input variable): "
    
    Write-Host -BackgroundColor Red -ForegroundColor Black "Start Command (Mandatory)" -NoNewLine
    Write-Host -BackgroundColor Cyan -ForegroundColor Black 'Download Type (Optional/Raw File)' -NoNewLine
    Write-Host -BackgroundColor Green -ForegroundColor Black 'Media Link (Mandatory)' -NoNewLine
    Write-Host -BackgroundColor Yellow -ForegroundColor Black "Location, Structure (Optional)"

    Write-Host -BackgroundColor Red -ForegroundColor Black "yt-dlp.exe " -NoNewLine
    Write-Host -BackgroundColor Cyan -ForegroundColor Black "-f bestaudio " -NoNewLine
    Write-Host -BackgroundColor Green -ForegroundColor Black '$link ' -NoNewLine
    Write-Host -BackgroundColor Yellow -ForegroundColor Black '-o "\Downloads\%(title)s.%(ext)s"'

    Write-Host
    Write-Host -BackgroundColor Blue -ForegroundColor Black "Extension Options"
    Write-Host -BackgroundColor Cyan -ForegroundColor Black "-f bestaudio "
    Write-Host -BackgroundColor Cyan -ForegroundColor Black "-f bestvideo "
    Write-Host -BackgroundColor Cyan -ForegroundColor Black "-f bestaudio + bestvideo "
    Write-Host 
    Write-Host -BackgroundColor DarkMagenta -ForegroundColor Black "--cookies-from-browser [brave, chrome, chromium, edge, firefox, opera, safari] "
    Write-Host -BackgroundColor DarkMagenta -ForegroundColor Black '--add-header $link '
    Write-Host -BackgroundColor DarkMagenta -ForegroundColor Black '--autonumber-start $number '
    Write-Host -BackgroundColor DarkMagenta -ForegroundColor Black '--playlist-start $start '
    Write-Host -BackgroundColor DarkMagenta -ForegroundColor Black '--playlist-end $end '
    Write-Host
    Write-Host -BackgroundColor Yellow -ForegroundColor Black '-o "\Downloads\%(title)s.%(ext)s"'
    Write-Host -BackgroundColor Yellow -ForegroundColor Black '-o "%(autonumber)0Nd-%(title)s.%(ext)s"'
    Write-Host

    Write-Host -BackgroundColor Blue -ForegroundColor Black "More Examples"
    Write-Host -BackgroundColor Red -ForegroundColor Black "yt-dlp.exe " -NoNewLine
    Write-Host -BackgroundColor Cyan -ForegroundColor Black "-f bestaudio " -NoNewLine
    Write-Host -BackgroundColor DarkMagenta -ForegroundColor Black '--autonumber-start $number ' -NoNewLine
    Write-Host -BackgroundColor DarkMagenta -ForegroundColor Black '--playlist-start $start ' -NoNewLine
    Write-Host -BackgroundColor DarkMagenta -ForegroundColor Black '--playlist-end $end ' -NoNewLine
    Write-Host -BackgroundColor Green -ForegroundColor Black '$link ' -NoNewLine
    Write-Host -BackgroundColor Yellow -ForegroundColor Black '-o "\Downloads\%(autonumber)0d-%(title)s.%(ext)s"'

    Write-Host -BackgroundColor Red -ForegroundColor Black "yt-dlp.exe " -NoNewLine
    Write-Host -BackgroundColor DarkMagenta -ForegroundColor Black '--add-header "Referer: https://girlsfrontline.kr/db/musicplayer/" ' -NoNewLine
    Write-Host -BackgroundColor DarkMagenta -ForegroundColor Black '-a templist.txt ' -NoNewLine
    Write-Host -BackgroundColor Yellow -ForegroundColor Black '-o "%(autonumber)03d-(%(id)s).%(ext)s"'
}

# 7 Updates youtube-dl
function Update-Youtube {
    .\yt-dlp.exe -U
    $script:version = .\yt-dlp.exe --version
}



#Helper method (1,5) to convert downloaded audio files
function AutoConvert-AudioFiles {
    $path = [string](Get-Location) + "\Downloads"
    $AudioFileCount = (Get-ChildItem -Path ($path+"\*.webm") | Measure-Object ).Count + (Get-ChildItem -Path ($path+"\*.m4a") | Measure-Object ).Count
    Write-Host "webm/m4a file count: "$AudioFileCount
    if ($AudioFileCount -eq 0) { 
        Write-Host "No files to convert"
        Return
    }
    Write-Host -BackgroundColor Yellow -ForegroundColor Black "Converting Audio Files"
    Get-ChildItem -Path ($path) -Filter *.webm |
    Foreach-Object {
        $name = "$_"
        $name = $name -replace ".webm", ""
        # $path'\'$_ is directory + \ + filename (location\file to be converted)
        # "$path\$name.mp3" is directory + \ + filenametobeconverted (location\named and command to convert to mp3)
        .\ffmpeg.exe -i $path'\'$_ "$path\$name.mp3" 
    }
    Get-ChildItem -Path ($path) -Filter *.m4a |
    Foreach-Object {
        $name = "$_"
        $name = $name -replace ".m4a", ""
        .\ffmpeg.exe -i $path'\'$_ "$path\$name.mp3"
    }
    Remove-Item $path\*.webm
    Remove-Item $path\*.m4a
    Write-Host -BackgroundColor Green -ForegroundColor Black "Audio Files Converted"
}
#Helper method (2) to convert downloaded video files
function AutoConvert-VideoFiles {
    $path = [string](Get-Location) + "\Downloads"
    $VideoFileCount = (Get-ChildItem -Path ($path+"\*.webm") | Measure-Object ).Count + (Get-ChildItem -Path ($path+"\*.m4a") | Measure-Object ).Count + (Get-ChildItem -Path ($path+"\*.mkv") | Measure-Object ).Count
    Write-Host "webm/m4a/mkv file count: "$VideoFileCount
    if ($VideoFileCount -eq 0) { 
        Write-Host "No files to convert"
        Return
    }
    Write-Host -BackgroundColor Yellow -ForegroundColor Black "Converting Video Files"
    Get-ChildItem -Path ($path) -Filter *.webm |
    Foreach-Object {
        $name = "$_"
        $name = $name -replace ".webm", ""
        .\ffmpeg.exe -i $path'\'$_ "$path\$name.mp4"
    }
    Get-ChildItem -Path ($path) -Filter *.m4a |
    Foreach-Object {
        $name = "$_"
        $name = $name -replace ".m4a", ""
        .\ffmpeg.exe -i $path'\'$_ "$path\$name.mp4"
    }
    Get-ChildItem -Path ($path) -Filter *.mkv |
    Foreach-Object {
        $name = "$_"
        $name = $name -replace ".mkv", ""
        .\ffmpeg.exe -i $path'\'$_ "$path\$name.mp4"
    }
    Remove-Item $path\*.webm
    Remove-Item $path\*.m4a
    Remove-Item $path\*.mkv
    Write-Host -BackgroundColor Green -ForegroundColor Black "Video Files Converted"
}
#Helper method (4) to convert downloaded image files
function AutoConvert-ImageFiles {
    $path = [string](Get-Location) + "\Downloads"
    $ImageFileCount = (Get-ChildItem -Path ($path+"\*.webp") | Measure-Object ).Count
    Write-Host "webp file count: "$ImageFileCount
    if ($ImageFileCount -eq 0) { 
        Write-Host "No files to convert"
        Return
    }
    Write-Host -BackgroundColor Yellow -ForegroundColor Black "CONVERTING IMAGE FILES"
    Get-ChildItem -Path ($path) -Filter *.webp |
    Foreach-Object {
        $name = "$_"
        $name = $name -replace ".webp", ""
        .\ffmpeg.exe -i $path'\'$_ "$path\$name.jpg"
    }
    Remove-Item $path\*.webp
    Write-Host -BackgroundColor Green -ForegroundColor Black "Image Files Converted"
}


#Menu Execution
do {
    $host.UI.RawUI.WindowSize = New-Object System.Management.Automation.Host.size(100,30)
    Show-Menu
    $UserInput = Read-Host "Choose a choice by typing the corresponding number"

    if ($UserInput -eq 1) { Download-Song }
    elseif ($UserInput -eq 2) { Download-Video }
    elseif ($UserInput -eq 3) { Grab-Thumbnail }
    elseif ($UserInput -eq 4) { Download-Playlist }
    elseif ($UserInput -eq 5) { Convert-File }
    elseif ($UserInput -eq 6) { Custom-Commands-List }
    elseif ($UserInput -eq 7) { Update-Youtube $version = .\yt-dlp.exe --version }
    elseif ($UserInput -eq 8) { 'Exiting...' }
    else { "Invalid Input" }
    if ($UserInput -ne 8) {
        pause
    }
    
}
until ($UserInput -eq '8')