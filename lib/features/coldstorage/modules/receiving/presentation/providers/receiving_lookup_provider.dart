import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ims_scanner_app/features/authentication/data/local/branch_selection_storage.dart';
import 'package:ims_scanner_app/features/coldstorage/modules/receiving/data/repositories/receiving_lookup_repository.dart';
import 'package:ims_scanner_app/features/coldstorage/modules/receiving/domain/models/receiving_lookup_data.dart';
import 'package:ims_scanner_app/features/coldstorage/shared/constants/receiving_lookup_fallback_values.dart';
import 'package:ims_scanner_app/utils/logging/logger.dart';

final receivingLookupRepositoryProvider = Provider<ReceivingLookupRepository>(
  (ref) => ReceivingLookupRepository(),
);

final receivingLookupProvider = FutureProvider<ReceivingLookupData>((ref) async {
  final repository = ref.read(receivingLookupRepositoryProvider);
  final selectedBranch = await BranchSelectionStorage.readSelectedBranch();
  final company = selectedBranch?.companyCode.trim() ?? '';
  final branch = selectedBranch?.branchCode.trim() ?? '';

  if (company.isEmpty || branch.isEmpty) {
    AppLoggerHelper.warning(
      '[ReceivingLookup] Branch not selected. Using static fallback lookup data.',
    );
    return _applyFallback(const ReceivingLookupData());
  }

  try {
    final data = await repository.fetchLookups(company: company, branch: branch);
    AppLoggerHelper.info('[ReceivingLookup] Lookup fetch completed.');
    return _applyFallback(data);
  } catch (e) {
    AppLoggerHelper.error('[ReceivingLookup] Lookup fetch failed.', e);
    return _applyFallback(const ReceivingLookupData());
  }
});

ReceivingLookupData _applyFallback(ReceivingLookupData data) {
  final result = ReceivingLookupData(
    seriesNames: data.seriesNames.isNotEmpty
        ? data.seriesNames
        : ReceivingLookupFallbackValues.seriesNames,
    customers: data.customers.isNotEmpty
        ? data.customers
        : ReceivingLookupFallbackValues.customers,
    roomTypes: data.roomTypes.isNotEmpty
        ? data.roomTypes
        : ReceivingLookupFallbackValues.roomTypes,
    receivingCategories: data.receivingCategories.isNotEmpty
        ? data.receivingCategories
        : ReceivingLookupFallbackValues.receivingCategories,
    locations: data.locations.isNotEmpty
        ? data.locations
        : ReceivingLookupFallbackValues.locations,
    palletIds: data.palletIds.isNotEmpty
        ? data.palletIds
        : ReceivingLookupFallbackValues.palletIds,
  );

  AppLoggerHelper.info(
    '[ReceivingLookup] final counts after fallback: '
    'series=${result.seriesNames.length}, customers=${result.customers.length}, '
    'roomTypes=${result.roomTypes.length}, categories=${result.receivingCategories.length}, '
    'locations=${result.locations.length}, palletIds=${result.palletIds.length}',
  );

  return result;
}
