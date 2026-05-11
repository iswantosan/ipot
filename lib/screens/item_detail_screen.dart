import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../l10n/generated/app_localizations.dart';
import '../models/cart_item.dart';
import '../models/customization.dart';
import '../models/menu_item.dart';
import '../state/cart_state.dart';
import '../utils/formatters.dart';
import '../widgets/quantity_stepper.dart';

class ItemDetailScreen extends ConsumerStatefulWidget {
  const ItemDetailScreen({super.key, required this.item});

  final MenuItem item;

  @override
  ConsumerState<ItemDetailScreen> createState() => _ItemDetailScreenState();
}

class _ItemDetailScreenState extends ConsumerState<ItemDetailScreen> {
  late final Map<int, List<int>> _selected; // groupId -> list of option ids
  int _quantity = 1;
  final _noteCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _selected = {
      for (final g in widget.item.customizationGroups) g.id: <int>[],
    };
    // Auto-pick the first option for required single-select groups so the
    // user starts in a valid state.
    for (final g in widget.item.customizationGroups) {
      if (g.required && g.maxSelections == 1 && g.options.isNotEmpty) {
        _selected[g.id] = [g.options.first.id];
      }
    }
  }

  @override
  void dispose() {
    _noteCtrl.dispose();
    super.dispose();
  }

  bool get _isValid {
    for (final g in widget.item.customizationGroups) {
      if (g.required && (_selected[g.id]?.isEmpty ?? true)) return false;
    }
    return true;
  }

  List<SelectedOption> _flattenSelections() {
    final out = <SelectedOption>[];
    for (final g in widget.item.customizationGroups) {
      final ids = _selected[g.id] ?? const [];
      for (final id in ids) {
        final opt = g.options.firstWhere((o) => o.id == id);
        out.add(SelectedOption(option: opt));
      }
    }
    return out;
  }

  double get _unitPrice {
    final selections = _flattenSelections();
    return widget.item.price +
        selections.fold(0.0, (sum, s) => sum + s.totalModifier);
  }

  void _toggle(CustomizationGroup g, int optId) {
    setState(() {
      final list = <int>[...?_selected[g.id]];
      if (g.maxSelections == 1) {
        // single-select: replace
        if (g.required) {
          _selected[g.id] = [optId];
        } else {
          if (list.contains(optId)) {
            _selected[g.id] = [];
          } else {
            _selected[g.id] = [optId];
          }
        }
      } else {
        // multi-select: toggle, respect max
        if (list.contains(optId)) {
          list.remove(optId);
        } else {
          if (list.length >= g.maxSelections) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Max ${g.maxSelections} for ${g.name}')),
            );
            return;
          }
          list.add(optId);
        }
        _selected[g.id] = list;
      }
    });
  }

  void _addToCart() {
    final l = AppLocalizations.of(context)!;
    if (!_isValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l.itemPickRequired)),
      );
      return;
    }
    ref.read(cartProvider.notifier).addItem(
          item: widget.item,
          quantity: _quantity,
          selections: _flattenSelections(),
          note: _noteCtrl.text.trim().isEmpty ? null : _noteCtrl.text.trim(),
        );
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Added $_quantity × ${widget.item.name}'),
          duration: const Duration(seconds: 2),
        ),
      );
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    final theme = Theme.of(context);
    final l = AppLocalizations.of(context)!;
    final lineTotal = _unitPrice * _quantity;

    return Scaffold(
      appBar: AppBar(title: Text(item.name)),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 100),
        children: [
          if (item.imageUrl != null)
            AspectRatio(
              aspectRatio: 16 / 9,
              child: Image.network(item.imageUrl!, fit: BoxFit.cover),
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.name, style: theme.textTheme.headlineSmall),
                const SizedBox(height: 4),
                Text(
                  formatPrice(item.price),
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (item.description.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(item.description, style: theme.textTheme.bodyMedium),
                ],
              ],
            ),
          ),
          for (final group in item.customizationGroups) _GroupSection(
            group: group,
            selected: _selected[group.id] ?? const [],
            onToggle: (optId) => _toggle(group, optId),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l.itemNotes, style: theme.textTheme.titleMedium),
                const SizedBox(height: 8),
                TextField(
                  controller: _noteCtrl,
                  decoration: InputDecoration(
                    hintText: l.itemNotesHint,
                    filled: true,
                    fillColor: Colors.grey.shade100,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  maxLines: 2,
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(l.itemQuantity, style: theme.textTheme.titleMedium),
                QuantityStepper(
                  value: _quantity,
                  onChanged: (v) => setState(() => _quantity = v),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: SizedBox(
            height: 52.h,
            child: FilledButton(
              onPressed: _isValid ? _addToCart : null,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(l.actionAddToCart),
                  const SizedBox(width: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      formatPrice(lineTotal),
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _GroupSection extends StatelessWidget {
  const _GroupSection({
    required this.group,
    required this.selected,
    required this.onToggle,
  });

  final CustomizationGroup group;
  final List<int> selected;
  final ValueChanged<int> onToggle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l = AppLocalizations.of(context)!;
    final isMulti = group.maxSelections > 1;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(group.name, style: theme.textTheme.titleMedium),
              const SizedBox(width: 8),
              if (group.required)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    l.itemRequired,
                    style: TextStyle(
                      color: theme.colorScheme.primary,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              const Spacer(),
              if (isMulti)
                Text(
                  l.itemMaxSelections(group.maxSelections),
                  style: theme.textTheme.bodySmall?.copyWith(color: Colors.black54),
                ),
            ],
          ),
          const SizedBox(height: 4),
          for (final opt in group.options)
            _OptionTile(
              label: opt.name,
              priceModifier: opt.priceModifier,
              selected: selected.contains(opt.id),
              isMulti: isMulti,
              onTap: () => onToggle(opt.id),
            ),
        ],
      ),
    );
  }
}

class _OptionTile extends StatelessWidget {
  const _OptionTile({
    required this.label,
    required this.priceModifier,
    required this.selected,
    required this.isMulti,
    required this.onTap,
  });

  final String label;
  final double priceModifier;
  final bool selected;
  final bool isMulti;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          children: [
            Icon(
              isMulti
                  ? (selected ? Icons.check_box : Icons.check_box_outline_blank)
                  : (selected ? Icons.radio_button_checked : Icons.radio_button_unchecked),
              color: selected ? Theme.of(context).colorScheme.primary : Colors.grey,
              size: 22,
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(label)),
            if (priceModifier > 0)
              Text(
                '+${formatPrice(priceModifier)}',
                style: const TextStyle(color: Colors.black54),
              ),
          ],
        ),
      ),
    );
  }
}
