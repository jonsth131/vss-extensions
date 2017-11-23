[CmdletBinding()]
Param(
    [Parameter(Mandatory = $True)]
    [string]$extensionType,
    [Parameter(Mandatory = $True)]
    [string]$extension
)

$taskOutputDir = ".\task"
$sourceDir = ".\source"

Write-Output "Building $extensionType extension $extension"
Set-Location -Path $extensionType

Write-Output "Updating version"
.$PSScriptRoot\UpdateVersion.ps1 -extension $extension

Write-Output "Cleaning old builds"
if (Test-Path $taskOutputDir) {
    Remove-Item $taskOutputDir -Force -Recurse
}
mkdir $taskOutputDir

Set-Location -Path $sourceDir

Write-Output "Compiling TypeScript"
& tsc

Write-Output "Copying files to compile folder"
Set-Location ..
Copy-Item .\$sourceDir\*.js $taskOutputDir
Copy-Item .\$sourceDir\*.json $taskOutputDir
Copy-Item .\$sourceDir\*.png $taskOutputDir

Write-Output "Restoring dependencies"
Set-Location $taskOutputDir
& npm install --only=production

Write-Output "Creating vsix package"
Set-Location ..
& tfx extension create --manifest-globs vss-extension.json

Write-Output "Created $extensionType extension $extension"

Set-Location $PSScriptRoot