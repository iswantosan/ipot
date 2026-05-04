import 'package:equatable/equatable.dart';

class CustomizationOption extends Equatable {
  const CustomizationOption({
    required this.id,
    required this.name,
    required this.priceModifier,
  });

  final int id;
  final String name;
  final double priceModifier;

  factory CustomizationOption.fromJson(Map<String, dynamic> json) {
    final raw = json['price_modifier'];
    return CustomizationOption(
      id: json['id'] as int,
      name: json['name'] as String,
      priceModifier: (raw is int) ? raw.toDouble() : (raw as num).toDouble(),
    );
  }

  @override
  List<Object?> get props => [id, name, priceModifier];
}

class CustomizationGroup extends Equatable {
  const CustomizationGroup({
    required this.id,
    required this.name,
    required this.required,
    required this.maxSelections,
    required this.options,
  });

  final int id;
  final String name;
  final bool required;
  final int maxSelections;
  final List<CustomizationOption> options;

  factory CustomizationGroup.fromJson(Map<String, dynamic> json) {
    final opts = (json['options'] as List<dynamic>? ?? const [])
        .map((e) => CustomizationOption.fromJson(e as Map<String, dynamic>))
        .toList();
    return CustomizationGroup(
      id: json['id'] as int,
      name: json['name'] as String,
      required: json['required'] as bool? ?? false,
      maxSelections: json['max_selections'] as int? ?? 1,
      options: opts,
    );
  }

  @override
  List<Object?> get props => [id, name, required, maxSelections, options];
}
