import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ScanLogField extends StatefulWidget {
  const ScanLogField({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.onTextChanged,
    required this.onSubmitted,
    required this.onClear,
    this.enabled = true,
    this.title = 'QRCode/Barcode Scan Log',
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onTextChanged;
  final ValueChanged<String> onSubmitted;
  final VoidCallback onClear;
  final bool enabled;
  final String title;

  @override
  State<ScanLogField> createState() => _ScanLogFieldState();
}

class _ScanLogFieldState extends State<ScanLogField> {
  void _hideKeyboard() {
    SystemChannels.textInput.invokeMethod<void>('TextInput.hide');
  }

  @override
  void initState() {
    super.initState();
    widget.focusNode.addListener(_hideKeyboardOnFocus);
  }

  @override
  void didUpdateWidget(covariant ScanLogField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.focusNode != widget.focusNode) {
      oldWidget.focusNode.removeListener(_hideKeyboardOnFocus);
      widget.focusNode.addListener(_hideKeyboardOnFocus);
    }
  }

  @override
  void dispose() {
    widget.focusNode.removeListener(_hideKeyboardOnFocus);
    super.dispose();
  }

  void _hideKeyboardOnFocus() {
    if (!widget.focusNode.hasFocus) return;
    _hideKeyboard();
    Future<void>.delayed(const Duration(milliseconds: 80), _hideKeyboard);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              widget.title,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            TextButton(
              onPressed: widget.enabled ? widget.onClear : null,
              child: const Text('Clear Scan Log'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(8),
          ),
          child: TextFormField(
            controller: widget.controller,
            focusNode: widget.focusNode,
            enabled: widget.enabled,
            keyboardType: TextInputType.text,
            textInputAction: TextInputAction.done,
            autocorrect: false,
            enableSuggestions: false,
            minLines: 2,
            maxLines: 3,
            onTap: _hideKeyboard,
            onChanged: widget.onTextChanged,
            onFieldSubmitted: widget.onSubmitted,
            decoration: const InputDecoration(
              hintText: 'Scan QR/Barcode here',
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            ),
          ),
        ),
      ],
    );
  }
}
