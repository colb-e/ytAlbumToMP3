<# Created by Colby Agerter :3

8/25/2024

Description: This program is a simple tool made to use yt-dlp (https://github.com/yt-dlp/yt-dlp) for downloading 
and formatting larger lists of specified albums from ytMsc to then be placed within organized folders.

I have no association with yt-dlp and take no credit for their amazing work that does the downloading 
and formatitng of the files. I am new to actually posting my code as a "complete" project and mainly
made this for fun, so if you have any reccomendations or tips please lmk! enjoy :)

How to Use:

1. Create a file called "links.txt"
2. Extract ffmpeg.exe from ffmpeg.7z
3. Copy and paste each desired album URL (one URL per line)
4. Ensure links.txt, yt-dlp.exe, and ffmpeg.exe are in the same directory


#>

$lineCount = 1
foreach ($line in (Get-Content -Path "links.txt")) {

    Write-Host "Line ${lineCount}:" -ForegroundColor Magenta
   
    $albumPage = Invoke-WebRequest -Uri $line

    if (Write-Output $albumPage.StatusCode -eq '200') {

        #Scrape webpage to find title of given album
        $albumName = $albumPage.AllElements | Where-Object { $_.tagname -eq "META" -and $_.name -eq "title" }

        #Current download info
        Write-Host "Album: "  $albumName.content
        Write-Host "URL: "  $line

        #Create and enter album folder
        $albumFolder = $PSScriptRoot + "\" + $albumName.content
        
        if (-not (Test-Path -Path $albumFolder)) {

            mkdir $albumFolder
            Write-Host "Created folder"

        } else { 
            
            Write-Host "Folder exists, skipping`n" -ForegroundColor Red
            $lineCount++
            continue
        }

        Set-Location $albumFolder
        
        #Run ytp-dlp with suppressed output
        try {

            ..\yt-dlp.exe --extract-audio --audio-format mp3 --audio-quality 0 --embed-thumbnail $line > $null 2>&1
            $status = "Completed"
            $stausColor ="Green"

        } catch { $status = "Failed" 
                  $stausColor ="Red" }

        
        #display status and return to root folder
        Write-Host "${albumName.content} download ${status}`n" -ForegroundColor $stausColor
        Set-Location $PSScriptRoot

    } else {

        Write-Host "Error accessing URL on line ${lineCount} `nURL: ${$line}`n"

    }

    $lineCount++

} 
