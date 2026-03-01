import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:ims_scanner_app/features/coldstorage/modules/receiving/domain/models/receiving_form_state.dart';
import 'package:ims_scanner_app/features/coldstorage/modules/receiving/domain/models/receiving_scanned_item.dart';

final receivingFormControllerProvider =
    StateNotifierProvider<ReceivingFormController, ReceivingFormState>(
  (ref) => ReceivingFormController(),
);

class ReceivingFormController extends StateNotifier<ReceivingFormState> {
  ReceivingFormController() : super(const ReceivingFormState());

  void updateSupplierCode(String value) {
    state = state.copyWith(
      supplierCode: value,
      clearFormError: true,
    );
  }

  void updateDeliveryNo(String value) {
    state = state.copyWith(
      deliveryNo: value,
      clearFormError: true,
    );
  }

  void updatePalletTag(String value) {
    state = state.copyWith(
      palletTag: value,
      clearFormError: true,
    );
  }

  void updateBarcodeInput(String value) {
    state = state.copyWith(
      barcodeInput: value,
      clearFormError: true,
    );
  }

  void updateQuantityInput(String value) {
    state = state.copyWith(
      quantityInput: value,
      clearFormError: true,
    );
  }

  void updateRemarks(String value) {
    state = state.copyWith(
      remarks: value,
      clearFormError: true,
    );
  }

  void addCurrentScan() {
    final barcode = state.barcodeInput.trim();
    if (barcode.isEmpty) {
      state = state.copyWith(formError: 'Scan barcode is required.');
      return;
    }

    final qty = int.tryParse(state.quantityInput.trim()) ?? 0;
    if (qty <= 0) {
      state = state.copyWith(formError: 'Quantity must be greater than 0.');
      return;
    }

    final item = ReceivingScannedItem(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      barcode: barcode,
      qty: qty,
      createdAt: DateTime.now(),
    );

    state = state.copyWith(
      scannedItems: <ReceivingScannedItem>[...state.scannedItems, item],
      barcodeInput: '',
      quantityInput: '1',
      clearFormError: true,
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

  Future<bool> submit() async {
    if (!state.canSubmit) {
      state = state.copyWith(
        formError:
            'Please complete required fields and add at least one scanned item.',
      );
      return false;
    }

    state = state.copyWith(isSubmitting: true, clearFormError: true);
    try {
      // TODO: connect repository/API and local queue here.
      return true;
    } finally {
      state = state.copyWith(isSubmitting: false);
    }
  }
}
