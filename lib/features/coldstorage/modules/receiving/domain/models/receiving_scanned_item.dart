class ReceivingScannedItem {
  const ReceivingScannedItem({
    required this.id,
    required this.seriesName,
    required this.custNo,
    required this.roomType,
    required this.receiveCategory,
    required this.custName,
    required this.palletAddress,
    required this.batch,
    required this.selectedDate,
    required this.qrCode,
    required this.createdAt,
  });

  final String id;
  final String seriesName;
  final String custNo;
  final String roomType;
  final String receiveCategory;
  final String custName;
  final String palletAddress;
  final String batch;
  final DateTime selectedDate;
  final String qrCode;
  final DateTime createdAt;

  String get selectedDateYmd =>
      '${selectedDate.year.toString().padLeft(4, '0')}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')}';

  Map<String, dynamic> toJson() => {
        'seriesname': seriesName,
        'custno': custNo,
        'roomtype': roomType,
        'receivecategory': receiveCategory,
        'custname': custName,
        'palletAddress': palletAddress,
        'batch': batch,
        'selectedDate': selectedDateYmd,
        'qrcode': qrCode,
      };
}
