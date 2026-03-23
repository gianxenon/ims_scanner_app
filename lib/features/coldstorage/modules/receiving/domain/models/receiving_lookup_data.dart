class ReceivingCustomerOption {
  const ReceivingCustomerOption({
    required this.code,
    required this.name,
  });

  final String code;
  final String name;

  String get label => '$code - $name';
}

class ReceivingSeriesOption {
  const ReceivingSeriesOption({
    required this.code,
    required this.name,
  });

  final String code;
  final String name;

  String get label {
    if (name.isEmpty || name == code) return code;
    return '$code - $name';
  }
}

class ReceivingLookupData {
  const ReceivingLookupData({
    this.seriesNames = const <ReceivingSeriesOption>[],
    this.customers = const <ReceivingCustomerOption>[],
    this.roomTypes = const <String>[],
    this.receivingCategories = const <String>[],
    this.locations = const <String>[],
    this.palletIds = const <String>[],
  });

  final List<ReceivingSeriesOption> seriesNames;
  final List<ReceivingCustomerOption> customers;
  final List<String> roomTypes;
  final List<String> receivingCategories;
  final List<String> locations;
  final List<String> palletIds;
}
