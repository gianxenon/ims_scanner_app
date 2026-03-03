class ReceivingCustomerOption {
  const ReceivingCustomerOption({
    required this.code,
    required this.name,
  });

  final String code;
  final String name;

  String get label => '$code - $name';
}

class ReceivingLookupData {
  const ReceivingLookupData({
    this.seriesNames = const <String>[],
    this.customers = const <ReceivingCustomerOption>[],
    this.roomTypes = const <String>[],
    this.receivingCategories = const <String>[],
    this.locations = const <String>[],
    this.palletIds = const <String>[],
  });

  final List<String> seriesNames;
  final List<ReceivingCustomerOption> customers;
  final List<String> roomTypes;
  final List<String> receivingCategories;
  final List<String> locations;
  final List<String> palletIds;
}
