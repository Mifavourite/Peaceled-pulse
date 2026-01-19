# Assets Setup Guide

This document explains how to set up the local assets required for the enhanced detection experience.

## Security Note

All assets are stored **locally** on the device. No external downloads or network requests are made for these assets. This ensures:
- ✅ Complete privacy
- ✅ Offline functionality
- ✅ No external dependencies
- ✅ Fast performance

## Required Assets

### 1. Shofar Sound (`assets/audio/shofar.mp3`)

**Purpose**: Plays automatically when inappropriate content is detected

**Setup**:
1. Obtain a shofar sound file (MP3 format recommended)
2. Place it at: `assets/audio/shofar.mp3`
3. The app will automatically detect and play it

**Note**: If the file is missing, the app continues to function without sound.

### 2. Scripture Images (`assets/images/scriptures/`)

**Purpose**: Rotating images shown during the lock period to provide encouragement

**Required Files**:
- `scripture_1.png` through `scripture_15.png` (15 images total)

**Setup**:
1. Create or obtain 15 scripture images
2. Each should display a Bible verse in a visually appealing way
3. Recommended size: 800x600px minimum
4. Place all files in: `assets/images/scriptures/`

**Suggested Verses**:
See `assets/images/scriptures/README.md` for recommended scripture references.

**Note**: If images are missing, the app displays placeholder text with scripture references.

## Folder Structure

```
secure_flutter_app/
├── assets/
│   ├── audio/
│   │   ├── shofar.mp3          ← Add your audio file here
│   │   └── README.md
│   └── images/
│       └── scriptures/
│           ├── scripture_1.png  ← Add 15 images here
│           ├── scripture_2.png
│           ├── ...
│           ├── scripture_15.png
│           └── README.md
└── pubspec.yaml                 ← Already configured
```

## Verification

After adding assets, run:

```bash
flutter pub get
flutter run
```

The app will:
1. ✅ Automatically load assets on startup
2. ✅ Play shofar sound on detection
3. ✅ Rotate through scripture images during lock
4. ✅ Gracefully handle missing files (placeholders shown)

## Testing

To test the enhanced overlay:
1. Trigger a detection (confidence > threshold)
2. Verify shofar sound plays
3. Verify scripture images rotate every 4 seconds
4. Verify lock timer counts down (1-5 minutes, configurable)
5. Verify recovery screen appears after timer completes

## Customization

- **Lock Duration**: Adjustable in detection screen (1-5 minutes)
- **Image Rotation Speed**: Currently 4 seconds per image (configurable in code)
- **Audio Volume**: Controlled by device system volume
