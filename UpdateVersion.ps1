[CmdletBinding()]
Param(
    [Parameter(Mandatory = $True)]
    [string]$extension,
    [int]$major = -1,
    [int]$minor = -1,
    [int]$patch = -1
)

if (!(Test-Path $extension)) {
    Write-Error "$extension not found. Breaking."
    Break
}

Set-Location $extension

$taskJsonPath = "$extension\task.json"
$packageJsonPath = "$extension\package.json"
$vssExtensionJsonPath = ".\vss-extension.json"

Write-Output "Getting version information from $taskJsonPath"
$task = Get-Content $taskJsonPath -raw | ConvertFrom-Json
$task.version | ForEach-Object {
    if ($major -eq -1) {$major = $_.Major}
    if ($minor -eq -1) {$minor = $_.Minor}
    if ($patch -eq -1) {$patch = $_.Patch + 1}
}
$completeVersion = "$major.$minor.$patch"

Write-Output "New version : $completeVersion"

Write-Output "Saving version information to $taskJsonPath"
$task.version.Major = $major
$task.version.Minor = $minor
$task.version.Patch = $patch
$task | ConvertTo-Json  | set-content $taskJsonPath

Write-Output "Saving version information to $packageJsonPath"
$package = Get-Content $packageJsonPath -raw | ConvertFrom-Json
$package.version = $completeVersion
$package | ConvertTo-Json | Set-Content $packageJsonPath

Write-Output "Saving version information to $vssExtensionJsonPath"
$vss = Get-Content $vssExtensionJsonPath -raw | ConvertFrom-Json
$vss.version = $completeVersion
$vss | ConvertTo-Json | Set-Content $vssExtensionJsonPath