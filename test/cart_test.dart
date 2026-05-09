import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ipot/models/cart_item.dart';
import 'package:ipot/models/customization.dart';
import 'package:ipot/models/menu_item.dart';
import 'package:ipot/state/cart_state.dart';

MenuItem _ramen() => const MenuItem(
      id: 4,
      name: 'Chicken Ramen',
      description: 'Rich chicken broth with chashu, egg, and noodles',
      price: 14.99,
      categoryId: 2,
      customizationGroups: [
        CustomizationGroup(
          id: 3,
          name: 'Spice Level',
          required: true,
          maxSelections: 1,
          options: [
            CustomizationOption(id: 6, name: 'Mild', priceModifier: 0),
            CustomizationOption(id: 9, name: 'Extra Spicy', priceModifier: 1.0),
          ],
        ),
      ],
    );

const _mild = CustomizationOption(id: 6, name: 'Mild', priceModifier: 0);
const _spicy = CustomizationOption(id: 9, name: 'Extra Spicy', priceModifier: 1.0);

void main() {
  late ProviderContainer container;

  setUp(() {
    container = ProviderContainer();
  });
  tearDown(() {
    container.dispose();
  });

  CartController ctrl() => container.read(cartProvider.notifier);
  Cart cart() => container.read(cartProvider);

  group('CartController', () {
    test('addItem creates a new line and computes subtotal', () {
      ctrl().addItem(item: _ramen(), quantity: 2, selections: const [
        SelectedOption(option: _mild),
      ]);
      final c = cart();
      expect(c.items.length, 1);
      expect(c.items.first.quantity, 2);
      expect(c.items.first.unitPrice, 14.99);
      expect(c.subtotal, closeTo(29.98, 0.001));
      expect(c.totalQuantity, 2);
    });

    test('adding the same item with same selections merges into one line', () {
      ctrl().addItem(item: _ramen(), quantity: 1, selections: const [
        SelectedOption(option: _mild),
      ]);
      ctrl().addItem(item: _ramen(), quantity: 2, selections: const [
        SelectedOption(option: _mild),
      ]);
      expect(cart().items.length, 1);
      expect(cart().items.first.quantity, 3);
    });

    test('adding the same item with different selections keeps separate lines', () {
      ctrl().addItem(item: _ramen(), quantity: 1, selections: const [
        SelectedOption(option: _mild),
      ]);
      ctrl().addItem(item: _ramen(), quantity: 1, selections: const [
        SelectedOption(option: _spicy),
      ]);
      expect(cart().items.length, 2);
      // 14.99 (mild) + 14.99 + 1.00 (spicy) = 30.98
      expect(cart().subtotal, closeTo(30.98, 0.001));
    });

    test('decrement removes line at quantity 1', () {
      ctrl().addItem(item: _ramen(), quantity: 1);
      final lineId = cart().items.first.lineId;
      ctrl().decrement(lineId);
      expect(cart().items, isEmpty);
    });

    test('increment / decrement adjusts quantity', () {
      ctrl().addItem(item: _ramen(), quantity: 2);
      final lineId = cart().items.first.lineId;
      ctrl().increment(lineId);
      expect(cart().items.first.quantity, 3);
      ctrl().decrement(lineId);
      expect(cart().items.first.quantity, 2);
    });

    test('setTable to a different table clears the cart', () {
      ctrl().setTable('T001');
      ctrl().addItem(item: _ramen(), quantity: 1);
      expect(cart().items.length, 1);
      ctrl().setTable('T002');
      expect(cart().items, isEmpty);
      expect(cart().tableId, 'T002');
    });
  });
}
