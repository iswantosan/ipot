import 'package:go_router/go_router.dart';

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
      // menu, cart, order routes are wired in session 2
    ],
  );
}
