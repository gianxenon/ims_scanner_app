import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:ims_scanner_app/features/authentication/data/local/branch_selection_storage.dart';
import 'package:ims_scanner_app/features/coldstorage/modules/receiving/domain/models/receiving_form_state.dart';
import 'package:ims_scanner_app/features/coldstorage/modules/receiving/domain/models/receiving_scanned_item.dart';
import 'package:ims_scanner_app/utils/logging/logger.dart';

final receivingFormControllerProvider =
    StateNotifierProvider<ReceivingFormController, ReceivingFormState>(
  (ref) => ReceivingFormController(),
);

class ReceivingFormController extends StateNotifier<ReceivingFormState> {
  ReceivingFormController() : super(const ReceivingFormState());

  void _setError(String message) {
    state = state.copyWith(formError: message);
  }

  bool _hasEmptyRequired(List<String> values) {
    return values.any((value) => value.trim().isEmpty);
  }

  void addItem({
    required String seriesName,
    required String custNo,
    required String roomType,
    required String receiveCategory,
    required String custName,
    required String palletAddress,
    required String batch,
    required DateTime selectedDate,
    required String qrCode,
  }) {
    final cleanSeriesName = seriesName.trim();
    final cleanCustNo = custNo.trim();
    final cleanRoomType = roomType.trim();
    final cleanReceiveCategory = receiveCategory.trim();
    final cleanCustName = custName.trim();
    final cleanPalletAddress = palletAddress.trim();
    final cleanBatch = batch.trim();
    final cleanQr = qrCode.trim();

    if (_hasEmptyRequired(<String>[
      cleanSeriesName,
      cleanCustNo,
      cleanRoomType,
      cleanReceiveCategory,
      cleanCustName,
      cleanPalletAddress,
      cleanBatch,
      cleanQr,
    ])) {
      _setError('Please complete all required fields before adding.');
      return;
    }

    final now = DateTime.now();
    final item = ReceivingScannedItem(
      id: now.microsecondsSinceEpoch.toString(),
      seriesName: cleanSeriesName,
      custNo: cleanCustNo,
      roomType: cleanRoomType,
      receiveCategory: cleanReceiveCategory,
      custName: cleanCustName,
      palletAddress: cleanPalletAddress,
      batch: cleanBatch,
      selectedDate: selectedDate,
      qrCode: cleanQr,
      createdAt: now,
    );

    state = state.copyWith(
      scannedItems: <ReceivingScannedItem>[...state.scannedItems, item],
      clearFormError: true,
    );

    AppLoggerHelper.info(
      '[ReceivingScan] controller saved qr="$cleanQr" total=${state.scannedItems.length}',
    );
  }

  void removeScanItem(String id) {
    state = state.copyWith(
      scannedItems: state.scannedItems.where((item) => item.id != id).toList(),
      clearFormError: true,
    );
  }

  void clearAll() {
    state = const ReceivingFormState();
  }

  void clearError() {
    state = state.copyWith(clearFormError: true);
  }

  Map<String, dynamic> buildPayload({
    required String company,
    required String branch,
  }) {
    return <String, dynamic>{
      'company': company.trim(),
      'branch': branch.trim(),
      'receiving': state.scannedItems.map((item) => item.toJson()).toList(),
    };
  }

  Future<bool> submit() async {
    final selectedBranch = await BranchSelectionStorage.readSelectedBranch();
    final company = selectedBranch?.companyCode.trim() ?? '';
    final branch = selectedBranch?.branchCode.trim() ?? '';

    if (company.isEmpty || branch.isEmpty) {
      _setError('Please select a valid branch in Settings first.');
      return false;
    }

    if (!state.canSubmit) {
      _setError('Please add at least one receiving line before submit.');
      return false;
    }

    state = state.copyWith(isSubmitting: true, clearFormError: true);
    try {
      final payload = buildPayload(company: company, branch: branch);

      // TODO: connect repository/API call here.
      debugPrint('Receiving payload: $payload');
      return true;
    } catch (_) {
      _setError('Failed to submit receiving payload.');
      return false;
    } finally {
      state = state.copyWith(isSubmitting: false);
    }
  }
}
