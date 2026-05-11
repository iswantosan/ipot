import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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
        .where((i) =>
            i.name.toLowerCase().contains(q) ||
            i.description.toLowerCase().contains(q))
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
    final theme = Theme.of(context);
    final searching = query.trim().isNotEmpty;

    return DefaultTabController(
      length: menu.categories.length,
      child: Scaffold(
        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              _RestaurantHero(menu: menu),
              SizedBox(height: 12.h),
              _SearchField(
                controller: searchCtrl,
                onChanged: onQueryChanged,
                hint: l.menuSearchHint,
                searching: searching,
                onClear: () {
                  searchCtrl.clear();
                  onQueryChanged('');
                },
              ),
              if (!searching) ...[
                SizedBox(height: 12.h),
                TabBar(
                  isScrollable: true,
                  tabAlignment: TabAlignment.start,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  indicator: BoxDecoration(
                    color: theme.colorScheme.primary,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  indicatorSize: TabBarIndicatorSize.tab,
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.black54,
                  dividerColor: Colors.transparent,
                  splashBorderRadius: BorderRadius.circular(24),
                  labelStyle: const TextStyle(fontWeight: FontWeight.w700),
                  unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500),
                  tabs: [
                    for (final c in menu.categories)
                      Tab(
                        height: 38,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(c.name),
                        ),
                      ),
                  ],
                ),
              ],
              SizedBox(height: 8.h),
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
      ),
    );
  }
}

class _RestaurantHero extends StatelessWidget {
  const _RestaurantHero({required this.menu});
  final Menu menu;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              theme.colorScheme.primary,
              const Color(0xFFB1352C),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: theme.colorScheme.primary.withValues(alpha: 0.25),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
              ),
              child: const Icon(Icons.restaurant_menu_rounded,
                  color: Colors.white, size: 26),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    menu.restaurant.name,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20.sp,
                      fontWeight: FontWeight.w800,
                      height: 1.1,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.22),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          AppLocalizations.of(context)!
                              .menuTable(menu.restaurant.tableId),
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 11.sp,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.4,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(Icons.circle, size: 4, color: Colors.white.withValues(alpha: 0.6)),
                      const SizedBox(width: 8),
                      Text(
                        '${menu.items.length} items',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.85),
                          fontSize: 12.sp,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField({
    required this.controller,
    required this.onChanged,
    required this.hint,
    required this.searching,
    required this.onClear,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final String hint;
  final bool searching;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.black.withValues(alpha: 0.06)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: TextField(
          controller: controller,
          onChanged: onChanged,
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.search_rounded, color: Colors.black45),
            hintText: hint,
            hintStyle: const TextStyle(color: Colors.black38),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
            suffixIcon: searching
                ? IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: onClear,
                  )
                : null,
          ),
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
                SizedBox(height: 160.h),
                Center(
                  child: Column(
                    children: [
                      Icon(Icons.restaurant_outlined,
                          size: 56, color: Colors.grey.shade400),
                      const SizedBox(height: 12),
                      Text(
                        AppLocalizations.of(context)!.menuEmptyCategory,
                        style: const TextStyle(color: Colors.black54),
                      ),
                    ],
                  ),
                ),
              ],
            )
          : ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.only(top: 4, bottom: 12),
              itemCount: items.length,
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
                SizedBox(height: 160.h),
                Center(
                  child: Column(
                    children: [
                      Icon(Icons.search_off_rounded,
                          size: 56, color: Colors.grey.shade400),
                      const SizedBox(height: 12),
                      Text(
                        AppLocalizations.of(context)!.menuNoMatches,
                        style: const TextStyle(color: Colors.black54),
                      ),
                    ],
                  ),
                ),
              ],
            )
          : ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.only(top: 4, bottom: 12),
              itemCount: items.length,
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
