import 'package:flutter/material.dart';
import 'package:ims_scanner_app/common/styles/spacing_styles.dart';
import 'package:ims_scanner_app/common/widget/reusable_appbar/appbar.dart';
import 'package:ims_scanner_app/features/authentication/data/local/network_config_storage.dart';
import 'package:ims_scanner_app/utils/http/http_client.dart';

class UrlScreen extends StatefulWidget {
  const UrlScreen({super.key});

  @override
  State<UrlScreen> createState() => _UrlScreenState();
}

class _UrlScreenState extends State<UrlScreen> {
  final List<_Endpoint> _endpoints = <_Endpoint>[];
  int? _selectedIndex;
  bool _isBootstrapping = true;

  @override
  void initState() {
    super.initState();
    _loadSavedConfig();
  }

  Future<void> _loadSavedConfig() async {
    final savedEndpoints = await NetworkConfigStorage.readEndpoints();
    final selectedUrl = await NetworkConfigStorage.readSelectedUrl();

    final index = selectedUrl == null
      ? -1
      : savedEndpoints.indexWhere((endpoint) => endpoint.url == selectedUrl);

    if (selectedUrl != null && index < 0) {
      await NetworkConfigStorage.clearSelectedUrl();
    }

    if (!mounted) return;

    setState(() {
      _endpoints
        ..clear()
        ..addAll(
          savedEndpoints.map((e) => _Endpoint(title: e.title, url: e.url)),
        );
      _selectedIndex = index >= 0 ? index : null;
      _isBootstrapping = false;
    });

    if (_selectedIndex != null) {
        AppHttpClient.setBaseUrl(_endpoints[_selectedIndex!].url);
    }
  }

  Future<void> _persistConfig() async {
    final endpoints = _endpoints
        .map((endpoint) => NetworkEndpointConfig(title: endpoint.title, url: endpoint.url))
        .toList();
    await NetworkConfigStorage.saveEndpoints(endpoints);

    if (_selectedIndex == null || _selectedIndex! < 0 || _selectedIndex! >= _endpoints.length) {
      await NetworkConfigStorage.clearSelectedUrl();
      AppHttpClient.setBaseUrl('http://10.0.2.2:3000/');  
      return;
    }

    final selectedUrl = _endpoints[_selectedIndex!].url;
    await NetworkConfigStorage.saveSelectedUrl(selectedUrl);
    AppHttpClient.setBaseUrl(selectedUrl);
  }

  bool _isValidHttpUrl(String value) {
    final uri = Uri.tryParse(value.trim());
    if (uri == null) return false;
    if (!(uri.isScheme('http') || uri.isScheme('https'))) return false;
    return uri.host.isNotEmpty;
  }

  Future<void> _openAddEndpointModal() async {
    final titleController = TextEditingController();
    final urlController = TextEditingController();

    // Optional: you can add validation for URL format later
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (ctx) {
        final bottomInset = MediaQuery.of(ctx).viewInsets.bottom;

        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 12,
            bottom: bottomInset + 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                "Add Endpoint",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),

              TextField(
                controller: titleController,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: "Title",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),

              TextField(
                controller: urlController,
                keyboardType: TextInputType.url,
                textInputAction: TextInputAction.done,
                decoration: const InputDecoration(
                  labelText: "Url",
                  hintText: "https://example.com/api",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text("Cancel"),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        final title = titleController.text.trim();
                        final url = urlController.text.trim();

                        if (title.isEmpty || url.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Please fill in Title and Url."),
                            ),
                          );
                          return;
                        }

                        if (!_isValidHttpUrl(url)) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Please enter a valid http/https URL."),
                            ),
                          );
                          return;
                        }

                        setState(() {
                          _endpoints.add(_Endpoint(title: title, url: url));
                          _selectedIndex = _endpoints.length - 1;
                        });

                        await _persistConfig();

                        if (!mounted || !ctx.mounted) return;
                        Navigator.pop(ctx);
                      },
                      child: const Text("Save"),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
  
  Future<void> _openEditEndpointModal(int index) async {
  final current = _endpoints[index];
  final titleController = TextEditingController(text: current.title);
  final urlController = TextEditingController(text: current.url);

  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (ctx) {
      final bottomInset = MediaQuery.of(ctx).viewInsets.bottom;

      return Padding(
        padding: EdgeInsets.only(left: 16, right: 16, top: 12, bottom: bottomInset + 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text("Edit Endpoint", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            TextField(
              controller: titleController,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(labelText: "Title", border: OutlineInputBorder()),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: urlController,
              keyboardType: TextInputType.url,
              textInputAction: TextInputAction.done,
              decoration: const InputDecoration(labelText: "Url", border: OutlineInputBorder()),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text("Cancel"),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      final title = titleController.text.trim();
                      final url = urlController.text.trim();

                      if (title.isEmpty || url.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Please fill in Title and Url.")),
                        );
                        return;
                      }

                      if (!_isValidHttpUrl(url)) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Please enter a valid http/https URL.")),
                        );
                        return;
                      }

                      setState(() {
                        _endpoints[index] = _Endpoint(title: title, url: url);
                      });

                      await _persistConfig(); // if you already added persistence
                      if (!mounted || !ctx.mounted) return;
                      Navigator.pop(ctx);
                    },
                    child: const Text("Update"),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    },
  );
}

  Future<void> _selectEndpoint(int index) async {
    setState(() {
      _selectedIndex = index;
    });
    await _persistConfig();
  }

  
  Future<void> _deleteEndpoint(int index) async {
    if (index < 0 || index >= _endpoints.length) return;

    final deletingSelected = _selectedIndex == index;

    setState(() {
      _endpoints.removeAt(index);

      if (_endpoints.isEmpty) {
        _selectedIndex = null; 
      } else if (deletingSelected) {
        _selectedIndex = 0;  
      } else if (_selectedIndex != null && _selectedIndex! > index) {
        _selectedIndex = _selectedIndex! - 1;
      }
    });  
  
    await _persistConfig();  
    
  }

  Future<void> _confirmDeleteEndpoint(int index) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete endpoint?'),
        content: Text('Remove "${_endpoints[index].title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _deleteEndpoint(index);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppReusableAppBar(
        title: const Text("Network Configuration"),
        showBackArrow: true,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openAddEndpointModal,
        child: const Icon(Icons.add),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: AppSpacingStyle.paddingWithAppBarheight,
          child: _isBootstrapping
              ? const Center(child: CircularProgressIndicator())
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      "Saved Endpoints",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 12),

                    if (_endpoints.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 24),
                        child: Text("No endpoints yet. Tap + to add one."),
                      )
                    else
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _endpoints.length,
                        separatorBuilder: (_, __) => const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final item = _endpoints[index];
                          final selected = _selectedIndex == index;

                          return ListTile(
                            title: Text(item.title),
                            subtitle: Text(item.url),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Checkbox(
                                  value: selected,
                                  onChanged: (v) {
                                    if (v == true) _selectEndpoint(index);
                                  },
                                ),
                                IconButton(
                                  onPressed: () => _confirmDeleteEndpoint(index),
                                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                                  tooltip: 'Delete',
                                ),
                                IconButton(
                                  onPressed: () => _openEditEndpointModal(index),
                                  icon: const Icon(Icons.edit_outlined, color: Colors.blue),
                                  tooltip: 'Edit',
                                ),
                              ],
                            ), 
                            onTap: () => _selectEndpoint(index),
                          );
                        },
                      ),

                    const SizedBox(height: 16),

                    if (_selectedIndex != null)
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Text(
                            "Selected: ${_endpoints[_selectedIndex!].title}\n${_endpoints[_selectedIndex!].url}",
                          ),
                        ),
                      ),
                  ],
                ),
        ),
      ),
    );
  }
}

class _Endpoint {
  final String title;
  final String url;

  _Endpoint({required this.title, required this.url});
}
