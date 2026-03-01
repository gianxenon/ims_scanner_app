import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:ims_scanner_app/features/authentication/domain/models/branch_option.dart';
import 'package:ims_scanner_app/utils/http/http_client.dart';

class BranchesRepository {
  Future<List<BranchOption>> fetchBranches([String? userId]) async {
    final query = <String, dynamic>{};
    final cleaned = userId?.trim() ?? '';
    if (cleaned.isNotEmpty) {
      query['userid'] = cleaned;
    }

    final response = await AppHttpClient.dio.get(
      'api/branches',
      queryParameters: query,
      options: Options(
        receiveTimeout: const Duration(seconds: 45),
      ),
    );

    final data = _asMap(response.data);
    final rawList = data['branches'];
    if (rawList is! List) return <BranchOption>[];

    return rawList
        .whereType<Map>()
        .map((entry) => entry.map((k, v) => MapEntry(k.toString(), v)))
        .map(BranchOption.fromJson)
        .where((item) => item.companyCode.isNotEmpty && item.branchCode.isNotEmpty)
        .toList();
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
}
