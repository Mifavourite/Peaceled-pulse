# Build APK Script for Testing (PowerShell)
# Run: .\scripts\build_apk.ps1

Write-Host "📱 Building APK for Testing..." -ForegroundColor Cyan
Write-Host "==============================" -ForegroundColor Cyan
Write-Host ""

# Clean previous builds
Write-Host "1. Cleaning previous builds..." -ForegroundColor Yellow
flutter clean
Write-Host ""

# Get dependencies
Write-Host "2. Getting dependencies..." -ForegroundColor Yellow
flutter pub get
Write-Host ""

# Run security checks
Write-Host "3. Running security checks..." -ForegroundColor Yellow
flutter pub audit
Write-Host ""

# Build APK
Write-Host "4. Building release APK..." -ForegroundColor Yellow
flutter build apk --release

if ($LASTEXITCODE -eq 0) {
    Write-Host ""
    Write-Host "✅ APK built successfully!" -ForegroundColor Green
    Write-Host ""
    Write-Host "APK location: build\app\outputs\flutter-apk\app-release.apk" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "To install on device:" -ForegroundColor Yellow
    Write-Host "  adb install build\app\outputs\flutter-apk\app-release.apk"
} else {
    Write-Host ""
    Write-Host "❌ APK build failed!" -ForegroundColor Red
    exit 1
}
