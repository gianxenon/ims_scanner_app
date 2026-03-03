import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:ims_scanner_app/features/coldstorage/modules/receiving/domain/models/receiving_lookup_data.dart';
import 'package:ims_scanner_app/features/coldstorage/shared/constants/cold_storage_api_paths.dart';
import 'package:ims_scanner_app/utils/http/http_client.dart';
import 'package:ims_scanner_app/utils/logging/logger.dart';

class ReceivingLookupRepository {
  Future<ReceivingLookupData> fetchLookups({
    required String company,
    required String branch,
  }) async {
    AppLoggerHelper.info(
      '[ReceivingLookup] Fetching lookups for company=$company branch=$branch',
    );

    final query = <String, dynamic>{
      'company': company,
      'branch': branch,
    };

    final responses = await Future.wait<Response<dynamic>?>([
      _safeGet(
        label: 'series',
        path: ColdStorageApiPaths.receivingSeriesNames,
        query: query,
      ),
      _safeGet(
        label: 'customers',
        path: ColdStorageApiPaths.receivingCustomers,
        query: query,
      ),
      _safeGet(
        label: 'roomTypes',
        path: ColdStorageApiPaths.receivingRoomTypes,
        query: query,
      ),
      _safeGet(
        label: 'categories',
        path: ColdStorageApiPaths.receivingCategories,
        query: query,
      ),
      _safeGet(
        label: 'locations',
        path: ColdStorageApiPaths.locations,
        query: query,
      ),
      _safeGet(
        label: 'palletIds',
        path: ColdStorageApiPaths.palletAddresses,
        query: query,
      ),
    ]);

    final series = _parseStringList(
      responses[0]?.data,
      containerKeys: const <String>['series', 'items', 'data'],
      valueKeys: const <String>['seriesname', 'name', 'value', 'label'],
    );

    final customers = _parseCustomers(responses[1]?.data);

    final roomTypes = _parseStringList(
      responses[2]?.data,
      containerKeys: const <String>['roomTypes', 'rooms', 'items', 'data'],
      valueKeys: const <String>['roomtype', 'roomType', 'name', 'value', 'label'],
    );

    final categories = _parseStringList(
      responses[3]?.data,
      containerKeys: const <String>['categories', 'items', 'data'],
      valueKeys: const <String>['receivecategory', 'category', 'name', 'value', 'label'],
    );

    final locations = _parseStringList(
      responses[4]?.data,
      containerKeys: const <String>['locations', 'items', 'data'],
      valueKeys: const <String>['code', 'location', 'address', 'name', 'value', 'label'],
    );

    final palletIds = _parseStringList(
      responses[5]?.data,
      containerKeys: const <String>['pallets', 'items', 'data'],
      valueKeys: const <String>['code', 'palletId', 'palletid', 'name', 'value', 'label'],
    );

    AppLoggerHelper.info(
      '[ReceivingLookup] statuses: series=${responses[0]?.statusCode}, '
      'customers=${responses[1]?.statusCode}, roomTypes=${responses[2]?.statusCode}, '
      'categories=${responses[3]?.statusCode}, locations=${responses[4]?.statusCode}, '
      'palletIds=${responses[5]?.statusCode}',
    );
    AppLoggerHelper.info(
      '[ReceivingLookup] counts: series=${series.length}, customers=${customers.length}, '
      'roomTypes=${roomTypes.length}, categories=${categories.length}, '
      'locations=${locations.length}, palletIds=${palletIds.length}',
    );

    return ReceivingLookupData(
      seriesNames: series,
      customers: customers,
      roomTypes: roomTypes,
      receivingCategories: categories,
      locations: locations,
      palletIds: palletIds,
    );
  }

  Future<Response<dynamic>?> _safeGet({
    required String label,
    required String path,
    required Map<String, dynamic> query,
  }) async {
    try {
      final response = await AppHttpClient.dio.get(path, queryParameters: query);
      AppLoggerHelper.info(
        '[ReceivingLookup] $label request OK status=${response.statusCode} path=$path',
      );
      return response;
    } catch (e) {
      AppLoggerHelper.error(
        '[ReceivingLookup] $label request failed path=$path query=$query',
        e,
      );
      return null;
    }
  }

  List<ReceivingCustomerOption> _parseCustomers(dynamic data) {
    final rawList = _extractList(
      data,
      const <String>['customers', 'items', 'data'],
    );
    if (rawList == null) return <ReceivingCustomerOption>[];

    final result = <ReceivingCustomerOption>[];
    final seen = <String>{};

    for (final entry in rawList) {
      String code = '';
      String name = '';

      if (entry is String) {
        code = entry.trim();
        name = entry.trim();
      } else if (entry is Map) {
        final map = entry.map((k, v) => MapEntry(k.toString(), v));
        code = _pickString(
          map,
          const <String>['custno', 'customerNo', 'customer_code', 'code', 'id', 'value'],
        );
        name = _pickString(
          map,
          const <String>['custname', 'customerName', 'customer_name', 'name', 'label'],
        );
      }

      if (code.isEmpty && name.isEmpty) continue;
      if (code.isEmpty) code = name;
      if (name.isEmpty) name = code;

      final key = '$code|$name';
      if (seen.add(key)) {
        result.add(
          ReceivingCustomerOption(
            code: code,
            name: name,
          ),
        );
      }
    }

    return result;
  }

  List<String> _parseStringList(
    dynamic data, {
    required List<String> containerKeys,
    required List<String> valueKeys,
  }) {
    final rawList = _extractList(data, containerKeys);
    if (rawList == null) return <String>[];

    final values = <String>{};
    for (final entry in rawList) {
      String value = '';
      if (entry is String) {
        value = entry.trim();
      } else if (entry is Map) {
        final map = entry.map((k, v) => MapEntry(k.toString(), v));
        value = _pickString(map, valueKeys);
      }
      if (value.isNotEmpty) values.add(value);
    }
    return values.toList();
  }

  List<dynamic>? _extractList(dynamic data, List<String> keys) {
    if (data is List) return data;

    final map = _asMap(data);
    if (map.isEmpty) return null;

    for (final key in keys) {
      final candidate = map[key];
      if (candidate is List) return candidate;
    }

    return null;
  }

  Map<String, dynamic> _asMap(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) return value.map((k, v) => MapEntry(k.toString(), v));
    if (value is String) {
      try {
        final decoded = jsonDecode(value);
        if (decoded is Map<String, dynamic>) return decoded;
        if (decoded is Map) return decoded.map((k, v) => MapEntry(k.toString(), v));
      } catch (_) {
        return <String, dynamic>{};
      }
    }
    return <String, dynamic>{};
  }

  String _pickString(Map<String, dynamic> map, List<String> keys) {
    for (final key in keys) {
      final value = map[key]?.toString().trim() ?? '';
      if (value.isNotEmpty) return value;
    }
    return '';
  }
}
