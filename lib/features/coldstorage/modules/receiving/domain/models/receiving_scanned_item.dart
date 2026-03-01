class ReceivingScannedItem {
  const ReceivingScannedItem({
    required this.id,
    required this.barcode,
    required this.qty,
    required this.createdAt,
  });

  final String id;
  final String barcode;
  final int qty;
  final DateTime createdAt;
}
