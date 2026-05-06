import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/services.dart' show rootBundle;

import '../models/menu.dart';
import 'api_client.dart';

abstract class MenuApi {
  Future<Menu> fetchMenu(String tableId);
}

class HttpMenuApi implements MenuApi {
  HttpMenuApi(this._client);
  final ApiClient _client;

  @override
  Future<Menu> fetchMenu(String tableId) async {
    try {
      final res = await _client.raw.get(
        '/api/v1/menu',
        queryParameters: {'table_id': tableId},
      );
      final data = res.data;
      if (data is! Map<String, dynamic>) {
        throw ApiException('Unexpected menu payload');
      }
      return Menu.fromJson(data);
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }
}

class MockMenuApi implements MenuApi {
  @override
  Future<Menu> fetchMenu(String tableId) async {
    await Future<void>.delayed(const Duration(milliseconds: 350));
    final asset = 'assets/mock/menu_${tableId.toUpperCase()}.json';
    String raw;
    try {
      raw = await rootBundle.loadString(asset);
    } catch (_) {
      // fallback to T001 if specific table is not bundled
      raw = await rootBundle.loadString('assets/mock/menu_T001.json');
    }
    final json = jsonDecode(raw) as Map<String, dynamic>;
    // Override table id so the rest of the app sees the scanned one
    final restaurant = json['restaurant'] as Map<String, dynamic>;
    restaurant['table_id'] = tableId;
    return Menu.fromJson(json);
  }
}
