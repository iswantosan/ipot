import 'package:flutter_test/flutter_test.dart';
import 'package:ipot/models/cart_item.dart';
import 'package:ipot/models/customization.dart';
import 'package:ipot/models/menu_item.dart';

void main() {
  group('SelectedOption', () {
    test('totalModifier multiplies price by quantity', () {
      const opt = CustomizationOption(id: 1, name: 'Extra Egg', priceModifier: 2.0);
      expect(const SelectedOption(option: opt, quantity: 1).totalModifier, 2.0);
      expect(const SelectedOption(option: opt, quantity: 3).totalModifier, 6.0);
    });
  });

  group('MenuItem', () {
    test('hasRequiredGroups detects at least one required group', () {
      const required = CustomizationGroup(
        id: 1,
        name: 'Size',
        required: true,
        maxSelections: 1,
        options: [],
      );
      const optional = CustomizationGroup(
        id: 2,
        name: 'Toppings',
        required: false,
        maxSelections: 3,
        options: [],
      );
      const itemA = MenuItem(
        id: 1,
        name: 'A',
        description: '',
        price: 1,
        categoryId: 1,
        customizationGroups: [required, optional],
      );
      const itemB = MenuItem(
        id: 2,
        name: 'B',
        description: '',
        price: 1,
        categoryId: 1,
        customizationGroups: [optional],
      );
      expect(itemA.hasRequiredGroups, isTrue);
      expect(itemB.hasRequiredGroups, isFalse);
    });
  });

  group('CartItem.lineTotal', () {
    test('combines item price with selection modifiers and quantity', () {
      const item = MenuItem(
        id: 4,
        name: 'Ramen',
        description: '',
        price: 14.99,
        categoryId: 2,
      );
      const extraEgg = CustomizationOption(id: 10, name: 'Extra Egg', priceModifier: 2.0);
      const extraChashu = CustomizationOption(id: 11, name: 'Extra Chashu', priceModifier: 4.0);

      final line = CartItem(
        lineId: '4:10x1,11x1',
        item: item,
        quantity: 2,
        selections: const [
          SelectedOption(option: extraEgg),
          SelectedOption(option: extraChashu),
        ],
      );
      // (14.99 + 2 + 4) * 2 = 41.98
      expect(line.lineTotal, closeTo(41.98, 0.001));
    });
  });
}
