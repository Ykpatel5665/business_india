import 'package:shared_preferences/shared_preferences.dart';

/// Service for loading and saving user profile data (avatar index and name).
class ProfileService {
  static const String _avatarKey = 'avatarIndex';
  static const String _nameKey = 'userName';

  /// Loads the saved avatar index and user name from persistent storage.
  static Future<ProfileData> loadProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final avatarIdx = prefs.getInt(_avatarKey) ?? 0;
    final name = prefs.getString(_nameKey) ?? '';
    return ProfileData(avatarIndex: avatarIdx, name: name);
  }

  /// Saves the avatar index and user name to persistent storage.
  static Future<void> saveProfile({required int avatarIndex, required String name}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_avatarKey, avatarIndex);
    await prefs.setString(_nameKey, name);
  }
}

/// Simple data class for user profile info.
class ProfileData {
  final int avatarIndex;
  final String name;
  const ProfileData({required this.avatarIndex, required this.name});
}
