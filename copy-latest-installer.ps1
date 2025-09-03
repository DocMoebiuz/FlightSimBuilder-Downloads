# Set paths
$releasesDir = "releases"
$sourceFile = "..\Flightsimbuilder\FSBLauncher\installer\FSBLauncher-Setup.exe"

# Get all version folders
$versionFolders = Get-ChildItem -Path $releasesDir -Directory | Where-Object { $_.Name -match '^\d+\.\d+\.\d+$' }

# Parse and sort by semantic version
$sortedFolders = $versionFolders | Sort-Object { [Version]$_.Name } -Descending

# Print sorted version folders
Write-Host "🔢 Sorted version folders (descending):" -ForegroundColor Cyan
$sortedFolders | ForEach-Object { Write-Host "   📁 $($_.Name)" }

$latestFolder = $sortedFolders | Select-Object -First 1

if ($latestFolder) {
    Write-Host "🏆 Latest version detected: $($latestFolder.Name)" -ForegroundColor Green
} else {
    Write-Host "⚠️ No valid version folders found." -ForegroundColor Yellow
}

if ($latestFolder) {
    $destPath = Join-Path $latestFolder.FullName "FSBLauncher-Setup.exe"
    Write-Host "📦 Copying installer to: $destPath" -ForegroundColor Cyan
    Copy-Item -Path $sourceFile -Destination $destPath -Force
    Write-Host "✅ Copied successfully to $destPath" -ForegroundColor Green
} else {
    Write-Host "❌ Copy failed: No valid version folders found." -ForegroundColor Red
}