# Superbird Quickstart

## Prerequisites
- Flutter SDK 3.3+
- Dart SDK (bundled with Flutter)
- Android Studio / Xcode toolchains for device targets

## 1) Install dependencies
```bash
flutter pub get
```

## 2) Create missing platform folders (if needed)
Run once in project root if `android/` and `ios/` are missing:
```bash
flutter create .
```

## 3) Run the game
```bash
flutter run
```

## Game features included
- Flappy-style tap-to-fly gameplay
- 6 suit-based powers with durations/cooldowns
- Rewarded revive flow
- Daily rewards + coin-based suit unlocks
- Local leaderboard + optional Firestore cloud sync fallback

## Firebase (optional cloud leaderboard)
1. Configure Firebase project for Android/iOS
2. Add platform configs (`google-services.json`, `GoogleService-Info.plist`)
3. Ensure Firestore is enabled

If Firebase is not configured, the game continues using local leaderboard storage.

## Useful commands
- Analyze:
```bash
flutter analyze
```
- Format:
```bash
dart format lib
```
- Build Android APK:
```bash
flutter build apk
```
