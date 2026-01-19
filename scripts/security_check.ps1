# Security Check Script for Flutter App (PowerShell)
# Run: .\scripts\security_check.ps1

Write-Host "🔒 Running Security Checks..." -ForegroundColor Cyan
Write-Host "================================" -ForegroundColor Cyan
Write-Host ""

# 1. Check dependencies
Write-Host "1. Checking dependencies..." -ForegroundColor Yellow
flutter pub audit
Write-Host ""

# 2. Check for hardcoded secrets
Write-Host "2. Scanning for hardcoded secrets..." -ForegroundColor Yellow
Write-Host "Checking for common secret patterns..."
Select-String -Path "lib\**\*.dart" -Pattern "password\s*=\s*['`"].*['`"]" -CaseSensitive:$false | Where-Object { $_.Path -notlike "*generated*" } | ForEach-Object { Write-Host "⚠️  Potential hardcoded password: $($_.Path):$($_.LineNumber)" -ForegroundColor Red }
Select-String -Path "lib\**\*.dart" -Pattern "api.*key\s*=\s*['`"].*['`"]" -CaseSensitive:$false | Where-Object { $_.Path -notlike "*generated*" } | ForEach-Object { Write-Host "⚠️  Potential API key: $($_.Path):$($_.LineNumber)" -ForegroundColor Red }
Select-String -Path "lib\**\*.dart" -Pattern "secret\s*=\s*['`"].*['`"]" -CaseSensitive:$false | Where-Object { $_.Path -notlike "*generated*" } | ForEach-Object { Write-Host "⚠️  Potential secret: $($_.Path):$($_.LineNumber)" -ForegroundColor Red }
Write-Host "✓ Secret scan complete" -ForegroundColor Green
Write-Host ""

# 3. Check for TODO/FIXME in security code
Write-Host "3. Checking for security-related TODOs..." -ForegroundColor Yellow
$todos = Select-String -Path "lib\security\**\*.dart", "lib\services\**\*.dart" -Pattern "TODO|FIXME" -CaseSensitive:$false
if ($todos) {
    $todos | ForEach-Object { Write-Host "⚠️  TODO found: $($_.Path):$($_.LineNumber)" -ForegroundColor Yellow }
} else {
    Write-Host "✓ No security TODOs found" -ForegroundColor Green
}
Write-Host ""

# 4. Verify encryption usage
Write-Host "4. Verifying encryption is used..." -ForegroundColor Yellow
if (Select-String -Path "lib\services\database_service.dart" -Pattern "sqflite_sqlcipher" -Quiet) {
    Write-Host "✓ Encrypted SQLite (SQLCipher) is being used" -ForegroundColor Green
} else {
    Write-Host "⚠️  Warning: SQLCipher not found" -ForegroundColor Red
}

if (Select-String -Path "lib\services\**\*.dart" -Pattern "flutter_secure_storage" -Quiet) {
    Write-Host "✓ Secure storage is being used" -ForegroundColor Green
} else {
    Write-Host "⚠️  Warning: Secure storage not found" -ForegroundColor Red
}
Write-Host ""

# 5. Check HTTPS enforcement
Write-Host "5. Checking HTTPS enforcement..." -ForegroundColor Yellow
if (Select-String -Path "lib\utils\security_utils.dart" -Pattern "createSecureDio|HTTPS" -Quiet) {
    Write-Host "✓ HTTPS enforcement found" -ForegroundColor Green
} else {
    Write-Host "⚠️  Warning: HTTPS enforcement not found" -ForegroundColor Red
}
Write-Host ""

Write-Host "✅ Security checks complete!" -ForegroundColor Green
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Cyan
Write-Host "  - Review any warnings above"
Write-Host "  - Test on Android device: flutter run"
Write-Host "  - Build APK: flutter build apk --release"
