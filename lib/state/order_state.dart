import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../api/providers.dart';
import '../models/order.dart';

/// Polls order status every few seconds. The stream emits whenever the API
/// returns a (potentially updated) order.
final orderTrackingProvider =
    StreamProvider.family.autoDispose<Order, String>((ref, orderId) async* {
  final api = ref.watch(orderApiProvider);
  while (true) {
    try {
      final order = await api.fetchOrder(orderId);
      yield order;
      if (order.status == OrderStatus.served) return;
    } catch (_) {
      // surface errors to UI on next pump; keep polling
    }
    await Future<void>.delayed(const Duration(seconds: 4));
  }
});
