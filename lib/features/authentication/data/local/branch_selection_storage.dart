import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:ims_scanner_app/features/authentication/domain/models/branch_option.dart';

class BranchSelectionStorage {
  BranchSelectionStorage._();

  static const FlutterSecureStorage _storage = FlutterSecureStorage();
  static const String _selectedBranchKey = 'selected_branch';

  static Future<void> saveSelectedBranch(BranchOption branch) async {
    await _storage.write(
      key: _selectedBranchKey,
      value: jsonEncode(branch.toJson()),
    );
  }

  static Future<BranchOption?> readSelectedBranch() async {
    final raw = await _storage.read(key: _selectedBranchKey);
    if (raw == null || raw.trim().isEmpty) return null;

    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map) return null;
      final mapped = decoded.map((key, value) => MapEntry(key.toString(), value));
      final branch = BranchOption.fromJson(mapped);
      if (branch.companyCode.isEmpty || branch.branchCode.isEmpty) return null;
      return branch;
    } catch (_) {
      return null;
    }
  }

  static Future<void> clear() async {
    await _storage.delete(key: _selectedBranchKey);
  }
}
