[CmdletBinding()]
Param(
    [Parameter(Mandatory = $True)]
    [string]$extensionType,
    [Parameter(Mandatory = $True)]
    [string]$extension
)

$taskOutputDir = ".\task"


Write-Output "Building $extensionType extension $extension"
Set-Location -Path $extensionType

Write-Output "Updating version"
.$PSScriptRoot\UpdateVersion.ps1 -extension $extension

Write-Output "Cleaning old builds"
if (Test-Path $taskOutputDir) {
    Remove-Item .\task -Force -Recurse
}
mkdir $taskOutputDir

Set-Location -Path $extension

Write-Output "Compiling TypeScript"
& tsc

Write-Output "Copying files to compile folder"
Set-Location ..
Copy-Item .\$extension\*.js $taskOutputDir
Copy-Item .\$extension\*.json $taskOutputDir
Copy-Item .\$extension\*.png $taskOutputDir

Write-Output "Restoring dependencies"
Set-Location $taskOutputDir
& npm install --only=production

Write-Output "Creating vsix package"
Set-Location ..
& tfx extension create --manifest-globs vss-extension.json

Write-Output "Created $extensionType extension $extension"

Set-Location $PSScriptRoot