import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ims_scanner_app/app.dart';
import 'package:ims_scanner_app/utils/http/http_client.dart';
import 'package:logger/logger.dart';

Future<void> main() async {
  final logger = Logger();
  logger.d("Starting IMS Scanner App");
  WidgetsFlutterBinding.ensureInitialized();
  await AppHttpClient.init();
  runApp(
    const ProviderScope(
      child: App(),
    ),
  );
}