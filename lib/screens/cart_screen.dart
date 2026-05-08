import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../models/cart_item.dart';
import '../state/cart_state.dart';
import '../utils/formatters.dart';
import '../widgets/quantity_stepper.dart';

class CartScreen extends ConsumerWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cart = ref.watch(cartProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Your cart'),
        actions: [
          if (!cart.isEmpty)
            TextButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Clear cart?'),
                    content: const Text('Remove all items from your cart.'),
                    actions: [
                      TextButton(
                          onPressed: () => Navigator.pop(ctx),
                          child: const Text('Cancel')),
                      FilledButton(
                        onPressed: () {
                          ref.read(cartProvider.notifier).clear();
                          Navigator.pop(ctx);
                        },
                        child: const Text('Clear'),
                      ),
                    ],
                  ),
                );
              },
              child: const Text('Clear'),
            ),
        ],
      ),
      body: cart.isEmpty
          ? _EmptyCart(onBrowse: () => context.pop())
          : Column(
              children: [
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: cart.items.length,
                    separatorBuilder: (_, _) =>
                        Divider(height: 1, color: Colors.grey.shade200),
                    itemBuilder: (ctx, i) => _CartLine(line: cart.items[i]),
                  ),
                ),
                _NoteField(
                  initial: cart.note,
                  onChanged: (v) =>
                      ref.read(cartProvider.notifier).setNote(v.isEmpty ? null : v),
                ),
                _SummaryAndCheckout(
                  subtotal: cart.subtotal,
                  itemCount: cart.totalQuantity,
                  onPlaceOrder: () {
                    // Wired in session 3 once OrderApi is integrated.
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Order submission — coming next')),
                    );
                  },
                ),
              ],
            ),
    );
  }
}

class _CartLine extends ConsumerWidget {
  const _CartLine({required this.line});
  final CartItem line;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final ctrl = ref.read(cartProvider.notifier);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(line.item.name, style: theme.textTheme.titleMedium),
                    if (line.selections.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        line.selections.map((s) => s.option.name).join(', '),
                        style: theme.textTheme.bodySmall?.copyWith(color: Colors.black54),
                      ),
                    ],
                    if (line.note != null && line.note!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        'Note: ${line.note}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.black54,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline),
                color: Colors.grey.shade600,
                onPressed: () => ctrl.remove(line.lineId),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              QuantityStepper(
                value: line.quantity,
                onChanged: (v) {
                  if (v > line.quantity) {
                    ctrl.increment(line.lineId);
                  } else {
                    ctrl.decrement(line.lineId);
                  }
                },
              ),
              Text(
                formatPrice(line.lineTotal),
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _NoteField extends StatefulWidget {
  const _NoteField({required this.initial, required this.onChanged});
  final String? initial;
  final ValueChanged<String> onChanged;

  @override
  State<_NoteField> createState() => _NoteFieldState();
}

class _NoteFieldState extends State<_NoteField> {
  late final TextEditingController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.initial ?? '');
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: TextField(
        controller: _ctrl,
        onChanged: widget.onChanged,
        decoration: InputDecoration(
          hintText: 'Note for the kitchen (optional)',
          prefixIcon: const Icon(Icons.edit_note),
          filled: true,
          fillColor: Colors.grey.shade100,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}

class _SummaryAndCheckout extends StatelessWidget {
  const _SummaryAndCheckout({
    required this.subtotal,
    required this.itemCount,
    required this.onPlaceOrder,
  });
  final double subtotal;
  final int itemCount;
  final VoidCallback onPlaceOrder;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8)],
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Subtotal ($itemCount items)', style: theme.textTheme.bodyMedium),
                Text(
                  formatPrice(subtotal),
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: FilledButton(
                onPressed: onPlaceOrder,
                child: const Text('Place order'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyCart extends StatelessWidget {
  const _EmptyCart({required this.onBrowse});
  final VoidCallback onBrowse;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.shopping_bag_outlined, size: 96, color: Colors.grey),
            const SizedBox(height: 16),
            Text('Your cart is empty', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            const Text('Add some items from the menu', style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 24),
            FilledButton(onPressed: onBrowse, child: const Text('Back to menu')),
          ],
        ),
      ),
    );
  }
}
