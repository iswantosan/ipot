import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/services.dart' show rootBundle;

import '../models/menu.dart';
import 'api_client.dart';
import 'menu_cache.dart';

abstract class MenuApi {
  Future<Menu> fetchMenu(String tableId);
}

class HttpMenuApi implements MenuApi {
  HttpMenuApi(this._client, {MenuCache? cache}) : _cache = cache;

  final ApiClient _client;
  final MenuCache? _cache;

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
      // Persist the raw response so we can serve it offline next time.
      _cache?.save(tableId, jsonEncode(data));
      return Menu.fromJson(data);
    } on DioException catch (e) {
      // On network failure, try to fall back to a cached menu.
      final cached = await _cache?.load(tableId);
      if (cached != null) {
        try {
          return Menu.fromJson(jsonDecode(cached) as Map<String, dynamic>);
        } catch (_) {
          // Corrupt cache — fall through to the original error.
        }
      }
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
      raw = await rootBundle.loadString('assets/mock/menu_T001.json');
    }
    final json = jsonDecode(raw) as Map<String, dynamic>;
    final restaurant = json['restaurant'] as Map<String, dynamic>;
    restaurant['table_id'] = tableId;
    return Menu.fromJson(json);
  }
}
