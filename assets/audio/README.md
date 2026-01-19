# Audio Assets

## Required Files

### shofar.mp3
- **Purpose**: Shofar sound played when inappropriate content is detected
- **Format**: MP3 audio file
- **Location**: `assets/audio/shofar.mp3`
- **Usage**: Automatically played when detection triggers the overlay screen

## Instructions

1. Add your shofar audio file to this directory
2. Name it exactly `shofar.mp3`
3. The app will automatically play this sound when inappropriate content is detected

**Note**: If the audio file is not found, the app will continue to function without sound. This is intentional for graceful degradation.
