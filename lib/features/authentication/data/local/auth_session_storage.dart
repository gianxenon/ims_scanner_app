import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthSessionStorage {
  AuthSessionStorage._();

  static const FlutterSecureStorage _storage = FlutterSecureStorage();
  static const String _userIdKey = 'auth_user_id';

  static Future<void> saveUserId(String userId) async {
    final trimmed = userId.trim();
    if (trimmed.isEmpty) return;
    await _storage.write(key: _userIdKey, value: trimmed);
  }

  static Future<String?> readUserId() async {
    final value = await _storage.read(key: _userIdKey);
    if (value == null || value.trim().isEmpty) return null;
    return value.trim();
  }

  static Future<void> clear() async {
    await _storage.delete(key: _userIdKey);
  }
}
