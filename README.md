# Powershell Interface for yt-dlp/Other Media Tools

## Tools
- Download Youtube
  - Songs
  - Videos
  - Thumbnails
  - Playlists
- Convert files

## How To Setup
- Place MediaTools.ps1 into a folder
- make a new folder in the same directory - .\Downloads\
- make a new folder in the Downloads directory - .\Downloads\NewFileFormat\
- Install exes and place into the same directory
  - https://www.gyan.dev/ffmpeg/builds/ (ffmpeg-git-essentials.7z)
    - ffmpeg.exe
    - ffplay.exe
    - ffprobe.exe
  - https://github.com/yt-dlp/yt-dlp (Installation Windows x64)
    - yt-dlp.exe
- Run MediaTools.ps1 with powershell

## How To Use
- Option 1-4 downloads youtube media and places it into the Downloads folder
- Option 5 Converts files in the Downloads folders and places it into the NewFileFormat folder

## Make Shortcut to Execute Powershell
- Make a short cut for MediaTools.ps1
- Properties - add to - Target:

      powershell.exe -ExecutionPolicy Bypass -File
- Example: 

      powershell.exe -ExecutionPolicy Bypass -File "E:\Users\matt\ytdlpscript\MediaTools.ps1"