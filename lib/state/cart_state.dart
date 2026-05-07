import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/cart_item.dart';
import '../models/menu_item.dart';

class Cart {
  const Cart({this.tableId, this.items = const [], this.note});

  final String? tableId;
  final List<CartItem> items;
  final String? note;

  int get totalQuantity => items.fold(0, (sum, e) => sum + e.quantity);
  double get subtotal => items.fold(0.0, (sum, e) => sum + e.lineTotal);
  bool get isEmpty => items.isEmpty;

  Cart copyWith({String? tableId, List<CartItem>? items, String? note}) =>
      Cart(
        tableId: tableId ?? this.tableId,
        items: items ?? this.items,
        note: note ?? this.note,
      );
}

class CartController extends StateNotifier<Cart> {
  CartController() : super(const Cart());

  void setTable(String tableId) {
    if (state.tableId == tableId) return;
    // switching tables clears the cart to avoid mixed orders
    state = Cart(tableId: tableId);
  }

  void addItem({
    required MenuItem item,
    int quantity = 1,
    List<SelectedOption> selections = const [],
    String? note,
  }) {
    final lineId = _lineKey(item.id, selections);
    final existing = state.items.indexWhere((e) => e.lineId == lineId);
    final next = [...state.items];
    if (existing >= 0) {
      final cur = next[existing];
      next[existing] = cur.copyWith(quantity: cur.quantity + quantity);
    } else {
      next.add(CartItem(
        lineId: lineId,
        item: item,
        quantity: quantity,
        selections: selections,
        note: note,
      ));
    }
    state = state.copyWith(items: next);
  }

  void increment(String lineId) {
    final next = state.items.map((e) {
      if (e.lineId != lineId) return e;
      return e.copyWith(quantity: e.quantity + 1);
    }).toList();
    state = state.copyWith(items: next);
  }

  void decrement(String lineId) {
    final next = <CartItem>[];
    for (final e in state.items) {
      if (e.lineId != lineId) {
        next.add(e);
        continue;
      }
      if (e.quantity <= 1) continue; // remove
      next.add(e.copyWith(quantity: e.quantity - 1));
    }
    state = state.copyWith(items: next);
  }

  void remove(String lineId) {
    state = state.copyWith(
      items: state.items.where((e) => e.lineId != lineId).toList(),
    );
  }

  void setNote(String? note) {
    state = state.copyWith(note: note);
  }

  void clear() => state = Cart(tableId: state.tableId);

  static String _lineKey(int itemId, List<SelectedOption> selections) {
    if (selections.isEmpty) return '$itemId:plain';
    final sorted = [...selections]..sort((a, b) => a.option.id.compareTo(b.option.id));
    final tail = sorted.map((s) => '${s.option.id}x${s.quantity}').join(',');
    return '$itemId:$tail';
  }
}

final cartProvider = StateNotifierProvider<CartController, Cart>((ref) => CartController());
