# Google Play Submission Guide

Complete guide for submitting the app to Google Play Store.

## 📋 Pre-Submission Checklist

### 1. ✅ Create App Icons
- [ ] Create 512x512 PNG icon (required for Google Play)
- [ ] Create 1024x1024 PNG icon (recommended)
- [ ] Create adaptive icon set (mipmap folders)
- [ ] Ensure icons follow Google Play guidelines
- [ ] Test icons on different backgrounds

**Location**: `android/app/src/main/res/mipmap-*/ic_launcher.png`

**Guidelines**:
- No transparency
- No words or letters
- Simple, recognizable design
- Works well at small sizes
- Matches app theme/colors

### 2. ✅ Write App Description

#### Short Description (80 characters max)
**Recommended**: "Secure personal values tracker with on-device detection and encrypted storage"

#### Full Description (4000 characters max)
See `GOOGLE_PLAY_DESCRIPTION.md` for complete description.

**Key Points to Include**:
- What the app does
- Key features
- Security/privacy highlights
- Who it's for
- Why it's unique

### 3. ✅ Prepare Screenshots

#### Required Screenshots:
- [ ] Phone screenshots (at least 2, up to 8)
  - Resolution: Minimum 320px, Maximum 3840px
  - Aspect ratio: Between 16:9 and 9:16
  - Format: 24-bit PNG or JPEG
  - Recommended: 1080x1920 (Full HD phone)

#### Screenshot Checklist:
- [ ] Login/Registration screen
- [ ] Home screen with navigation
- [ ] Detection screen
- [ ] Values screen
- [ ] Victory Log screen
- [ ] Settings screen
- [ ] Security features highlight

**Screenshot Tips**:
- Use real device screenshots (not emulator)
- Show the best features
- Ensure text is readable
- Use consistent styling
- Add brief captions if needed

#### Tablet Screenshots (Optional but Recommended):
- [ ] 7" tablet screenshots (at least 1, up to 8)
- [ ] 10" tablet screenshots (at least 1, up to 8)

#### Feature Graphic:
- [ ] 1024x500 PNG or 24-bit PNG (no alpha)
- [ ] Banner for Google Play listing
- [ ] Shows app name and key feature

### 4. ✅ Set Up Google Play Developer Account

#### Steps:
1. **Visit Google Play Console**: https://play.google.com/console
2. **Sign Up**:
   - Create Google account (if needed)
   - Pay one-time $25 registration fee
   - Complete developer profile
3. **Verify Account**:
   - Phone number verification
   - Address verification
   - Payment method setup

#### Important:
- One-time fee: $25 USD
- Annual renewal: FREE
- Processing time: Usually 24-48 hours

### 5. ✅ Prepare App for Release

#### Version Information:
- App version: 1.0.0 (version in pubspec.yaml)
- Version code: 1 (build number)
- Package name: `com.secureapp.flutter` (update in build.gradle)

#### Build Release APK/AAB:
```bash
# Build App Bundle (recommended for Google Play)
flutter build appbundle --release

# OR Build APK (for testing)
flutter build apk --release --split-per-abi
```

**Output**:
- App Bundle: `build/app/outputs/bundle/release/app-release.aab`
- APK: `build/app/outputs/flutter-apk/app-release.apk`

#### Signing Configuration:
1. Generate keystore:
   ```bash
   keytool -genkey -v -keystore ~/upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
   ```
2. Configure signing in `android/key.properties`
3. Update `android/app/build.gradle` for signing

### 6. ✅ App Store Listing Information

#### Basic Information:
- **App Name**: "Secure Values" (or your chosen name, 50 chars max)
- **Short Description**: 80 characters max
- **Full Description**: 4000 characters max
- **App Icon**: 512x512 PNG
- **Feature Graphic**: 1024x500 PNG

#### Categorization:
- **Category**: Productivity / Lifestyle / Tools
- **Content Rating**: 
  - Age rating questionnaire required
  - Expected: Everyone or Teen (depending on detection features)

#### Privacy Policy:
- [ ] Create privacy policy (REQUIRED)
- [ ] Host privacy policy online
- [ ] Add privacy policy URL to listing
- **Template**: See `PRIVACY_POLICY_TEMPLATE.md`

### 7. ✅ Content Rating

#### Required:
- Complete content rating questionnaire
- Categories to consider:
  - Violence
  - Sexual Content
  - Profanity
  - Controlled Substances
  - Gambling
  - User-Generated Content

#### For This App:
- Violence: None
- Sexual Content: Content filtering/detection (be clear about purpose)
- Profanity: None
- Controlled Substances: None
- Gambling: None
- User-Generated Content: Local only (no sharing)

### 8. ✅ Pricing and Distribution

#### Pricing:
- Free app (recommended for initial launch)
- Or paid app (if monetizing)

#### Countries:
- Select countries for distribution
- Recommended: Start with English-speaking countries
- Expand based on feedback

#### Device Compatibility:
- Minimum SDK: Android 5.0 (API 21)
- Target SDK: Latest Android version
- Maximum SDK: Leave blank (support all)

### 9. ✅ Store Listing (Localized)

#### Default Language: English (United States)
- [ ] App name
- [ ] Short description
- [ ] Full description
- [ ] Screenshots
- [ ] Feature graphic

#### Additional Languages (Optional):
- Add other languages as needed
- Translate all content
- Add localized screenshots

## 🚀 Submission Steps

### Step 1: Create New App
1. Go to Google Play Console
2. Click "Create app"
3. Fill in:
   - App name
   - Default language
   - App or game
   - Free or paid
   - Declarations (ads, content rating, etc.)

### Step 2: Complete Store Listing
1. Go to "Store presence" > "Store listing"
2. Upload app icon (512x512)
3. Upload feature graphic (1024x500)
4. Add short description
5. Add full description
6. Upload screenshots
7. Add contact details (email, website - optional)

### Step 3: Set Up App Content
1. Complete content rating
2. Add privacy policy URL
3. Complete target audience
4. Complete data safety section
5. Add advertising ID usage (if applicable)

### Step 4: Set Up Pricing & Distribution
1. Select countries
2. Set pricing (if paid)
3. Set device compatibility
4. Add consent forms if needed

### Step 5: Create Release
1. Go to "Release" > "Production" (or "Testing")
2. Create new release
3. Upload App Bundle (`.aab` file)
4. Add release notes:
   ```
   Initial release of Secure Values app.

   Features:
   - Secure encrypted storage
   - Personal values tracking
   - On-device content detection
   - Victory logging
   - Privacy-first design
   ```
5. Review and roll out

### Step 6: Review & Submit
1. Review all sections
2. Check for warnings/errors
3. Submit for review
4. Wait for review (typically 1-7 days)

## 📝 Release Notes Template

### Version 1.0.0 (Initial Release)
```
🎉 Welcome to Secure Values!

Features:
✅ Secure encrypted storage for personal values
✅ On-device content detection
✅ Victory log tracking
✅ Privacy-first architecture
✅ Biometric authentication support
✅ Zero external data transmission

Security highlights:
🔒 All data encrypted locally
🔒 No analytics or tracking
🔒 Open source security architecture
🔒 Secure password hashing

We're excited to have you! Your feedback helps us improve.
```

## ⚠️ Important Notes

### Before Submission:
- [ ] Test app thoroughly on multiple devices
- [ ] Test on different Android versions
- [ ] Verify all features work correctly
- [ ] Check for crashes or errors
- [ ] Test offline functionality
- [ ] Verify encryption works
- [ ] Test backup/restore (if applicable)
- [ ] Check permission handling
- [ ] Verify no hardcoded secrets
- [ ] Update app version in pubspec.yaml

### Common Issues:
1. **App rejected for permissions**: Ensure permissions are justified
2. **Content rating issues**: Be clear about content detection purpose
3. **Privacy policy missing**: Must have hosted privacy policy
4. **Icon doesn't meet guidelines**: Follow Google Play icon guidelines
5. **Screenshots not meeting requirements**: Check resolution/aspect ratio

### Testing Before Release:
- [ ] Internal testing track (up to 100 testers)
- [ ] Closed testing track (up to 1000 testers)
- [ ] Open testing track (unlimited testers)

**Recommended**: Start with internal testing, then closed testing, then production.

## 📚 Resources

- [Google Play Console](https://play.google.com/console)
- [Google Play Developer Policy](https://play.google.com/about/developer-content-policy/)
- [App Bundle Guide](https://developer.android.com/guide/app-bundle)
- [Content Rating Guide](https://support.google.com/googleplay/android-developer/answer/9888179)
- [Privacy Policy Requirements](https://support.google.com/googleplay/android-developer/answer/10787469)

## ✅ Final Checklist

Before clicking "Submit for Review":

- [ ] App icon created and uploaded
- [ ] Feature graphic created and uploaded
- [ ] Screenshots prepared and uploaded
- [ ] Short description written (80 chars)
- [ ] Full description written (4000 chars)
- [ ] Privacy policy created and hosted
- [ ] Privacy policy URL added
- [ ] Content rating completed
- [ ] Data safety section completed
- [ ] App Bundle (.aab) built and tested
- [ ] Release notes written
- [ ] Tested on multiple devices
- [ ] All permissions justified
- [ ] No crashes or critical bugs
- [ ] Developer account set up ($25 paid)
- [ ] Contact information added
- [ ] Pricing/distribution set
- [ ] Target countries selected

## 🎯 Timeline

**Estimated Timeline**:
- Developer account setup: 1-2 days
- Asset creation (icons, screenshots): 2-3 days
- App preparation and testing: 2-3 days
- Store listing creation: 1 day
- Review submission: 1 day
- Google review: 1-7 days
- **Total: ~1-2 weeks**

## 🆘 Support

If you encounter issues:
1. Check Google Play Console help section
2. Review rejection reasons (if app is rejected)
3. Update app based on feedback
4. Resubmit after fixes

---

**Good luck with your submission! 🚀**
