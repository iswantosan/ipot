import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../l10n/generated/app_localizations.dart';
import '../models/order.dart';
import '../navigation/routes.dart';
import '../state/order_state.dart';

class OrderStatusScreen extends ConsumerWidget {
  const OrderStatusScreen({super.key, required this.orderId});

  final String orderId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context)!;
    final orderAsync = ref.watch(orderTrackingProvider(orderId));

    return Scaffold(
      appBar: AppBar(
        title: Text(l.orderTrackTitle),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.go(AppRoutes.scan),
        ),
      ),
      body: orderAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('$err')),
        data: (order) => _StatusView(order: order),
      ),
    );
  }
}

class _StatusView extends StatelessWidget {
  const _StatusView({required this.order});
  final Order order;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    final steps = const [
      OrderStatus.pending,
      OrderStatus.confirmed,
      OrderStatus.preparing,
      OrderStatus.ready,
      OrderStatus.served,
    ];
    final currentIdx = steps.indexOf(order.status);

    String label(OrderStatus s) {
      switch (s) {
        case OrderStatus.pending:
          return l.orderStatusPending;
        case OrderStatus.confirmed:
          return l.orderStatusConfirmed;
        case OrderStatus.preparing:
          return l.orderStatusPreparing;
        case OrderStatus.ready:
          return l.orderStatusReady;
        case OrderStatus.served:
          return l.orderStatusServed;
        case OrderStatus.unknown:
          return '—';
      }
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.receipt_long, color: theme.colorScheme.primary),
                    const SizedBox(width: 8),
                    Text(
                      l.orderConfirmedSubtitle(order.id),
                      style: theme.textTheme.titleMedium,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(label(order.status), style: theme.textTheme.headlineSmall),
                if (order.estimatedMinutes != null &&
                    order.status != OrderStatus.served) ...[
                  const SizedBox(height: 4),
                  Text(
                    l.orderEta(order.estimatedMinutes!),
                    style: theme.textTheme.bodyMedium,
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 24),
          for (var i = 0; i < steps.length; i++)
            _StepRow(
              label: label(steps[i]),
              done: i < currentIdx,
              active: i == currentIdx,
              isLast: i == steps.length - 1,
            ),
          const SizedBox(height: 32),
          Center(
            child: TextButton.icon(
              onPressed: () => context.go(AppRoutes.scan),
              icon: const Icon(Icons.qr_code_scanner),
              label: Text(l.orderBackToScan),
            ),
          ),
        ],
      ),
    );
  }
}

class _StepRow extends StatelessWidget {
  const _StepRow({
    required this.label,
    required this.done,
    required this.active,
    required this.isLast,
  });

  final String label;
  final bool done;
  final bool active;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color =
        done || active ? theme.colorScheme.primary : Colors.grey.shade300;
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Column(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                child: done
                    ? const Icon(Icons.check, color: Colors.white, size: 16)
                    : (active
                        ? const Padding(
                            padding: EdgeInsets.all(6),
                            child: CircleAvatar(backgroundColor: Colors.white),
                          )
                        : null),
              ),
              if (!isLast)
                Expanded(child: Container(width: 2, color: color)),
            ],
          ),
          const SizedBox(width: 16),
          Padding(
            padding: const EdgeInsets.only(top: 2, bottom: 16),
            child: Text(
              label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: active ? FontWeight.w700 : FontWeight.w400,
                color: done || active ? Colors.black : Colors.black54,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
