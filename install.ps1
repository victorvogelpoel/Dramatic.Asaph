$module        	= 'Dramatic.Asaph'
$gitrepository	= 'https://github.com/victorvogelpoel/Dramatic.Asaph'

# Make sure the module is not loaded
Remove-Module $module -ErrorAction SilentlyContinue

# Download latest version
$webclient		= New-Object System.Net.WebClient
$url 			= "$gitrepository/archive/master.zip"

Write-Host "Downloading latest version of $module from $url" -ForegroundColor Cyan
$file 			= "$($env:TEMP)\$module.zip"
$webclient.DownloadFile($url,$file)
Write-Host "File saved to $file" -ForegroundColor Green

# Unblock and Decompress
Unblock-File -Path $file

$targetondisk 	= "$($env:USERPROFILE)\Documents\WindowsPowerShell\Modules"
New-Item -ItemType Directory -Force -Path $targetondisk | out-null

$shell_app		= new-object -com shell.application
$zip_file 		= $shell_app.namespace($file)
Write-Host "Uncompressing the Zip file to $($targetondisk)" -ForegroundColor Cyan
$destination	= $shell_app.namespace($targetondisk)
$destination.Copyhere($zip_file.items(), 0x10)

# Rename and import
Write-Host "Renaming folder" -ForegroundColor Cyan
Rename-Item -Path ("$targetondisk\$module`-master") -NewName $module -Force

Write-Host "Module `"$module`" has been installed :-)" -ForegroundColor Green

Write-Host "Now loading module `"$module`"..."
Import-Module -Name $module
Get-Command -Module $module

Get-Help about_DramaticAsaphModule
