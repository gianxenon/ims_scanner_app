import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ims_scanner_app/common/widget/reusable_appbar/appbar.dart';
import 'package:ims_scanner_app/features/coldstorage/modules/receiving/domain/models/receiving_form_state.dart';
import 'package:ims_scanner_app/features/coldstorage/modules/receiving/domain/models/receiving_lookup_data.dart';
import 'package:ims_scanner_app/features/coldstorage/modules/receiving/presentation/providers/receiving_form_controller.dart';
import 'package:ims_scanner_app/features/coldstorage/modules/receiving/presentation/providers/receiving_lookup_provider.dart';
import 'package:ims_scanner_app/features/coldstorage/modules/receiving/presentation/widgets/scan_log_field.dart';
import 'package:ims_scanner_app/features/coldstorage/shared/domain/models/lookup_option.dart';
import 'package:ims_scanner_app/features/coldstorage/shared/widgets/searchable_lookup_field.dart';
import 'package:ims_scanner_app/utils/logging/logger.dart';

class ReceivingScreen extends ConsumerStatefulWidget {
  const ReceivingScreen({super.key});

  @override
  ConsumerState<ReceivingScreen> createState() => _ReceivingScreenState();
}

class _ReceivingScreenState extends ConsumerState<ReceivingScreen> {
  final TextEditingController _scanCtrl = TextEditingController();
  final FocusNode _scanFocusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _scanFieldKey = GlobalKey();
  String _hardwareScanBuffer = '';
  String _lastRoutedScan = '';
  DateTime? _lastRoutedAt;
  Timer? _scanIdleTimer;

  String? _selectedSeriesName;
  ReceivingCustomerOption? _selectedCustomer;
  String? _selectedRoomType;
  String? _selectedReceivingCategory;
  String? _selectedLocation;
  String? _selectedPalletId;
  DateTime? _selectedReceivingDate;

  bool get _isHeaderComplete {
    return _selectedSeriesName != null &&
        _selectedSeriesName!.trim().isNotEmpty &&
        _selectedCustomer != null &&
        _selectedRoomType != null &&
        _selectedRoomType!.trim().isNotEmpty &&
        _selectedReceivingCategory != null &&
        _selectedReceivingCategory!.trim().isNotEmpty &&
        _selectedReceivingDate != null &&
        _selectedLocation != null &&
        _selectedLocation!.trim().isNotEmpty &&
        _selectedPalletId != null &&
        _selectedPalletId!.trim().isNotEmpty;
  }

  @override
  void initState() {
    super.initState();
    _scanFocusNode.addListener(_handleScanFocusChange);
    HardwareKeyboard.instance.addHandler(_handleHardwareKeyEvent);
  }

  @override
  void dispose() {
    HardwareKeyboard.instance.removeHandler(_handleHardwareKeyEvent);
    _scanFocusNode.removeListener(_handleScanFocusChange);
    _scanIdleTimer?.cancel();
    _scrollController.dispose();
    _scanCtrl.dispose();
    _scanFocusNode.dispose();
    super.dispose();
  }

  void _hideSoftKeyboard() {
    SystemChannels.textInput.invokeMethod<void>('TextInput.hide');
  }

  void _setScanText(String value) {
    _scanCtrl.value = TextEditingValue(
      text: value,
      selection: TextSelection.collapsed(offset: value.length),
    );
  }

  void _clearScanInput() {
    _scanIdleTimer?.cancel();
    _hardwareScanBuffer = '';
    _setScanText('');
  }

  String _logSafe(String value) {
    return value.replaceAll('\n', r'\n').replaceAll('\r', r'\r');
  }

  String? _extractHardwareChar(KeyEvent event) {
    final direct = event.character;
    if (direct != null && direct.length == 1) {
      return direct;
    }
    final label = event.logicalKey.keyLabel;
    if (label.length == 1) {
      return label;
    }
    if (event.logicalKey == LogicalKeyboardKey.space) {
      return ' ';
    }
    return null;
  }

  bool _shouldSkipRecentDuplicateRoute(String scanned) {
    final now = DateTime.now();
    final isRecentDuplicate = _lastRoutedAt != null &&
        _lastRoutedScan == scanned &&
        now.difference(_lastRoutedAt!) < const Duration(milliseconds: 500);
    if (!isRecentDuplicate) {
      _lastRoutedScan = scanned;
      _lastRoutedAt = now;
    }
    return isRecentDuplicate;
  }

  bool _handleHardwareKeyEvent(KeyEvent event) {
    if (!_scanFocusNode.hasFocus || !_isHeaderComplete) return false;
    if (event is! KeyDownEvent) return false;

    final key = event.logicalKey;
    if (key == LogicalKeyboardKey.enter || key == LogicalKeyboardKey.numpadEnter) {
      final normalized = _hardwareScanBuffer.trim();
      AppLoggerHelper.info(
        '[ReceivingScan] hardware enter buffer="${_logSafe(normalized)}" len=${normalized.length}',
      );
      if (normalized.isNotEmpty) {
        _routeScannedInput(normalized);
      }
      return true;
    }

    if (key == LogicalKeyboardKey.backspace) {
      if (_hardwareScanBuffer.isNotEmpty) {
        _hardwareScanBuffer = _hardwareScanBuffer.substring(0, _hardwareScanBuffer.length - 1);
        _setScanText(_hardwareScanBuffer);
      }
      return true;
    }

    final char = _extractHardwareChar(event);
    if (char != null) {
      _hardwareScanBuffer += char;
      _setScanText(_hardwareScanBuffer);
      _scheduleScanIdleRoute(source: 'hardware_key');
      return true;
    }
    return false;
  }

  void _scheduleScanIdleRoute({required String source}) {
    _scanIdleTimer?.cancel();
    _scanIdleTimer = Timer(const Duration(milliseconds: 300), () {
      final candidate = (_scanCtrl.text.isNotEmpty ? _scanCtrl.text : _hardwareScanBuffer).trim();
      if (candidate.isEmpty) return;
      AppLoggerHelper.info(
        '[ReceivingScan] idle route source=$source value="${_logSafe(candidate)}" len=${candidate.length}',
      );
      _routeScannedInput(candidate);
    });
  }

  void _handleScanFocusChange() {
    AppLoggerHelper.debug('[ReceivingScan] focusChanged hasFocus=${_scanFocusNode.hasFocus}');
    debugPrint('[ReceivingScan] focusChanged hasFocus=${_scanFocusNode.hasFocus}');
    if (!_scanFocusNode.hasFocus) return;
    _hideSoftKeyboard();
    Future<void>.delayed(const Duration(milliseconds: 80), _hideSoftKeyboard);
  }

  void _showSnack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<bool> _confirmDeleteScanItem(String qrCode) async {
    if (!mounted) return false;
    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Remove Scanned Item'),
        content: Text('Delete this scanned QR code?\n$qrCode'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  String _formatDate(DateTime date) {
    final y = date.year.toString().padLeft(4, '0');
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  Future<void> _pickReceivingDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedReceivingDate ?? now,
      firstDate: DateTime(now.year - 3),
      lastDate: DateTime(now.year + 3),
    );

    if (picked == null || !mounted) return;

    setState(() {
      _selectedReceivingDate = picked;
    });
    _tryFocusScanner();
  }

  void _tryFocusScanner() {
    if (!_isHeaderComplete || !_scanFocusNode.canRequestFocus) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      FocusManager.instance.primaryFocus?.unfocus();
      FocusScope.of(context).requestFocus(_scanFocusNode);
      _hideSoftKeyboard();
    });
  }

  Future<void> _focusScannerFromAction({bool showErrorOnIncomplete = true}) async {
    if (!_isHeaderComplete) {
      if (showErrorOnIncomplete) {
        _showSnack('Please complete all fields before scanning.');
      }
      return;
    }

    AppLoggerHelper.debug(
      '[ReceivingScan] focus scanner requested; hasFocus=${_scanFocusNode.hasFocus}',
    );
    final scanContext = _scanFieldKey.currentContext;
    if (scanContext != null) {
      await Scrollable.ensureVisible(
        scanContext,
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
        alignment: 0.1,
      );
    }

    _tryFocusScanner();
  }

  Future<void> _handleScanAgainPressed() async {
    AppLoggerHelper.debug('[ReceivingScan] scan again pressed');
    await _focusScannerFromAction();
  }

  LookupOption? _findSelectedOption({
    required List<LookupOption> options,
    required String? value,
  }) {
    if (value == null || value.isEmpty) return null;
    for (final option in options) {
      if (option.value == value) return option;
    }
    return null;
  }

  bool _isValidReceivingQr(String value) {
    final rawParts = value.split('|');
    final hasTrailingPipe = rawParts.isNotEmpty && rawParts.last.trim().isEmpty;
    final trimmedParts = hasTrailingPipe ? rawParts.take(rawParts.length - 1) : rawParts;
    final parts = trimmedParts.map((part) => part.trim()).toList();
    if (parts.length != 10) return false;
    if (parts.any((part) => part.isEmpty)) return false;

    final dateRx = RegExp(r'^\d{2}/\d{2}/\d{4}$');
    if (!dateRx.hasMatch(parts[8]) || !dateRx.hasMatch(parts[9])) {
      return false;
    }

    return true;
  }

  double _extractNetWeight(String qrCode) {
    final parts = qrCode.split('|');
    if (parts.length < 4) return 0;
    return double.tryParse(parts[3].trim()) ?? 0;
  }

  void _routeScannedInput(String rawValue) {
    _scanIdleTimer?.cancel();
    final scanned = rawValue.trim();
    if (scanned.isEmpty) return;
    if (_shouldSkipRecentDuplicateRoute(scanned)) {
      AppLoggerHelper.debug('[ReceivingScan] skip duplicate route "$scanned"');
      return;
    }
    _hardwareScanBuffer = scanned;
    _setScanText(scanned);
    debugPrint('[ReceivingScan] route="$scanned" len=${scanned.length}');
    AppLoggerHelper.info(
      '[ReceivingScan] route raw="${_logSafe(rawValue)}" '
      'trimmed="${_logSafe(scanned)}" len=${scanned.length} segments=${scanned.split('|').length}',
    );

    final isQrCode = scanned.split('|').length > 1;
    if (isQrCode) {
      _handleScanSubmit(scanned);
      return;
    }

    if ((_selectedPalletId ?? '').trim().isNotEmpty) {
      _showSnack('Scanned barcode is not QR format. QR with "|" delimiters is required.');
    } else {
      _showSnack('Please select Pallet Id first, then scan QR code.');
    }

    _clearScanInput();
    _tryFocusScanner();
  }

  void _handleScanFieldChanged(String value) {
    if (value.isEmpty) return;
    _hardwareScanBuffer = value;
    final hasScannerSuffix = value.contains('\n') || value.contains('\r');
    if (!hasScannerSuffix) {
      _scheduleScanIdleRoute(source: 'text_field');
      return;
    }

    final normalized = value.replaceAll('\n', '').replaceAll('\r', '').trim();
    _hardwareScanBuffer = normalized;
    AppLoggerHelper.info(
      '[ReceivingScan] suffix detected raw="${_logSafe(value)}" '
      'normalized="${_logSafe(normalized)}" len=${normalized.length}',
    );
    debugPrint('[ReceivingScan] suffix normalized="$normalized" len=${normalized.length}');
    _setScanText(normalized);
    _routeScannedInput(normalized);
  }

  void _handleScanSubmit([String? value]) {
    final scannedValue = (value ?? _scanCtrl.text).trim();
    AppLoggerHelper.debug(
      '[ReceivingScan] submit attempt; headerComplete=$_isHeaderComplete, value="$scannedValue"',
    );

    if (scannedValue.isEmpty) return;

    if (!_isHeaderComplete) {
      _showSnack('Please complete all fields before scanning.');
      return;
    }

    if (!_isValidReceivingQr(scannedValue)) {
      AppLoggerHelper.warning(
        '[ReceivingScan] invalid QR format value="${_logSafe(scannedValue)}" '
        'segments=${scannedValue.split('|').length}',
      );
      debugPrint('[ReceivingScan] invalid="$scannedValue"');
      _showSnack(
        'Invalid QR format. Expected: '
        '111225-01|CS-NL-IB136|150|90|15|15|15|PAC|12/30/2026|12/11/2025|',
      );
      _clearScanInput();
      _tryFocusScanner();
      return;
    }

    final state = ref.read(receivingFormControllerProvider);
    final isDuplicate = state.scannedItems.any((item) => item.qrCode == scannedValue);
    if (isDuplicate) {
      AppLoggerHelper.warning(
        '[ReceivingScan] duplicate QR value="${_logSafe(scannedValue)}"',
      );
      _showSnack('This QR/Barcode is already in the list.');
      _clearScanInput();
      _tryFocusScanner();
      return;
    }

    ref.read(receivingFormControllerProvider.notifier).addItem(
          seriesName: _selectedSeriesName!,
          custNo: _selectedCustomer!.code,
          roomType: _selectedRoomType!,
          receiveCategory: _selectedReceivingCategory!,
          custName: _selectedCustomer!.name,
          palletAddress: _selectedLocation!,
          batch: _selectedPalletId!,
          selectedDate: _selectedReceivingDate!,
          qrCode: scannedValue,
        );

    final updatedState = ref.read(receivingFormControllerProvider);
    if (updatedState.formError != null) {
      _showSnack(updatedState.formError!);
      return;
    }

    AppLoggerHelper.info(
      '[ReceivingScan] saved; totalItems=${updatedState.scannedItems.length}',
    );
    debugPrint('[ReceivingScan] saved total=${updatedState.scannedItems.length} qr="$scannedValue"');

    _clearScanInput();
    _tryFocusScanner();
  }

  Future<void> _submit() async {
    final notifier = ref.read(receivingFormControllerProvider.notifier);
    final ok = await notifier.submit();

    if (!mounted) return;

    final state = ref.read(receivingFormControllerProvider);
    if (!ok) {
      if (state.formError != null) {
        _showSnack(state.formError!);
      }
      return;
    }

    _showSnack('Receiving payload prepared successfully.');
    notifier.clearAll();
    _clearScanInput();
    _tryFocusScanner();
  }

  Widget _buildLookupStatus(AsyncValue<ReceivingLookupData> lookupsAsync) {
    if (lookupsAsync.isLoading) {
      return const Column(
        children: [
          LinearProgressIndicator(),
          SizedBox(height: 12),
        ],
      );
    }

    if (lookupsAsync.hasError) {
      return Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Lookup data unavailable. You can continue with fallback values.',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
              TextButton(
                onPressed: () => ref.invalidate(receivingLookupProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
          const SizedBox(height: 8),
        ],
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildScanAndListSection(ReceivingFormState formState) {
    if (!_isHeaderComplete) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Text(
          'Complete all fields to enable QR/Barcode scanning and show QR code list.',
        ),
      );
    }

    final totalBarcodeCount = formState.scannedItems.length;
    final totalNetWeight = formState.scannedItems.fold<double>(
      0,
      (sum, item) => sum + _extractNetWeight(item.qrCode),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'QR Code List ($totalBarcodeCount)',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            Wrap(
              spacing: 4,
              children: [
                TextButton(
                  onPressed: formState.isSubmitting ? null : _handleScanAgainPressed,
                  child: const Text('Scan Again'),
                ),
                if (formState.scannedItems.isNotEmpty)
                  TextButton(
                    onPressed: formState.isSubmitting
                        ? null
                        : () {
                            ref.read(receivingFormControllerProvider.notifier).clearAll();
                            _tryFocusScanner();
                          },
                    child: const Text('Clear List'),
                  ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          'Total Net Weight: ${totalNetWeight.toStringAsFixed(2)}',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 8),
        if (formState.scannedItems.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Text('No scanned QR/Barcode yet.'),
          )
        else
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: Theme.of(context).colorScheme.outline),
              borderRadius: BorderRadius.circular(8),
            ),
            child: SizedBox(
              height: 240,
              child: ListView.separated(
                padding: const EdgeInsets.all(8),
                physics: const AlwaysScrollableScrollPhysics(),
                itemCount: formState.scannedItems.length,
                separatorBuilder: (_, _) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final item = formState.scannedItems[index];
                  return Card(
                    child: ListTile(
                      title: Text(item.qrCode),
                      subtitle: Text(
                        '${item.seriesName} | ${item.custNo} | ${item.selectedDateYmd}',
                      ),
                      trailing: IconButton(
                        onPressed: formState.isSubmitting
                            ? null
                            : () async {
                                final confirmed = await _confirmDeleteScanItem(item.qrCode);
                                if (!mounted || !confirmed) return;
                                ref
                                    .read(receivingFormControllerProvider.notifier)
                                    .removeScanItem(item.id);
                                _tryFocusScanner();
                              },
                        icon: const Icon(Icons.delete_outline, color: Colors.red),
                        tooltip: 'Remove',
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        const SizedBox(height: 16),
        KeyedSubtree(
          key: _scanFieldKey,
          child: ScanLogField(
            controller: _scanCtrl,
            focusNode: _scanFocusNode,
            enabled: !formState.isSubmitting,
            onClear: _clearScanInput,
            onTextChanged: _handleScanFieldChanged,
            onSubmitted: (value) {
              AppLoggerHelper.info(
                '[ReceivingScan] onFieldSubmitted value="${_logSafe(value)}"',
              );
              debugPrint('[ReceivingScan] onFieldSubmitted="$value"');
              _routeScannedInput(value);
            },
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Tip: Keep this field focused so handheld scanner can type and submit.',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final keyboardInset = MediaQuery.of(context).viewInsets.bottom;
    final formState = ref.watch(receivingFormControllerProvider);
    final lookupsAsync = ref.watch(receivingLookupProvider);
    final lookups = lookupsAsync.when(
      data: (value) => value,
      loading: () => const ReceivingLookupData(),
      error: (_, _) => const ReceivingLookupData(),
    );

    final seriesOptions = lookups.seriesNames
        .map((item) => LookupOption(value: item, label: item))
        .toList();

    final customerOptions = lookups.customers
        .map((item) => LookupOption(value: item.code, label: item.label))
        .toList();

    final roomTypeOptions = lookups.roomTypes
        .map((item) => LookupOption(value: item, label: item))
        .toList();

    final categoryOptions = lookups.receivingCategories
        .map((item) => LookupOption(value: item, label: item))
        .toList();

    final locationOptions = lookups.locations
        .map((item) => LookupOption(value: item, label: item))
        .toList();

    final palletIdOptions = lookups.palletIds
        .map((item) => LookupOption(value: item, label: item))
        .toList();

    return Scaffold(
      appBar: const AppReusableAppBar(
        title: Text('Receiving'),
        showBackArrow: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          controller: _scrollController,
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.manual,
          padding: EdgeInsets.fromLTRB(16, 16, 16, 16 + keyboardInset),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildLookupStatus(lookupsAsync),
              Text(
                'Receiving Setup',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 12),
              SearchableLookupField(
                label: 'Series Name',
                options: seriesOptions,
                selected: _findSelectedOption(
                  options: seriesOptions,
                  value: _selectedSeriesName,
                ),
                onSelected: (selected) {
                  setState(() {
                    _selectedSeriesName = selected.value;
                  });
                  _tryFocusScanner();
                },
              ),
              const SizedBox(height: 12),
              SearchableLookupField(
                label: 'Customer No',
                options: customerOptions,
                selected: _findSelectedOption(
                  options: customerOptions,
                  value: _selectedCustomer?.code,
                ),
                onSelected: (selected) {
                  setState(() {
                    final customer = lookups.customers.where((item) => item.code == selected.value);
                    if (customer.isNotEmpty) {
                      _selectedCustomer = customer.first;
                    } else {
                      _selectedCustomer = ReceivingCustomerOption(
                        code: selected.value,
                        name: selected.label,
                      );
                    }
                  });
                  _tryFocusScanner();
                },
              ),
              const SizedBox(height: 12),
              SearchableLookupField(
                label: 'Room Type',
                options: roomTypeOptions,
                selected: _findSelectedOption(
                  options: roomTypeOptions,
                  value: _selectedRoomType,
                ),
                onSelected: (selected) {
                  setState(() {
                    _selectedRoomType = selected.value;
                  });
                  _tryFocusScanner();
                },
              ),
              const SizedBox(height: 12),
              SearchableLookupField(
                label: 'Receiving Category',
                options: categoryOptions,
                selected: _findSelectedOption(
                  options: categoryOptions,
                  value: _selectedReceivingCategory,
                ),
                onSelected: (selected) {
                  setState(() {
                    _selectedReceivingCategory = selected.value;
                  });
                  _tryFocusScanner();
                },
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: _pickReceivingDate,
                icon: const Icon(Icons.calendar_month),
                label: Text(
                  _selectedReceivingDate == null
                      ? 'Select Receiving Date'
                      : 'Receiving Date: ${_formatDate(_selectedReceivingDate!)}',
                ),
              ),
              const SizedBox(height: 12),
              SearchableLookupField(
                label: 'Location',
                options: locationOptions,
                selected: _findSelectedOption(
                  options: locationOptions,
                  value: _selectedLocation,
                ),
                onSelected: (selected) {
                  setState(() {
                    _selectedLocation = selected.value;
                  });
                },
              ),
              const SizedBox(height: 12),
              SearchableLookupField(
                label: 'Pallet Id',
                options: palletIdOptions,
                selected: _findSelectedOption(
                  options: palletIdOptions,
                  value: _selectedPalletId,
                ),
                onSelected: (selected) {
                  setState(() {
                    _selectedPalletId = selected.value;
                  });
                  _tryFocusScanner();
                },
              ),
              const SizedBox(height: 16),
              _buildScanAndListSection(formState),
              if (formState.formError != null) ...[
                const SizedBox(height: 12),
                Text(
                  formState.formError!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ],
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: formState.isSubmitting || !_isHeaderComplete
                      ? null
                      : _submit,
                  child: formState.isSubmitting
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Submit Receiving'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
