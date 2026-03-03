import 'package:flutter/material.dart';
import 'package:ims_scanner_app/features/coldstorage/shared/domain/models/lookup_option.dart';

class SearchableLookupField extends StatelessWidget {
  const SearchableLookupField({
    super.key,
    required this.label,
    required this.options,
    required this.onSelected,
    this.selected,
    this.emptyDataLabel,
  });

  final String label;
  final List<LookupOption> options;
  final LookupOption? selected;
  final ValueChanged<LookupOption> onSelected;
  final String? emptyDataLabel;

  bool get _enabled => options.isNotEmpty;

  Future<void> _openPicker(BuildContext context) async {
    if (!_enabled) return;
    FocusManager.instance.primaryFocus?.unfocus();
    final picked = await showModalBottomSheet<LookupOption>(
      context: context,
      isScrollControlled: true,
      enableDrag: true,
      showDragHandle: true,
      useSafeArea: true,
      builder: (sheetContext) {
        final bottomInset = MediaQuery.of(sheetContext).viewInsets.bottom;
        return AnimatedPadding(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          padding: EdgeInsets.only(bottom: bottomInset),
          child: _LookupPickerSheet(
            title: label,
            options: options,
            selected: selected,
          ),
        );
      },
    );
    if (picked != null) {
      onSelected(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final hint = _enabled ? 'Select $label' : (emptyDataLabel ?? 'No data available');

    return InkWell(
      onTap: _enabled ? () => _openPicker(context) : null,
      borderRadius: BorderRadius.circular(4),
      child: InputDecorator(
        isEmpty: selected == null,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          border: const OutlineInputBorder(),
          enabled: _enabled,
          suffixIcon: const Icon(Icons.arrow_drop_down),
        ),
        child: selected == null
            ? const SizedBox.shrink()
            : Text(
                selected!.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
      ),
    );
  }
}

class _LookupPickerSheet extends StatefulWidget {
  const _LookupPickerSheet({
    required this.title,
    required this.options,
    this.selected,
  });

  final String title;
  final List<LookupOption> options;
  final LookupOption? selected;

  @override
  State<_LookupPickerSheet> createState() => _LookupPickerSheetState();
}

class _LookupPickerSheetState extends State<_LookupPickerSheet> {
  final TextEditingController _searchCtrl = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = widget.options.where((item) {
      final q = _query.toLowerCase();
      return item.label.toLowerCase().contains(q) || item.value.toLowerCase().contains(q);
    }).toList();

    return SafeArea(
      child: DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.5,
        minChildSize: 0.3,
        maxChildSize: 0.9,
        builder: (context, scrollController) => CustomScrollView(
          controller: scrollController,
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Select ${widget.title}',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close),
                      tooltip: 'Close',
                    ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                child: TextField(
                  controller: _searchCtrl,
                  autofocus: false,
                  decoration: const InputDecoration(
                    hintText: 'Search...',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _query = value;
                    });
                  },
                ),
              ),
            ),
            if (filtered.isEmpty)
              const SliverFillRemaining(
                hasScrollBody: false,
                child: Center(child: Text('No matching result.')),
              )
            else
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final item = filtered[index];
                    final selected = item.value == widget.selected?.value;
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ListTile(
                          title: Text(item.label),
                          subtitle: item.label == item.value ? null : Text(item.value),
                          trailing: selected ? const Icon(Icons.check, size: 18) : null,
                          onTap: () => Navigator.of(context).pop(item),
                        ),
                        if (index < filtered.length - 1) const Divider(height: 1),
                      ],
                    );
                  },
                  childCount: filtered.length,
                ),
              ),
            const SliverToBoxAdapter(child: SizedBox(height: 12)),
          ],
        ),
      ),
    );
  }
}
