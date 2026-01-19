#!/bin/bash

# Security Check Script for Flutter App
# Run: bash scripts/security_check.sh

echo "🔒 Running Security Checks..."
echo "================================"
echo ""

# 1. Check dependencies
echo "1. Checking dependencies..."
flutter pub audit
echo ""

# 2. Check for hardcoded secrets
echo "2. Scanning for hardcoded secrets..."
echo "Checking for common secret patterns..."
grep -r -i "password.*=.*['\"].*['\"]" lib/ --exclude-dir=generated || echo "✓ No obvious hardcoded passwords found"
grep -r -i "api.*key.*=.*['\"].*['\"]" lib/ --exclude-dir=generated || echo "✓ No obvious API keys found"
grep -r -i "secret.*=.*['\"].*['\"]" lib/ --exclude-dir=generated || echo "✓ No obvious secrets found"
echo ""

# 3. Check for TODO/FIXME in security code
echo "3. Checking for security-related TODOs..."
grep -r -i "TODO\|FIXME" lib/security/ lib/services/ || echo "✓ No security TODOs found"
echo ""

# 4. Verify encryption usage
echo "4. Verifying encryption is used..."
if grep -r "sqflite_sqlcipher" lib/services/database_service.dart > /dev/null; then
    echo "✓ Encrypted SQLite (SQLCipher) is being used"
else
    echo "⚠️  Warning: SQLCipher not found"
fi

if grep -r "flutter_secure_storage" lib/services/ > /dev/null; then
    echo "✓ Secure storage is being used"
else
    echo "⚠️  Warning: Secure storage not found"
fi
echo ""

# 5. Check HTTPS enforcement
echo "5. Checking HTTPS enforcement..."
if grep -r "createSecureDio\|HTTPS" lib/utils/security_utils.dart > /dev/null; then
    echo "✓ HTTPS enforcement found"
else
    echo "⚠️  Warning: HTTPS enforcement not found"
fi
echo ""

echo "✅ Security checks complete!"
echo ""
echo "Next steps:"
echo "  - Review any warnings above"
echo "  - Test on Android device: flutter run"
echo "  - Build APK: flutter build apk --release"
