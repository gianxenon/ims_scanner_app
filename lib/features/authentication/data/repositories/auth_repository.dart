import 'dart:convert';

import 'package:ims_scanner_app/features/authentication/domain/models/auth_user.dart';
import 'package:ims_scanner_app/utils/http/http_client.dart';
import 'package:logger/logger.dart';

class AuthRepository {
  final logger = Logger();

  Future<void> login({required String userId, required String password}) async {
    final res = await AppHttpClient.dio.post(
      'api/auth/login',
      data: {'userid': userId, 'password': password},
    );

    final data = _asMap(res.data);
    logger.d('POST ${res.realUri} -> ${res.statusCode}, response: ${res.data}');

    final nested = data['php'] is Map
        ? Map<String, dynamic>.from(data['php'] as Map)
        : <String, dynamic>{};
    final ok = data['ok'] == true ||
        data['success'] == true ||
        nested['ok'] == true ||
        nested['success'] == true;
    final message = data['message']?.toString() ?? nested['message']?.toString();

    if (res.statusCode != 200 || !ok) {
      throw Exception(message ?? 'Invalid credentials');
    }
  }

  Future<bool> me() async {
    try {
      await fetchMe();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<AuthUser> fetchMe() async {
    final res = await AppHttpClient.dio.get('api/auth/me');
    final data = _asMap(res.data);
    final user = _asMap(data['user']);

    if (res.statusCode != 200 || user.isEmpty) {
      final message = data['message']?.toString() ?? 'Unauthorized';
      throw Exception(message);
    }

    final userid = _valueAsString(user['userid']);
    if (userid.isEmpty) {
      throw Exception('Invalid user profile payload.');
    }

    return AuthUser(
      userId: userid,
      name: _valueAsString(user['name']),
      email: _valueAsString(user['email']),
      groupId: _valueAsString(user['groupid']),
      roleId: _valueAsString(user['roleid']),
      isValid: _valueAsString(user['isValid']),
      lockout: _valueAsString(user['lockout']),
      mobileNo: _valueAsString(user['mobileNo']),
      avatar: _valueAsString(user['avatar']),
    );
  }

  Future<void> logout() async {
    await AppHttpClient.dio.post('api/auth/logout');
  }

  Map<String, dynamic> _asMap(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) return value.map((k, v) => MapEntry(k.toString(), v));
    if (value is String) {
      try {
        final decoded = jsonDecode(value);
        if (decoded is Map<String, dynamic>) return decoded;
        if (decoded is Map) {
          return decoded.map((k, v) => MapEntry(k.toString(), v));
        }
      } catch (_) {
        return <String, dynamic>{};
      }
    }
    return <String, dynamic>{};
  }

  String _valueAsString(dynamic value) {
    return value?.toString().trim() ?? '';
  }
}
