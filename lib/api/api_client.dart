import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiClient {
  ApiClient._(this._dio);

  final Dio _dio;

  Dio get raw => _dio;

  static ApiClient create() {
    final base = dotenv.maybeGet('API_BASE_URL') ?? 'https://api.ipot.example.com';
    final dio = Dio(BaseOptions(
      baseUrl: base,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 15),
      headers: {'Accept': 'application/json'},
    ));
    return ApiClient._(dio);
  }

  static bool get useMock {
    final flag = dotenv.maybeGet('USE_MOCK')?.toLowerCase();
    return flag == null || flag == 'true' || flag == '1';
  }
}

class ApiException implements Exception {
  ApiException(this.message, {this.statusCode});
  final String message;
  final int? statusCode;

  @override
  String toString() => 'ApiException($statusCode): $message';
}

ApiException mapDioError(DioException e) {
  final code = e.response?.statusCode;
  final body = e.response?.data;
  String msg;
  if (body is Map && body['message'] is String) {
    msg = body['message'] as String;
  } else if (body is Map && body['error'] is String) {
    msg = body['error'] as String;
  } else {
    msg = e.message ?? 'Network error';
  }
  return ApiException(msg, statusCode: code);
}
