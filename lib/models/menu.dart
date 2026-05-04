import 'package:equatable/equatable.dart';

import 'category.dart';
import 'menu_item.dart';
import 'restaurant.dart';

class Menu extends Equatable {
  const Menu({
    required this.restaurant,
    required this.categories,
    required this.items,
  });

  final Restaurant restaurant;
  final List<MenuCategory> categories;
  final List<MenuItem> items;

  factory Menu.fromJson(Map<String, dynamic> json) {
    final cats = (json['categories'] as List<dynamic>? ?? const [])
        .map((e) => MenuCategory.fromJson(e as Map<String, dynamic>))
        .toList()
      ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));

    final items = (json['items'] as List<dynamic>? ?? const [])
        .map((e) => MenuItem.fromJson(e as Map<String, dynamic>))
        .toList();

    return Menu(
      restaurant: Restaurant.fromJson(json['restaurant'] as Map<String, dynamic>),
      categories: cats,
      items: items,
    );
  }

  List<MenuItem> itemsForCategory(int categoryId) =>
      items.where((i) => i.categoryId == categoryId).toList();

  @override
  List<Object?> get props => [restaurant, categories, items];
}
