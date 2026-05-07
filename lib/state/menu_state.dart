import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../api/providers.dart';
import '../models/menu.dart';

final menuProvider = FutureProvider.family<Menu, String>((ref, tableId) async {
  final api = ref.watch(menuApiProvider);
  return api.fetchMenu(tableId);
});
