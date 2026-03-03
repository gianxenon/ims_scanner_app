import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class NetworkEndpointConfig {
  const NetworkEndpointConfig({
    required this.title,
    required this.url,
  });

  final String title;
  final String url;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'title': title,
      'url': url,
    };
  }

  factory NetworkEndpointConfig.fromJson(Map<String, dynamic> json) {
    return NetworkEndpointConfig(
      title: (json['title'] as String? ?? '').trim(),
      url: (json['url'] as String? ?? '').trim(),
    );
  }
}

class NetworkConfigStorage {
  NetworkConfigStorage._();

  static const String _endpointsKey = 'network_endpoints';
  static const String _selectedUrlKey = 'network_selected_url';
  static const FlutterSecureStorage _storage = FlutterSecureStorage();

  static Future<List<NetworkEndpointConfig>> readEndpoints() async {
    final raw = await _storage.read(key: _endpointsKey);
    if (raw == null || raw.trim().isEmpty) return <NetworkEndpointConfig>[];

    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) return <NetworkEndpointConfig>[];

      return decoded
          .whereType<Map<String, dynamic>>()
          .map(NetworkEndpointConfig.fromJson)
          .where((endpoint) => endpoint.title.isNotEmpty && endpoint.url.isNotEmpty)
          .toList();
    } catch (_) {
      return <NetworkEndpointConfig>[];
    }
  }

  static Future<void> saveEndpoints(List<NetworkEndpointConfig> endpoints) async {
    final jsonList = endpoints.map((endpoint) => endpoint.toJson()).toList();
    await _storage.write(
      key: _endpointsKey,
      value: jsonEncode(jsonList),
    );
  }

  static Future<String?> readSelectedUrl() async {
    final url = await _storage.read(key: _selectedUrlKey);
    if (url == null || url.trim().isEmpty) return null;
    return url.trim();
  }

  static Future<void> saveSelectedUrl(String url) async {
    final trimmed = url.trim();
    if (trimmed.isEmpty) return;
    await _storage.write(key: _selectedUrlKey, value: trimmed);
  }

  static Future<void> clear() async {
    await _storage.delete(key: _endpointsKey);
    await _storage.delete(key: _selectedUrlKey);
  }

  static Future<void> clearSelectedUrl() async {
    await _storage.delete(key: _selectedUrlKey);
  }
}
