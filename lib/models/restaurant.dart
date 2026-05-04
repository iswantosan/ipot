import 'package:equatable/equatable.dart';

class Restaurant extends Equatable {
  const Restaurant({
    required this.id,
    required this.name,
    required this.tableId,
  });

  final String id;
  final String name;
  final String tableId;

  factory Restaurant.fromJson(Map<String, dynamic> json) {
    return Restaurant(
      id: json['id'] as String,
      name: json['name'] as String,
      tableId: json['table_id'] as String,
    );
  }

  @override
  List<Object?> get props => [id, name, tableId];
}
