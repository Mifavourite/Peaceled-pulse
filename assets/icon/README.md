# App Icon Assets

This folder contains the app icon assets for generating launcher icons.

## Required Files

To generate app icons automatically:

1. **app_icon.png** (1024x1024px)
   - Main app icon
   - Must be 1024x1024 pixels
   - PNG format
   - No transparency (opaque background)
   - Should work well at small sizes

2. **app_icon_foreground.png** (1024x1024px) - Optional
   - Foreground layer for adaptive icon (Android 8.0+)
   - Can have transparency
   - Important elements should be in center 66% (safe zone)

## How to Generate Icons

Once you have your base icon files:

```bash
# Install dependencies
flutter pub get

# Generate all icon sizes
flutter pub run flutter_launcher_icons
```

This will automatically:
- Generate all required sizes (mdpi, hdpi, xhdpi, xxhdpi, xxxhdpi)
- Create adaptive icon XML configuration
- Place icons in correct Android folders
- Generate Play Store icon (512x512)

## Icon Design Guidelines

### For app_icon.png:
- **Size**: 1024x1024 pixels
- **Format**: PNG (24-bit, no transparency)
- **Background**: Solid color (no transparency)
- **Content**: Simple, recognizable design
- **Safe Zone**: Keep important elements within center 75%

### For app_icon_foreground.png (if creating adaptive icon):
- **Size**: 1024x1024 pixels
- **Format**: PNG (can have transparency)
- **Safe Zone**: Center 66% (important elements)
- **Design**: Icon without background

## Design Tips

1. **Simple & Clean**: Should be recognizable at 48x48px
2. **High Contrast**: Ensure visibility on various backgrounds
3. **Brand Colors**: Use your app's color scheme
4. **No Text**: Avoid letters or words
5. **Test Small**: View at 48x48px to ensure readability

## Creating Your Icon

### Option 1: Design from Scratch
- Use Figma, Adobe Illustrator, Canva, or any design tool
- Create 1024x1024px canvas
- Design icon matching guidelines above
- Export as PNG (no transparency)

### Option 2: Use Online Generators
- Visit https://icon.kitchen/ or https://makeappicon.com/
- Create or upload your icon
- Download generated icons
- Place in this folder

### Option 3: Use Icon Templates
- Find free icon templates online
- Customize with your branding
- Export as 1024x1024px PNG

## Example Icon Ideas

For "Secure Values" app:
1. **Shield Icon**: Security/privacy theme
2. **Lock Icon**: Privacy/security theme
3. **Encrypted Document**: Storage theme
4. **Safe/Vault**: Values/storage theme
5. **Checkmark in Shield**: Security + values theme

## Quick Start Template

If you need a quick placeholder:
1. Create a simple blue shield icon
2. Add a white checkmark or star inside
3. Export as 1024x1024px PNG
4. Save as `app_icon.png` in this folder
5. Run `flutter pub run flutter_launcher_icons`

## Next Steps

After placing your icon files:
1. Run `flutter pub run flutter_launcher_icons`
2. Check generated icons in `android/app/src/main/res/mipmap-*/`
3. Test on device: `flutter run`
4. Verify icon appears correctly in launcher
5. Proceed with Google Play submission

## See Also

- **APP_ICON_GUIDE.md** - Complete icon creation guide
- **GOOGLE_PLAY_SUBMISSION.md** - Full submission guide

---

**Note**: Icon files are not included in this repository. You need to create your own icon following the guidelines above.
