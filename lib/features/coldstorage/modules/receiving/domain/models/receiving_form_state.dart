import 'package:ims_scanner_app/features/coldstorage/modules/receiving/domain/models/receiving_scanned_item.dart';

class ReceivingFormState {
  const ReceivingFormState({
    this.supplierCode = '',
    this.deliveryNo = '',
    this.palletTag = '',
    this.barcodeInput = '',
    this.quantityInput = '1',
    this.remarks = '',
    this.scannedItems = const <ReceivingScannedItem>[],
    this.isSubmitting = false,
    this.formError,
  });

  final String supplierCode;
  final String deliveryNo;
  final String palletTag;
  final String barcodeInput;
  final String quantityInput;
  final String remarks;
  final List<ReceivingScannedItem> scannedItems;
  final bool isSubmitting;
  final String? formError;

  bool get hasRequiredHeader =>
      supplierCode.trim().isNotEmpty && deliveryNo.trim().isNotEmpty;

  bool get hasItems => scannedItems.isNotEmpty;

  bool get canSubmit => hasRequiredHeader && hasItems && !isSubmitting;

  ReceivingFormState copyWith({
    String? supplierCode,
    String? deliveryNo,
    String? palletTag,
    String? barcodeInput,
    String? quantityInput,
    String? remarks,
    List<ReceivingScannedItem>? scannedItems,
    bool? isSubmitting,
    String? formError,
    bool clearFormError = false,
  }) {
    return ReceivingFormState(
      supplierCode: supplierCode ?? this.supplierCode,
      deliveryNo: deliveryNo ?? this.deliveryNo,
      palletTag: palletTag ?? this.palletTag,
      barcodeInput: barcodeInput ?? this.barcodeInput,
      quantityInput: quantityInput ?? this.quantityInput,
      remarks: remarks ?? this.remarks,
      scannedItems: scannedItems ?? this.scannedItems,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      formError: clearFormError ? null : (formError ?? this.formError),
    );
  }
}
