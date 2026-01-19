# Quick Start Guide

## 🚀 Get Started in 5 Minutes

### 1. Prerequisites Check
```bash
# Check Flutter
flutter --version

# Check Docker
docker --version

# Check Make (or use WSL/Git Bash on Windows)
make --version
```

### 2. Install Dependencies
```bash
# Install Flutter packages
flutter pub get
```

### 3. Start Security Services
```bash
# Start Docker services (Vault, WireGuard, etc.)
make start

# Or manually:
docker-compose up -d
```

### 4. Initialize Vault
```bash
# Initialize HashiCorp Vault
make vault-init

# Unseal Vault (use key from vault-keys.txt)
make vault-unseal
```

### 5. Run the App
```bash
# Run Flutter app
flutter run

# Or build for release
make build
```

## 🎮 Using Security Features

### Security Dashboard
- Press **F10** to open/refresh the security dashboard
- View real-time security statistics
- Monitor network security status
- Check intrusion detection alerts

### Penetration Testing
- Press **Ctrl+Shift+X** to run penetration test simulation
- Or click the "Run Penetration Test" button in the dashboard
- Review test results for vulnerabilities

### Security Scanning
```bash
# Run comprehensive security scan
make security-scan

# Run security audit
make audit

# Run penetration test
make pentest
```

## 🔧 Common Commands

```bash
# View all available commands
make help

# Start all services
make start

# Stop all services
make stop

# View logs
make logs

# Clean up
make clean
```

## 📱 App Features

1. **Security Dashboard**: Main security monitoring interface
2. **Biometric Authentication**: Test hardware-backed authentication
3. **Network Security**: Monitor VPN and connection status
4. **Threat Intelligence**: View threat detection status
5. **Intrusion Detection**: Monitor security events

## ⚠️ Troubleshooting

### Docker Issues
```bash
# Check if Docker is running
docker ps

# Restart services
docker-compose restart

# View service logs
docker-compose logs vault
```

### Flutter Issues
```bash
# Clean build
flutter clean
flutter pub get

# Check for issues
flutter doctor
```

### Vault Issues
```bash
# Check Vault status
make vault-status

# Re-initialize if needed
make vault-init
make vault-unseal
```

## 🔐 Security Checklist

- [ ] GPG keys configured for commit signing
- [ ] Pre-commit hooks installed
- [ ] Vault initialized and unsealed
- [ ] Security services running
- [ ] Initial security scan completed
- [ ] Firewall rules configured
- [ ] Certificate pins added for your domains

## 📚 Next Steps

1. Review `README.md` for detailed documentation
2. Customize firewall rules in `lib/security/network/firewall_rules.dart`
3. Add certificate pins in `lib/security/network/certificate_pinning.dart`
4. Configure threat intelligence database
5. Set up monitoring alerts

---

**Need Help?** Check the `README.md` or `SETUP.md` for more details.
