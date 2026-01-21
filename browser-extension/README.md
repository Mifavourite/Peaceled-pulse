# Recovery Journey Browser Extension

This browser extension automatically detects and warns you when you attempt to access inappropriate content.

## Installation

### Chrome/Edge:
1. Open Chrome/Edge and go to `chrome://extensions/` (or `edge://extensions/`)
2. Enable "Developer mode" (toggle in top right)
3. Click "Load unpacked"
4. Select the `browser-extension` folder from this project
5. The extension is now installed!

### Firefox:
1. Open Firefox and go to `about:debugging`
2. Click "This Firefox"
3. Click "Load Temporary Add-on"
4. Select the `manifest.json` file from the `browser-extension` folder

## Features

- **Automatic Detection**: Monitors all URLs you visit
- **Bible Verse Warnings**: Shows relevant Bible verses when inappropriate content is detected
- **Attempt Logging**: Tracks all attempts (visible in the app)
- **Privacy**: All data stays local, nothing is sent to servers

## How It Works

The extension checks every URL you visit against a list of inappropriate keywords. If a match is found, it:
1. Logs the attempt
2. Shows a warning page with a Bible verse
3. Prevents access to the inappropriate content

## Integration with App

The extension works alongside the Recovery Journey web app. All attempts are logged and can be viewed in the app's dashboard.

## Privacy

- All detection happens locally in your browser
- No data is sent to external servers
- All logs are stored locally in your browser
