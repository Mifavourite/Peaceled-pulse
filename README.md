# Recovery Journey App 🌟

A comprehensive, privacy-first recovery companion with military-grade security and motivational support features.

## 💪 What Makes This App Special

This isn't just another recovery tracker. It's a complete support system that:
- **Motivates** you with visual progress tracking and milestone celebrations
- **Supports** you with 24/7 crisis resources and coping strategies
- **Empowers** you with insights through mood tracking and trigger analysis
- **Protects** your privacy with military-grade encryption (all data stays on YOUR device)

## ✨ Core Features

### 🎯 1. Motivational Dashboard
Your recovery command center:
- **Live Streak Counter**: Animated display of your current recovery streak
- **Progress Statistics**: Total victories, weekly count, and trends
- **Milestone Badges**: Unlock achievements at 7, 30, 90, and 365 days
- **Daily Motivation**: Rotating inspirational quotes to keep you going
- **Quick Actions**: One-tap access to check-ins and emergency support

### 📝 2. Daily Check-In System
Track your emotional journey:
- **Mood Tracking**: 5 mood levels from Great to Very Difficult
- **Trigger Identification**: Track common triggers (stress, loneliness, anxiety, etc.)
- **Personal Notes**: Document your thoughts and experiences
- **Smart Support**: Get coping suggestions when you're struggling
- **Trend Analysis**: Identify patterns over time

### 🎉 3. Enhanced Victory Log
Celebrate and visualize your progress:
- **Visual Progress Chart**: Beautiful monthly bar charts showing your victories
- **Achievement Badges**: Earn badges at key milestones
- **Detailed History**: All victories with notes stored securely
- **Encrypted Storage**: Your data is protected with AES-256 encryption

### 🆘 4. Emergency Support
Life-saving resources when you need them most:
- **24/7 Crisis Hotlines**: One-tap calling to National Suicide Prevention Lifeline (988), Crisis Text Line (741741), SAMHSA Helpline
- **Quick Coping Strategies**: Breathing exercises, grounding techniques, physical activities
- **Accountability Partners**: Add trusted contacts for support
- **Recovery Reminders**: Motivational affirmations

### 📊 5. Progress Reports & Export
Share your journey:
- **Text Reports**: Human-readable progress summaries
- **JSON Export**: Structured data for analysis
- **Comprehensive Stats**: Streak, mood trends, trigger analysis, milestones
- **Share Capability**: Send reports to sponsors, therapists, or accountability partners
- **Encrypted Backups**: Secure data backup with password protection

### 🛡️ 6. NSFW Detection
AI-powered content protection:
- **On-Device Processing**: All detection happens locally (no cloud)
- **TensorFlow Lite**: Fast, accurate content analysis
- **Customizable Sensitivity**: Adjust detection threshold
- **Privacy First**: No images uploaded anywhere

### ❤️ 7. Core Values
Remember what matters most:
- **5 Core Values**: Store your most important principles
- **Quick Access**: View anytime for motivation and grounding
- **Encrypted Storage**: Your values kept private and secure

### 💬 8. AI Support Chat
Conversational guidance:
- **Scripture-based support**: Biblical wisdom for recovery
- **Encouragement**: Positive reinforcement and accountability
- **Privacy-focused**: All conversations stay on your device

## 🔒 Security Features

### Military-Grade Encryption
- **AES-256 Encryption**: All data encrypted at rest
- **SQLCipher Database**: Hardware-backed database encryption
- **Bcrypt Password Hashing**: Cost factor 12 for maximum security
- **Secure Key Storage**: Platform-specific secure storage (iOS Keychain, Android Keystore)
- **Certificate Pinning**: Protected network communications
- **Zero Cloud Sync**: All data stays on YOUR device

### Privacy First
- ✅ No data uploaded to cloud
- ✅ No tracking or analytics
- ✅ No personal information collected
- ✅ No location tracking
- ✅ No advertising
- ✅ Your data belongs to YOU

## 🚀 Quick Start

### Prerequisites
- Flutter SDK (>=3.0.0)
- Android Studio or Xcode (for mobile deployment)

### Simple Run (One Command)

```bash
# Install dependencies
flutter pub get

# Run the app
flutter run
```

### First Time Setup (3 minutes)
1. **Create Account**
   - Enter username and strong password
   - Your data is encrypted immediately

2. **Set Core Values** (optional)
   - Go to "Values" tab
   - Enter up to 5 personal values

3. **Log Your First Victory**
   - Go to "Victory" tab
   - Add a note about today
   - Tap "Log Victory"

**That's it! You're on your recovery journey! 🎉**

## 📱 Your Daily Routine

### ☀️ Morning (30 seconds)
- Open app → Check your streak on dashboard
- Read motivational quote

### 📝 Throughout Day
- Log victories as they happen
- Use detection feature if needed
- Access emergency support if struggling

### 🌙 Evening (2 minutes)
- Complete daily check-in
- Review your progress

## 🆘 Emergency Resources

### In Crisis? Get Help Now:
- **Call 988** - National Suicide Prevention Lifeline
- **Text HOME to 741741** - Crisis Text Line
- **Call 1-800-662-4357** - SAMHSA National Helpline

**In the app**: Tap the red phone icon (top right) for immediate crisis resources

## 📊 Track Your Progress

### What You Can Track:
- **Daily Streak**: See your consecutive recovery days grow
- **Victory Logs**: Document successful days with notes
- **Mood Trends**: Track emotional patterns over time
- **Trigger Analysis**: Identify what challenges you most
- **Milestone Achievements**: Earn badges at 7, 30, 90, 365 days

### Export Your Progress:
- Generate text reports
- Export JSON data
- Share with accountability partners
- Backup your data securely

## 🎯 Key Features at a Glance

| Feature | Description | Privacy |
|---------|-------------|---------|
| **Dashboard** | Streak, stats, and motivation | 🔒 Local only |
| **Check-Ins** | Daily mood and trigger tracking | 🔒 Encrypted |
| **Victory Log** | Progress charts and badges | 🔒 Encrypted |
| **Emergency Support** | Crisis hotlines and coping strategies | 📞 Direct |
| **Detection** | AI-powered content safety | 🔒 On-device |
| **Export** | Progress reports and backups | 🔒 Encrypted |
| **Values** | Your core principles | 🔒 Encrypted |
| **Chat** | AI support and guidance | 🔒 Local only |

## 🏗️ Architecture

```
lib/
├── security/
│   ├── authentication/
│   │   ├── biometric_auth.dart
│   │   ├── hardware_key.dart
│   │   └── mfa_service.dart
│   ├── encryption/
│   │   ├── e2ee.dart
│   │   ├── key_management.dart
│   │   └── secure_enclave.dart
│   ├── network/
│   │   ├── certificate_pinning.dart
│   │   ├── vpn_detection.dart
│   │   └── firewall_rules.dart
│   ├── monitoring/
│   │   ├── intrusion_detection.dart
│   │   ├── behavior_analytics.dart
│   │   └── threat_intelligence.dart
│   └── dashboard/
│       ├── security_dashboard.dart
│       └── pentest_screen.dart
├── core/
└── features/
```

## 🐳 Docker Services

- **Vault**: HashiCorp Vault for secrets management (port 8200)
- **WireGuard**: VPN for network isolation (port 51820)
- **Trivy**: Security scanner for vulnerability detection
- **Clair**: Container vulnerability scanner (ports 6060, 6061)
- **PostgreSQL**: Database for Clair (internal)

## 🔐 Security Best Practices

1. **Always sign commits** with GPG
2. **Never commit secrets** - use Vault instead
3. **Run security scans** before committing
4. **Review security dashboard** regularly
5. **Keep dependencies updated** - run `flutter pub upgrade` regularly
6. **Use hardware-backed storage** for sensitive data
7. **Enable certificate pinning** for all network requests
8. **Monitor intrusion detection** alerts

## 📝 Pre-commit Hooks

The pre-commit hook automatically:
- Runs Flutter analyzer
- Checks for hardcoded secrets
- Verifies GPG signatures
- Runs security audits

## 🛡️ Security Testing

### Manual Testing
1. Open the app
2. Press **F10** to open security dashboard
3. Press **Ctrl+Shift+X** to run penetration test
4. Review security statistics and alerts

### Automated Testing
```bash
make security-scan  # Full security scan
make pentest        # Penetration test simulation
make audit          # Security audit
```

## 📚 Documentation

- **[FEATURES_GUIDE.md](FEATURES_GUIDE.md)** - Complete feature documentation
- **[QUICK_START.md](QUICK_START.md)** - 3-minute getting started guide
- **[ENHANCEMENTS_COMPLETE.md](ENHANCEMENTS_COMPLETE.md)** - Technical details of all improvements

## 🎓 Recovery Principles

This app is built on core recovery principles:

1. **Progress, Not Perfection** - Every day is a victory
2. **One Day at a Time** - Focus on today
3. **You Are Not Alone** - Support is always available
4. **Recovery is Possible** - You deserve healing
5. **Privacy First** - Your data, your device, your journey

## 💡 Tips for Success

### Build Habits:
- ✅ Check in at the same time daily
- ✅ Log victories immediately
- ✅ Review dashboard each morning
- ✅ Export progress weekly

### Stay Motivated:
- ✅ Set milestone goals
- ✅ Share progress with a supporter
- ✅ Read motivational quotes
- ✅ Celebrate each victory

### Use Support:
- ✅ Save emergency contacts
- ✅ Practice coping strategies
- ✅ Reach out when struggling
- ✅ Build accountability

## ⚠️ Important Notes

- **Privacy First**: All data stored locally on YOUR device
- **No Cloud Sync**: Your data never leaves your device unless you choose to share
- **Encrypted Storage**: Military-grade AES-256 encryption
- **Crisis Resources**: Immediate access to 24/7 helplines
- **Not a Replacement**: This app supports recovery but doesn't replace professional help

## 🙏 Support

### In the App:
- Chat with AI assistant
- Access emergency resources
- Submit feedback
- View documentation

### External Resources:
- **988** - National Suicide Prevention Lifeline
- **741741** - Crisis Text Line (text HOME)
- **1-800-662-4357** - SAMHSA National Helpline
- Visit: https://findahelpline.com for international resources

## 🎉 Milestones to Celebrate

- **Day 1**: You started! 🌱
- **Day 7**: First week! 🌟
- **Day 30**: One month! ⭐
- **Day 90**: Three months! 🏅
- **Day 365**: One year! 💎

## 📄 License

This project is provided as-is to support recovery journeys. Use it, share it, help others with it.

---

## 💪 Remember

> **"Recovery is not a race. It's a journey taken one day at a time."**

**You've got this. One day at a time. 🌟**

---

*Your recovery journey starts with a single step. You've already taken it by being here.*

**Version**: 1.0.0  
**Built with ❤️ for those on the recovery journey**
