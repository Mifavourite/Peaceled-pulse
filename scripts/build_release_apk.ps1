# Build Release APK Script for Windows PowerShell
# Optimized for mobile: battery, memory, and performance

param(
    [string]$BuildType = "release",
    [switch]$Clean = $false,
    [switch]$Sign = $false
)

$ErrorActionPreference = "Stop"

Write-Host "🚀 Building Release APK..." -ForegroundColor Cyan
Write-Host ""

# Change to project directory
$projectRoot = Split-Path -Parent $PSScriptRoot
Push-Location $projectRoot

try {
    # Step 1: Clean (optional)
    if ($Clean) {
        Write-Host "🧹 Cleaning build files..." -ForegroundColor Yellow
        flutter clean
        Remove-Item -Path "build" -Recurse -Force -ErrorAction SilentlyContinue
        Write-Host "✓ Clean complete" -ForegroundColor Green
        Write-Host ""
    }

    # Step 2: Get dependencies
    Write-Host "📦 Getting dependencies..." -ForegroundColor Yellow
    flutter pub get
    if ($LASTEXITCODE -ne 0) {
        throw "Failed to get dependencies"
    }
    Write-Host "✓ Dependencies installed" -ForegroundColor Green
    Write-Host ""

    # Step 3: Build APK
    Write-Host "🔨 Building $BuildType APK..." -ForegroundColor Yellow
    
    $buildCommand = "flutter build apk --release"
    
    # Add optimizations
    $buildCommand += " --split-per-abi"  # Build separate APKs per ABI (smaller size)
    $buildCommand += " --target-platform android-arm,android-arm64,android-x64"
    
    if ($Sign) {
        Write-Host "   (Including signing - ensure keystore is configured)" -ForegroundColor Gray
    }
    
    Invoke-Expression $buildCommand
    
    if ($LASTEXITCODE -ne 0) {
        throw "APK build failed"
    }
    
    Write-Host "✓ APK build successful!" -ForegroundColor Green
    Write-Host ""
    
    # Step 4: Locate APK files
    Write-Host "📱 APK Location:" -ForegroundColor Cyan
    $apkPaths = Get-ChildItem -Path "build\app\outputs\flutter-apk" -Filter "*.apk" -Recurse
    
    foreach ($apk in $apkPaths) {
        $size = [math]::Round($apk.Length / 1MB, 2)
        Write-Host "   $($apk.FullName)" -ForegroundColor White
        Write-Host "   Size: $size MB" -ForegroundColor Gray
    }
    
    Write-Host ""
    Write-Host "✅ Release APK build complete!" -ForegroundColor Green
    Write-Host ""
    Write-Host "Installation:" -ForegroundColor Cyan
    Write-Host "   adb install $($apkPaths[0].FullName)" -ForegroundColor White
    Write-Host ""
    Write-Host "App Bundle (recommended for Play Store):" -ForegroundColor Cyan
    Write-Host "   flutter build appbundle --release" -ForegroundColor White

} catch {
    Write-Host ""
    Write-Host "❌ Build failed: $_" -ForegroundColor Red
    exit 1
} finally {
    Pop-Location
}
