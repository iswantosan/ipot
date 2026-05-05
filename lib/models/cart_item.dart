import 'package:equatable/equatable.dart';

import 'customization.dart';
import 'menu_item.dart';

class SelectedOption extends Equatable {
  const SelectedOption({required this.option, this.quantity = 1});

  final CustomizationOption option;
  final int quantity;

  double get totalModifier => option.priceModifier * quantity;

  Map<String, dynamic> toRequestJson() => {
        'option_id': option.id,
        'quantity': quantity,
      };

  @override
  List<Object?> get props => [option, quantity];
}

class CartItem extends Equatable {
  const CartItem({
    required this.lineId,
    required this.item,
    required this.quantity,
    this.selections = const [],
    this.note,
  });

  final String lineId;
  final MenuItem item;
  final int quantity;
  final List<SelectedOption> selections;
  final String? note;

  double get unitPrice =>
      item.price + selections.fold<double>(0, (sum, s) => sum + s.totalModifier);

  double get lineTotal => unitPrice * quantity;

  CartItem copyWith({int? quantity, List<SelectedOption>? selections, String? note}) {
    return CartItem(
      lineId: lineId,
      item: item,
      quantity: quantity ?? this.quantity,
      selections: selections ?? this.selections,
      note: note ?? this.note,
    );
  }

  @override
  List<Object?> get props => [lineId, item, quantity, selections, note];
}
