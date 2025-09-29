import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:dio_web_adapter/dio_web_adapter.dart';

class ApiClient {
  ApiClient._internal() {
    if (kIsWeb) {
      _dio.httpClientAdapter = BrowserHttpClientAdapter()
        ..withCredentials = true;
    }
  }
  static final ApiClient instance = ApiClient._internal();

  // Configure this to point to your backend base URL.
  String baseUrl = const String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://fish-api-md7q.onrender.com',
  );

  final Dio _dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 20),
    receiveTimeout: const Duration(seconds: 20),
    sendTimeout: const Duration(seconds: 30),
    validateStatus: (s) => s != null && s >= 200 && s < 400,
    headers: {'Accept': 'application/json'},
    // Note: cookie-based auth from the web app may not apply on mobile.
    // If your API requires auth, add a token header here.
  ));

  // Web adapter is configured in the private constructor above

  Future<Map<String, dynamic>> get(String path,
      {Map<String, dynamic>? params}) async {
    final res = await _dio.get('$baseUrl$path', queryParameters: params);
    if (res.data is Map<String, dynamic>)
      return res.data as Map<String, dynamic>;
    // Deprecated: Legacy API client removed.
    // Intentionally empty.
    return {'data': res.data};
  }
}
