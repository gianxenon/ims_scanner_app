import 'package:ims_scanner_app/features/coldstorage/modules/receiving/domain/models/receiving_lookup_data.dart';

class ReceivingLookupFallbackValues {
  ReceivingLookupFallbackValues._();

  static const List<String> seriesNames = <String>[
    'CS Receive',
  ];

  static const List<ReceivingCustomerOption> customers = <ReceivingCustomerOption>[
    ReceivingCustomerOption(
      code: 'BFFI',
      name: 'Bounty Fresh Foods Inc.',
    ),
  ];

  static const List<String> roomTypes = <String>[
    'Rack',
  ];

  static const List<String> receivingCategories = <String>[
    'IQF',
  ];

  static const List<String> locations = <String>[
    'DSP1-01-1A',
  ];

  static const List<String> palletIds = <String>[
    'PPUL000001',
  ];
}
