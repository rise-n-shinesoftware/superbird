# Superbird AI Agent Guide

## Architecture Overview
Superbird is a Flutter mobile game using Flame 2D engine for gameplay. Core structure:
- **Game Logic**: `lib/game/superbird_game.dart` manages Flame components (Bird, Obstacles, Power Pickups) with physics, collisions, and power effects.
- **State Management**: `lib/state/game_session_controller.dart` uses Provider/ChangeNotifier for global state (coins, scores, unlocks), persisted via SharedPreferences.
- **UI Screens**: `lib/ui/screens/` - Home for stats/leaderboard, Gameplay overlays Flame game, Shop for suit unlocks.
- **Services**: `lib/services/` - LeaderboardService handles local (SharedPreferences) + optional Firestore cloud sync; AdService stubbed for rewarded revive.
- **Models**: `lib/models/power_suit.dart` defines 6 suits (Red default, others unlockable) with durations/cooldowns/costs.

Data flows from game updates to controller, screens watch controller via Provider. Firebase optional - app runs with local storage if not configured.

## Key Workflows
- **Run App**: `flutter run` (after `flutter pub get`)
- **Build APK**: `flutter build apk`
- **Lint/Analyze**: `flutter analyze`
- **Format**: `dart format lib`
- **Debug**: Standard Flutter debugger; game state via controller logs

## Conventions
- **State Updates**: Always call `notifyListeners()` after controller changes (e.g., `lib/state/game_session_controller.dart:165`).
- **Persistence**: Use SharedPreferences keys prefixed by feature (e.g., `_coinsKey = 'coins'` in controller).
- **UI Styling**: White containers with `border: Border.all(color: Color(0xFFDCEBFF))`, blue theme `Color(0xFF2563EB)`.
- **Game Components**: Extend Flame classes (e.g., `BirdComponent` as `CircleComponent`), handle collisions via `CollisionCallbacks`.
- **Power Mechanics**: Suits apply multipliers/cooldowns in game loop (e.g., `worldSpeedFactor` in `superbird_game.dart:44`); pickups spawn randomly in gaps.
- **Error Handling**: Firebase ops catch exceptions, fall back to local (e.g., `leaderboard_service.dart:54-63`).

## Integration Points
- **Firebase**: Optional; initialize in `main.dart:10-13`, configure via `google-services.json` for cloud leaderboard.
- **Ads**: Stubbed in `ad_service.dart`; replace with real SDK for rewarded revive flow.
- **Cross-Component**: Inject controller via Provider; game callbacks update state (e.g., `onGameOver` in `gameplay_screen.dart:28`).
