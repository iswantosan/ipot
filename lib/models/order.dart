import 'package:equatable/equatable.dart';

enum OrderStatus { pending, confirmed, preparing, ready, served, unknown }

OrderStatus parseOrderStatus(String? raw) {
  switch (raw) {
    case 'pending':
      return OrderStatus.pending;
    case 'confirmed':
      return OrderStatus.confirmed;
    case 'preparing':
      return OrderStatus.preparing;
    case 'ready':
      return OrderStatus.ready;
    case 'served':
      return OrderStatus.served;
    default:
      return OrderStatus.unknown;
  }
}

class OrderItemRequest {
  OrderItemRequest({
    required this.menuItemId,
    required this.quantity,
    this.customizations = const [],
  });

  final int menuItemId;
  final int quantity;
  final List<Map<String, dynamic>> customizations;

  Map<String, dynamic> toJson() => {
        'menu_item_id': menuItemId,
        'quantity': quantity,
        'customizations': customizations,
      };
}

class OrderRequest {
  OrderRequest({
    required this.tableId,
    required this.items,
    this.customerNote,
  });

  final String tableId;
  final List<OrderItemRequest> items;
  final String? customerNote;

  Map<String, dynamic> toJson() => {
        'table_id': tableId,
        'items': items.map((e) => e.toJson()).toList(),
        if (customerNote != null && customerNote!.isNotEmpty)
          'customer_note': customerNote,
      };
}

class Order extends Equatable {
  const Order({
    required this.id,
    required this.status,
    required this.tableId,
    this.estimatedMinutes,
    this.total,
    this.createdAt,
  });

  final String id;
  final OrderStatus status;
  final String tableId;
  final int? estimatedMinutes;
  final double? total;
  final DateTime? createdAt;

  factory Order.fromJson(Map<String, dynamic> json) {
    final totalRaw = json['total'];
    return Order(
      id: json['id'].toString(),
      status: parseOrderStatus(json['status'] as String?),
      tableId: (json['table_id'] ?? '').toString(),
      estimatedMinutes: json['estimated_minutes'] as int?,
      total: totalRaw == null
          ? null
          : (totalRaw is int ? totalRaw.toDouble() : (totalRaw as num).toDouble()),
      createdAt: json['created_at'] == null
          ? null
          : DateTime.tryParse(json['created_at'] as String),
    );
  }

  @override
  List<Object?> get props => [id, status, tableId, estimatedMinutes, total, createdAt];
}
