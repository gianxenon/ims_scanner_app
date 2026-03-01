import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ims_scanner_app/features/authentication/data/local/network_config_storage.dart';
import 'package:ims_scanner_app/features/authentication/presentation/providers/auth_controller.dart';
import 'package:ims_scanner_app/routers/app_router.dart';
import 'package:ims_scanner_app/utils/http/http_client.dart';
import 'package:ims_scanner_app/utils/theme/theme.dart';

class App extends ConsumerStatefulWidget {
  const App({super.key});

  @override
  ConsumerState<App> createState() => _AppState();
}

class _AppState extends ConsumerState<App> {
  @override
  void initState() {
    super.initState();
    Future<void>.microtask(() async {
      final selectedUrl = await NetworkConfigStorage.readSelectedUrl();
      if (selectedUrl != null && selectedUrl.isNotEmpty) {
        AppHttpClient.setBaseUrl(selectedUrl);
      }
      await ref.read(authControllerProvider.notifier).restoreSession();
    });
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(appRouterProvider);
    return MaterialApp.router(
      routerConfig: router,
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.system,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme, 
    );
  }
}
