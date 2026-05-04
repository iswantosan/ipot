import 'package:equatable/equatable.dart';

class MenuCategory extends Equatable {
  const MenuCategory({
    required this.id,
    required this.name,
    required this.sortOrder,
  });

  final int id;
  final String name;
  final int sortOrder;

  factory MenuCategory.fromJson(Map<String, dynamic> json) {
    return MenuCategory(
      id: json['id'] as int,
      name: json['name'] as String,
      sortOrder: json['sort_order'] as int? ?? 0,
    );
  }

  @override
  List<Object?> get props => [id, name, sortOrder];
}
