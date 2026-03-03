import 'package:ims_scanner_app/features/coldstorage/modules/receiving/domain/models/receiving_scanned_item.dart';

class ReceivingFormState {
  const ReceivingFormState({
    this.scannedItems = const <ReceivingScannedItem>[],
    this.isSubmitting = false,
    this.formError,
  });

  final List<ReceivingScannedItem> scannedItems;
  final bool isSubmitting;
  final String? formError;

  bool get hasItems => scannedItems.isNotEmpty;

  bool get canSubmit => hasItems && !isSubmitting;

  ReceivingFormState copyWith({
    List<ReceivingScannedItem>? scannedItems,
    bool? isSubmitting,
    String? formError,
    bool clearFormError = false,
  }) {
    return ReceivingFormState(
      scannedItems: scannedItems ?? this.scannedItems,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      formError: clearFormError ? null : (formError ?? this.formError),
    );
  }
}
