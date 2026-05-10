import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ipot/api/menu_api.dart';
import 'package:ipot/api/providers.dart';
import 'package:ipot/l10n/generated/app_localizations.dart';
import 'package:ipot/models/menu.dart';
import 'package:ipot/screens/menu_screen.dart';
import 'package:ipot/state/cart_state.dart';
import 'package:ipot/state/session_state.dart';

const _menuJson = {
  'restaurant': {'id': 'R001', 'name': 'Test Diner', 'table_id': 'T001'},
  'categories': [
    {'id': 1, 'name': 'Mains', 'sort_order': 1},
    {'id': 2, 'name': 'Drinks', 'sort_order': 2},
  ],
  'items': [
    {
      'id': 10,
      'name': 'Beef Bowl',
      'description': 'Tender beef over rice',
      'price': 8.50,
      'category_id': 1,
      'image_url': null,
      'customization_groups': [],
    },
    {
      'id': 11,
      'name': 'Iced Tea',
      'description': 'Refreshing',
      'price': 2.00,
      'category_id': 2,
      'image_url': null,
      'customization_groups': [],
    },
  ],
};

class _StubMenuApi implements MenuApi {
  @override
  Future<Menu> fetchMenu(String tableId) async => Menu.fromJson(
        Map<String, dynamic>.from(_menuJson),
      );
}

Widget _harness({required ProviderContainer container}) {
  return UncontrolledProviderScope(
    container: container,
    child: MaterialApp(
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en')],
      home: const MenuScreen(),
    ),
  );
}

void main() {
  testWidgets('menu screen renders categories and items', (tester) async {
    final container = ProviderContainer(overrides: [
      menuApiProvider.overrideWithValue(_StubMenuApi()),
      activeTableProvider.overrideWith((ref) => 'T001'),
    ]);
    addTearDown(container.dispose);

    await tester.pumpWidget(_harness(container: container));
    await tester.pumpAndSettle();

    expect(find.text('Test Diner'), findsOneWidget);
    expect(find.text('Mains'), findsOneWidget);
    expect(find.text('Drinks'), findsOneWidget);
    expect(find.text('Beef Bowl'), findsOneWidget);
  });

  testWidgets('cart updates when an item is added through the provider', (tester) async {
    final container = ProviderContainer(overrides: [
      menuApiProvider.overrideWithValue(_StubMenuApi()),
      activeTableProvider.overrideWith((ref) => 'T001'),
    ]);
    addTearDown(container.dispose);

    await tester.pumpWidget(_harness(container: container));
    await tester.pumpAndSettle();

    // CartSummaryBar should be hidden when cart is empty.
    expect(find.text('View cart'), findsNothing);

    // Use the menu we loaded to add an item.
    final menu = await container.read(menuApiProvider).fetchMenu('T001');
    final bowl = menu.items.firstWhere((i) => i.id == 10);
    container.read(cartProvider.notifier).addItem(item: bowl, quantity: 2);

    await tester.pump();

    // Now the bar should be visible with the right totals.
    expect(find.text('View cart'), findsOneWidget);
    expect(find.text(r'$17.00'), findsOneWidget); // 8.50 x 2
    expect(find.text('2'), findsOneWidget); // badge count
  });

  testWidgets('search filters across categories', (tester) async {
    final container = ProviderContainer(overrides: [
      menuApiProvider.overrideWithValue(_StubMenuApi()),
      activeTableProvider.overrideWith((ref) => 'T001'),
    ]);
    addTearDown(container.dispose);

    await tester.pumpWidget(_harness(container: container));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).first, 'iced');
    await tester.pump();

    expect(find.text('Iced Tea'), findsOneWidget);
    expect(find.text('Beef Bowl'), findsNothing);
  });
}
