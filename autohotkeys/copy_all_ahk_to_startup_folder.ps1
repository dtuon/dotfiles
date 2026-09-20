# Define source folder (you can customize this)
$sourceFolder = Get-Location

# Get the user's Startup folder path
$startupFolder = [Environment]::GetFolderPath("Startup")

# Get all .ahk files in the source folder
$ahkFiles = Get-ChildItem -Path $sourceFolder -Filter *.ahk -File

foreach ($file in $ahkFiles) {
    # Build destination path
    $destPath = Join-Path -Path $startupFolder -ChildPath $file.Name
    
    # Copy the .ahk file to the Startup folder
    Copy-Item -Path $file.FullName -Destination $destPath -Force
    Write-Host "Copied $($file.Name) to Startup folder."
}
