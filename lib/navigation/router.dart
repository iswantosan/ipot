import 'package:go_router/go_router.dart';

import '../models/menu_item.dart';
import '../screens/cart_screen.dart';
import '../screens/item_detail_screen.dart';
import '../screens/menu_screen.dart';
import '../screens/scan_screen.dart';
import 'routes.dart';

GoRouter buildRouter() {
  return GoRouter(
    initialLocation: AppRoutes.scan,
    routes: [
      GoRoute(
        path: AppRoutes.scan,
        name: 'scan',
        builder: (context, state) => const ScanScreen(),
      ),
      GoRoute(
        path: AppRoutes.menu,
        name: 'menu',
        builder: (context, state) => const MenuScreen(),
      ),
      GoRoute(
        path: AppRoutes.itemDetail,
        name: 'itemDetail',
        builder: (context, state) {
          final item = state.extra as MenuItem;
          return ItemDetailScreen(item: item);
        },
      ),
      GoRoute(
        path: AppRoutes.cart,
        name: 'cart',
        builder: (context, state) => const CartScreen(),
      ),
    ],
  );
}
