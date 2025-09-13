# Flutter Installation Script for Windows
Write-Host "Installing Flutter..." -ForegroundColor Green

# Create flutter directory
$flutterPath = "C:\flutter"
if (!(Test-Path $flutterPath)) {
    New-Item -ItemType Directory -Path $flutterPath -Force
}

# Download Flutter SDK
$flutterUrl = "https://storage.googleapis.com/flutter_infra_release/releases/stable/windows/flutter_windows_3.16.5-stable.zip"
$zipPath = "$env:TEMP\flutter.zip"

Write-Host "Downloading Flutter SDK..." -ForegroundColor Yellow
try {
    Invoke-WebRequest -Uri $flutterUrl -OutFile $zipPath -UseBasicParsing
    Write-Host "Download completed!" -ForegroundColor Green
} catch {
    Write-Host "Download failed: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

# Extract Flutter
Write-Host "Extracting Flutter..." -ForegroundColor Yellow
try {
    Expand-Archive -Path $zipPath -DestinationPath "C:\" -Force
    Write-Host "Extraction completed!" -ForegroundColor Green
} catch {
    Write-Host "Extraction failed: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

# Add to PATH for current session
$env:PATH += ";C:\flutter\bin"

# Verify installation
Write-Host "Verifying Flutter installation..." -ForegroundColor Yellow
try {
    & "C:\flutter\bin\flutter.bat" --version
    Write-Host "Flutter installed successfully!" -ForegroundColor Green
} catch {
    Write-Host "Flutter verification failed: $($_.Exception.Message)" -ForegroundColor Red
}

# Clean up
Remove-Item $zipPath -Force

Write-Host "Installation complete! Please restart your terminal to use Flutter." -ForegroundColor Green
