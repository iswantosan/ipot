import 'package:equatable/equatable.dart';

import 'customization.dart';

class MenuItem extends Equatable {
  const MenuItem({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.categoryId,
    this.imageUrl,
    this.customizationGroups = const [],
  });

  final int id;
  final String name;
  final String description;
  final double price;
  final int categoryId;
  final String? imageUrl;
  final List<CustomizationGroup> customizationGroups;

  factory MenuItem.fromJson(Map<String, dynamic> json) {
    final priceRaw = json['price'];
    final groups = (json['customization_groups'] as List<dynamic>? ?? const [])
        .map((e) => CustomizationGroup.fromJson(e as Map<String, dynamic>))
        .toList();
    return MenuItem(
      id: json['id'] as int,
      name: json['name'] as String,
      description: (json['description'] as String?) ?? '',
      price: (priceRaw is int) ? priceRaw.toDouble() : (priceRaw as num).toDouble(),
      categoryId: json['category_id'] as int,
      imageUrl: json['image_url'] as String?,
      customizationGroups: groups,
    );
  }

  bool get hasRequiredGroups => customizationGroups.any((g) => g.required);

  @override
  List<Object?> get props => [id, name, description, price, categoryId, imageUrl, customizationGroups];
}
