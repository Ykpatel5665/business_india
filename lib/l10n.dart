// Localization entry point for Business India Game App.
// This file is a placeholder for future multi-language support.
//
// To add localization:
// 1. Add ARB files in lib/l10n/ (e.g., app_en.arb, app_hi.arb).
// 2. Use Flutter's intl tools to generate localization code.
// 3. Replace hardcoded strings in the app with lookups from AppLocalizations.

// Example usage (after setup):
// AppLocalizations.of(context)!.loginTitle

// For now, all strings are hardcoded in English.

class AppStrings {
  static const String selectGameMode = 'Please select a game mode to continue.';
  static const String continueBtn = 'Continue';
  static const String profileTooltip = 'Profile';
  static const String friendsTooltip = 'Friends';
  static const String settingsTooltip = 'Settings';
  static const String editProfileTooltip = 'Edit profile (name & avatar)';

  static const String soloChallenge = 'Solo Challenge';
  static const String soloChallengeDesc = 'Play against AI and test your skills.';
  static const String localMultiplayer = 'Local Multiplayer';
  static const String localMultiplayerDesc = 'Play with friends on the same device.';
  static const String globalMatch = 'Global Match';
  static const String globalMatchDesc = 'Compete with players worldwide.';
  static const String privateRoom = 'Private Room';
  static const String privateRoomDesc = 'Create or join a private game room.';
}
