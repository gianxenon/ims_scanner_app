import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:path_provider/path_provider.dart';

class AppHttpClient {
  static final Dio dio = Dio(BaseOptions(
    baseUrl: 'http://10.0.2.2:3000/',
    connectTimeout: const Duration(seconds: 20),
    sendTimeout: const Duration(seconds: 20),
    receiveTimeout: const Duration(seconds: 45),
    headers: {'Accept': 'application/json', 'Content-Type': 'application/json'},
  ));

  static bool _initialized = false;

  static Future<void> init() async {
    if (_initialized) return;
    final dir = await getApplicationDocumentsDirectory();
    final jar = PersistCookieJar(storage: FileStorage('${dir.path}/.cookies/'));
    dio.interceptors.add(CookieManager(jar));
    _initialized = true;
  }

  static void setBaseUrl(String baseUrl) {
    final trimmed = baseUrl.trim();
    dio.options.baseUrl = trimmed.endsWith('/') ? trimmed : '$trimmed/';
  }
}
