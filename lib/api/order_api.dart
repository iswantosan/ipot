import 'dart:math';

import 'package:dio/dio.dart';

import '../models/order.dart';
import 'api_client.dart';

abstract class OrderApi {
  Future<Order> createOrder(OrderRequest req);
  Future<Order> fetchOrder(String orderId);
}

class HttpOrderApi implements OrderApi {
  HttpOrderApi(this._client);
  final ApiClient _client;

  @override
  Future<Order> createOrder(OrderRequest req) async {
    try {
      final res = await _client.raw.post('/api/v1/orders', data: req.toJson());
      return Order.fromJson(res.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  @override
  Future<Order> fetchOrder(String orderId) async {
    try {
      final res = await _client.raw.get('/api/v1/orders/$orderId');
      return Order.fromJson(res.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }
}

/// In-memory mock that progresses an order's status over time.
class MockOrderApi implements OrderApi {
  final Map<String, _MockOrderState> _store = {};
  final _rand = Random();

  @override
  Future<Order> createOrder(OrderRequest req) async {
    await Future<void>.delayed(const Duration(milliseconds: 500));
    final id = 'ORD-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';
    final state = _MockOrderState(
      id: id,
      tableId: req.tableId,
      createdAt: DateTime.now(),
      estimatedMinutes: 8 + _rand.nextInt(8),
    );
    _store[id] = state;
    return state.toOrder();
  }

  @override
  Future<Order> fetchOrder(String orderId) async {
    await Future<void>.delayed(const Duration(milliseconds: 250));
    final s = _store[orderId];
    if (s == null) {
      throw ApiException('Order not found', statusCode: 404);
    }
    s.tick();
    return s.toOrder();
  }
}

class _MockOrderState {
  _MockOrderState({
    required this.id,
    required this.tableId,
    required this.createdAt,
    required this.estimatedMinutes,
  });

  final String id;
  final String tableId;
  final DateTime createdAt;
  final int estimatedMinutes;
  OrderStatus status = OrderStatus.pending;

  // Roughly: pending -> confirmed -> preparing -> ready -> served
  static const _flow = [
    OrderStatus.pending,
    OrderStatus.confirmed,
    OrderStatus.preparing,
    OrderStatus.ready,
    OrderStatus.served,
  ];

  void tick() {
    final elapsed = DateTime.now().difference(createdAt).inSeconds;
    // Move forward every ~6s for demo purposes
    final step = (elapsed / 6).floor().clamp(0, _flow.length - 1);
    status = _flow[step];
  }

  Order toOrder() => Order(
        id: id,
        status: status,
        tableId: tableId,
        estimatedMinutes: estimatedMinutes,
        createdAt: createdAt,
      );
}
