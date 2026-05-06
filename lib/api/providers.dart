import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'api_client.dart';
import 'menu_api.dart';
import 'order_api.dart';

final apiClientProvider = Provider<ApiClient>((ref) => ApiClient.create());

final menuApiProvider = Provider<MenuApi>((ref) {
  if (ApiClient.useMock) return MockMenuApi();
  return HttpMenuApi(ref.watch(apiClientProvider));
});

final orderApiProvider = Provider<OrderApi>((ref) {
  if (ApiClient.useMock) return MockOrderApi();
  return HttpOrderApi(ref.watch(apiClientProvider));
});
