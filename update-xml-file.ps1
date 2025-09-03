# Paths
$releasesDir = "releases"
$installerName = "FSBLauncher-Setup.exe"
$updatesXml = "updates.xml"

# Get latest version folder
$versionFolders = Get-ChildItem -Path $releasesDir -Directory | Where-Object { $_.Name -match '^\d+\.\d+\.\d+$' }
$sortedFolders = $versionFolders | Sort-Object { [Version]$_.Name } -Descending
$latestFolder = $sortedFolders | Select-Object -First 1
$latestVersion = $latestFolder.Name

Write-Host "🏆 Latest version detected: $latestVersion" -ForegroundColor Green

# Add trailing .0 if needed
if ($latestVersion -notmatch '^\d+\.\d+\.\d+\.\d+$') {
    $itemVersion = "$latestVersion.0"
} else {
    $itemVersion = $latestVersion
}

Write-Host "📝 item.version will be set to: $itemVersion" -ForegroundColor Yellow

# Calculate SHA1 checksum
$installerPath = Join-Path $latestFolder.FullName $installerName
$checksumLine = certutil -hashfile $installerPath SHA1 | Select-Object -Index 1
$checksum = $checksumLine.Trim().ToUpper()

Write-Host "🔑 SHA1 checksum for ${installerPath}: $checksum" -ForegroundColor Magenta

# Prepare new XML fields
$title = "FSBLauncher $latestVersion released!"
$url = "https://github.com/DocMoebiuz/FlightSimBuilder-Downloads/raw/main/releases/$latestVersion/$installerName"
$changelog = "https://github.com/flightsimbuilder/Flightsimbuilder/releases/tag/$latestVersion"

Write-Host "🌐 URL: $url" -ForegroundColor Cyan
Write-Host "📜 Changelog: $changelog" -ForegroundColor Cyan
Write-Host "🏷️ Title: $title" -ForegroundColor Cyan

# Update XML
[xml]$xml = Get-Content $updatesXml
$item = $xml.updates.item
# Set the 'version' attribute (not a child node)
$item.SetAttribute("version", $itemVersion)
# Set the <version> child node (requires SelectSingleNode due to XML parsing quirks)
$item.SelectSingleNode("version").InnerText = $latestVersion
$item.title = $title
$item.url = $url
$item.changelog = $changelog
$item.checksum.'#text' = $checksum

$xml.Save($updatesXml)
Write-Host "✅ updates.xml updated for version $latestVersion" -ForegroundColor Green