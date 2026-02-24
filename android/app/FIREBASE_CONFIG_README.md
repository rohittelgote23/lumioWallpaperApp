# Firebase Configuration Files

This directory should contain your Firebase configuration files:

## Android
- `google-services.json` - Download from Firebase Console

## iOS  
- `GoogleService-Info.plist` - Download from Firebase Console (place in `ios/Runner/`)

## Setup Instructions

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select your project
3. Add Android app:
   - Click "Add app" → Android
   - Package name: `com.example.lumiowalls`
   - Download `google-services.json`
   - Place in `android/app/`

4. Add iOS app:
   - Click "Add app" → iOS
   - Bundle ID: (from Xcode project)
   - Download `GoogleService-Info.plist`
   - Place in `ios/Runner/`

**IMPORTANT**: Never commit actual Firebase config files to version control!

Add to `.gitignore`:
```
android/app/google-services.json
ios/Runner/GoogleService-Info.plist
```

See [FIREBASE_SETUP.md](../FIREBASE_SETUP.md) for detailed setup instructions.
