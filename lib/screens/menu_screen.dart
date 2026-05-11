import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../l10n/generated/app_localizations.dart';
import '../models/menu.dart';
import '../models/menu_item.dart';
import '../navigation/routes.dart';
import '../state/cart_state.dart';
import '../state/menu_state.dart';
import '../state/session_state.dart';
import '../widgets/cart_summary_bar.dart';
import '../widgets/menu_item_card.dart';
import '../widgets/menu_shimmer.dart';

class MenuScreen extends ConsumerStatefulWidget {
  const MenuScreen({super.key});

  @override
  ConsumerState<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends ConsumerState<MenuScreen> {
  final _searchCtrl = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tableId = ref.watch(activeTableProvider);
    if (tableId == null) {
      // No table selected — bounce back to scan.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) context.go(AppRoutes.scan);
      });
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final menuAsync = ref.watch(menuProvider(tableId));
    return menuAsync.when(
      loading: () => const MenuShimmer(),
      error: (err, _) {
        final l = AppLocalizations.of(context)!;
        return Scaffold(
          appBar: AppBar(),
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.redAccent),
                  const SizedBox(height: 16),
                  Text(l.menuFailedLoad, style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  Text('$err', textAlign: TextAlign.center),
                  const SizedBox(height: 24),
                  FilledButton(
                    onPressed: () => ref.invalidate(menuProvider(tableId)),
                    child: Text(l.actionRetry),
                  ),
                ],
              ),
            ),
          ),
        );
      },
      data: (menu) => _MenuView(
        menu: menu,
        query: _query,
        searchCtrl: _searchCtrl,
        onQueryChanged: (q) => setState(() => _query = q),
      ),
    );
  }
}

class _MenuView extends ConsumerWidget {
  const _MenuView({
    required this.menu,
    required this.query,
    required this.searchCtrl,
    required this.onQueryChanged,
  });

  final Menu menu;
  final String query;
  final TextEditingController searchCtrl;
  final ValueChanged<String> onQueryChanged;

  List<MenuItem> _filter(List<MenuItem> items) {
    if (query.trim().isEmpty) return items;
    final q = query.toLowerCase();
    return items
        .where((i) => i.name.toLowerCase().contains(q) || i.description.toLowerCase().contains(q))
        .toList();
  }

  Future<void> _refresh(WidgetRef ref) async {
    ref.invalidate(menuProvider(menu.restaurant.tableId));
    await ref.read(menuProvider(menu.restaurant.tableId).future);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cart = ref.watch(cartProvider);
    final l = AppLocalizations.of(context)!;
    final searching = query.trim().isNotEmpty;

    return DefaultTabController(
      length: menu.categories.length,
      child: Scaffold(
        appBar: AppBar(
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(menu.restaurant.name, style: const TextStyle(fontSize: 18)),
              Text(
                l.menuTable(menu.restaurant.tableId),
                style: const TextStyle(fontSize: 12, color: Colors.black54),
              ),
            ],
          ),
          bottom: searching
              ? null
              : TabBar(
                  isScrollable: true,
                  tabs: [for (final c in menu.categories) Tab(text: c.name)],
                ),
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: TextField(
                controller: searchCtrl,
                onChanged: onQueryChanged,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.search),
                  hintText: l.menuSearchHint,
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  contentPadding: const EdgeInsets.symmetric(vertical: 0),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  suffixIcon: searching
                      ? IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () {
                            searchCtrl.clear();
                            onQueryChanged('');
                          },
                        )
                      : null,
                ),
              ),
            ),
            Expanded(
              child: searching
                  ? _SearchResults(
                      items: _filter(menu.items),
                      onRefresh: () => _refresh(ref),
                    )
                  : TabBarView(
                      children: [
                        for (final c in menu.categories)
                          _CategoryItems(
                            items: menu.itemsForCategory(c.id),
                            onRefresh: () => _refresh(ref),
                          ),
                      ],
                    ),
            ),
            CartSummaryBar(
              itemCount: cart.totalQuantity,
              subtotal: cart.subtotal,
              onTap: () => context.push(AppRoutes.cart),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryItems extends StatelessWidget {
  const _CategoryItems({required this.items, required this.onRefresh});

  final List<MenuItem> items;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: items.isEmpty
          ? ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                SizedBox(height: 200.0),
                Center(child: Text(AppLocalizations.of(context)!.menuEmptyCategory)),
              ],
            )
          : ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: items.length,
              separatorBuilder: (_, _) =>
                  Divider(height: 1, color: Colors.grey.shade200),
              itemBuilder: (ctx, i) {
                final item = items[i];
                return MenuItemCard(
                  item: item,
                  onTap: () => context.push(AppRoutes.itemDetail, extra: item),
                );
              },
            ),
    );
  }
}

class _SearchResults extends StatelessWidget {
  const _SearchResults({required this.items, required this.onRefresh});

  final List<MenuItem> items;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: items.isEmpty
          ? ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                SizedBox(height: 200.0),
                Center(child: Text(AppLocalizations.of(context)!.menuNoMatches)),
              ],
            )
          : ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: items.length,
              separatorBuilder: (_, _) =>
                  Divider(height: 1, color: Colors.grey.shade200),
              itemBuilder: (ctx, i) {
                final item = items[i];
                return MenuItemCard(
                  item: item,
                  onTap: () => context.push(AppRoutes.itemDetail, extra: item),
                );
              },
            ),
    );
  }
}
