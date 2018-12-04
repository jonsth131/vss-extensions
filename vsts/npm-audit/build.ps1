$taskOutputDir = ".\task"
$sourceDir = ".\source"

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
Copy-Item .\package.json $taskOutputDir

Write-Output "Restoring dependencies"
Set-Location $taskOutputDir
& npm install --only=production

Write-Output "Removing package.json"
Remove-Item .\package.json
Remove-Item .\package-lock.json

Write-Output "Creating vsix package"
Set-Location ..
& tfx extension create --manifest-globs vss-extension.json

Write-Output "Created $extensionType extension $extension"

Set-Location $PSScriptRoot