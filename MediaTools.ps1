<#
.Synopsis
Script used to download media from youtube and convert media file types.
.Description
You have options to: Download Youtube Songs and videos, and convert video and audio files into other formats using youtube-dl and ffmpeg in a user-friendly menu
#>
$currentDirectory = (Get-Location)
$version = .\yt-dlp.exe --version
function Show-Menu {
    Clear-Host
    Write-Host -BackgroundColor Blue -ForegroundColor Black "(Ctrl + C CANCELS ANY PROCESS GOING ON, may need to press twice)"
    Write-Host -BackgroundColor Blue -ForegroundColor Black "(If there are any issues, try selecting the UPDATE option)"
    Write-Host "Media Tools Menu"
    Write-Host "$currentDirectory"
    Write-Host "Youtube-dl Version: $version"
    Write-Host "1: Download Song"
    Write-Host "2: Download Video"
    Write-Host "3: Convert File"
    Write-Host "4: Youtube Video Thumbnail"
    Write-Host "5: Download Youtube Playlist (Specific Range, With Prefix #)"
    Write-Host "6: Update"
    Write-Host "7: Exit"
}


#Downloads songs in mp3 format
function Download-Song {
    $UserInput = Read-Host "Enter A Youtube Link"
    $link = $UserInput
    Write-Host -BackgroundColor Yellow -ForegroundColor Black "Downloading Song(s)"
    .\yt-dlp.exe -f bestaudio $link -o "\Downloads\%(title)s.%(ext)s"
    Write-Host -BackgroundColor Green -ForegroundColor Black "Downloading Song(s) Complete"
    AutoConvert-AudioFiles
}

#Downloads videos in mp4 format
function Download-Video {
    $UserInput = Read-Host "Enter A Youtube Link"
    $link = $UserInput
    Write-Host -BackgroundColor Yellow -ForegroundColor Black "Downloading Video(s)"
    .\yt-dlp.exe -f bestvideo+bestaudio $link -o "\Downloads\%(title)s.%(ext)s"
    Write-Host -BackgroundColor Green -ForegroundColor Black "Downloading Video(s) Complete"
    AutoConvert-VideoFiles
}

#Converts a file type in the current directory
function Convert-File {
    Write-Host "All files in the directory with the initial format will be converted to final format."
    $UserInput = Read-Host "Enter Initial Format"
    $formatOne = $UserInput
    $UserInput = Read-Host "Enter Final Format"
    $formatTwo = $UserInput
    $path = [string](Get-Location) + "\Downloads"
    Get-ChildItem -Path ($path) -Filter *.$formatOne |
    Foreach-Object {
        $name = "$_"
        $name = $name -replace ".$formatOne", ""
        .\ffmpeg.exe -i $path'\'$_ "$path\$name.$formatTwo"
    }
    Write-Host -BackgroundColor Green -ForegroundColor Black "Conversion Complete"
}

#Grabs youtube video thumbnail
function Grab-Thumbnail {
    Write-Host "1: Without Prefix Number (Single YT Vids)?"
    Write-Host "2: With Prefix Number (For YT Playlists)?"
    $UserInput = Read-Host 
    $link = Read-Host "Enter A Youtube Link"
    if ($UserInput -eq 1) { 
        Write-Host -BackgroundColor Yellow -ForegroundColor Black "Downloading Thumbnail(s)"
        .\yt-dlp.exe $link -o "\Downloads\%(title)s.%(ext)s" --write-thumbnail --skip-download 
        AutoConvert-ImageFiles
        Write-Host -BackgroundColor Green -ForegroundColor Black "Downloading Thumbnail(s) Complete"
    }
    elseif ($UserInput -eq 2) { 
        Write-Host "Playlist Range"
        $UserInput = Read-Host "Enter Starting Range"
        $start = $UserInput
        $UserInput = Read-Host "Enter Ending Range"
        $end = $UserInput
        Write-Host -BackgroundColor Yellow -ForegroundColor Black "Downloading Thumbnail(s)"
        .\yt-dlp.exe $link -o "\Downloads\%(playlist_index)s-%(title)s.%(ext)s" --playlist-start $start --playlist-end $end --write-thumbnail --skip-download 
        AutoConvert-ImageFiles
        Write-Host -BackgroundColor Green -ForegroundColor Black "Downloading Thumbnail(s) Complete"
    }
    else { "Invalid Input" }
    
}

#Updates youtube-dl
function Update-Youtube {
    .\yt-dlp.exe -U
}

#Downloads Youtube Playlist in mp3 format, asks for range of songs (if range is out of bounds only downloads the songs within available range)
function Download-Playlist {
    $UserInput = Read-Host "Enter A Youtube Playlist Link"
    $link = $UserInput
    $UserInput = Read-Host "Enter Starting Range"
    $start = $UserInput
    $UserInput = Read-Host "Enter Ending Range"
    $end = $UserInput
    Write-Host -BackgroundColor Yellow -ForegroundColor Black "Downloading Song(s)"
    .\yt-dlp.exe -f bestaudio $link -o "\Downloads\%(playlist_index)s-%(title)s.%(ext)s" --playlist-start $start --playlist-end $end
    Write-Host -BackgroundColor Green -ForegroundColor Black "Downloading Song(s) Complete"
    AutoConvert-AudioFiles
}

#Helper method to convert downloaded audio files
function AutoConvert-AudioFiles {
    
    Write-Host -BackgroundColor Yellow -ForegroundColor Black "Converting Audio Files"
    $path = [string](Get-Location) + "\Downloads"
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
#Helper method to convert downloaded video files
function AutoConvert-VideoFiles {
    Write-Host -BackgroundColor Yellow -ForegroundColor Black "Converting Video Files"
    $path = [string](Get-Location) + "\Downloads"
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
    Remove-Item $path\*.webm
    Remove-Item $path\*.m4a
    Write-Host -BackgroundColor Green -ForegroundColor Black "Video Files Converted"
}
#Helper method to convert downloaded image files
function AutoConvert-ImageFiles {
    Write-Host -BackgroundColor Green "CONVERTING IMAGE FILES"
    $path = [string](Get-Location) + "\Downloads"
    Get-ChildItem -Path ($path) -Filter *.webp |
    Foreach-Object {
        $name = "$_"
        $name = $name -replace ".webp", ""
        .\ffmpeg.exe -i $path'\'$_ "$path\$name.jpg"
    }
    Remove-Item $path\*.webp
}

do {
    Set-WindowSize
    Show-Menu
    $UserInput = Read-Host "Choose a choice by typing the number"

    if ($UserInput -eq 1) { Download-Song }
    elseif ($UserInput -eq 2) { Download-Video }
    elseif ($UserInput -eq 3) { Convert-File }
    elseif ($UserInput -eq 4) { Grab-Thumbnail }
    elseif ($UserInput -eq 5) { Download-Playlist }
    elseif ($UserInput -eq 6) { Update-Youtube }
    elseif ($UserInput -eq 7) { 'Exiting...' }
    else { "Invalid Input" }
    if ($UserInput -ne 7) {
        pause
    }
    
}
until ($UserInput -eq '7')