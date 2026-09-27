import 'package:flutter/material.dart';

import '../core/app_state.dart';
import '../core/theme.dart';
import '../core/theme_state.dart';
import '../data/store_items.dart';
import '../services/user_service.dart';
import '../widgets/glass_card.dart';

class MyPurchasesScreen extends StatefulWidget {
  const MyPurchasesScreen({super.key});

  @override
  State<MyPurchasesScreen> createState() => _MyPurchasesScreenState();
}

class _MyPurchasesScreenState extends State<MyPurchasesScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs = TabController(length: 4, vsync: this);

  bool _loading = true;
  Map<String, dynamic> _inventory = {};

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final inv = await userService.loadInventory();
      if (mounted) setState(() => _inventory = inv);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  List<String> _ownedList(String type) {
    final key = switch (type) {
      'background' => 'backgrounds',
      'voice' => 'voices',
      'adhan' => 'adhans',
      'theme' => 'themes',
      _ => 'backgrounds',
    };
    final list = (_inventory[key] as List?) ?? ['default'];
    return list.map((e) => e.toString()).toList();
  }

  bool _isActive(StoreItem item) {
    final key = switch (item.type) {
      'background' => 'activeBackground',
      'voice' => 'activeVoice',
      'adhan' => 'activeAdhan',
      'theme' => 'activeTheme',
      _ => 'activeBackground',
    };
    return (_inventory[key] as String?) == item.id;
  }

  Future<void> _activate(StoreItem item) async {
    switch (item.type) {
      case 'background':
        await themeState.setBackground(item.id);
        break;
      case 'voice':
        await themeState.setReciter(item.id);
        break;
      case 'adhan':
        await themeState.setAdhan(item.id);
        break;
      case 'theme':
        await themeState.setTheme(item.id);
        break;
    }
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.deepGreen, Color(0xFF0A1F17)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(8, 8, 20, 0),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.of(context).maybePop(),
                      color: AppColors.softGold,
                      icon: const Icon(Icons.arrow_back_rounded),
                    ),
                    const Spacer(),
                    Text(
                      appState.tr('myPurchases'),
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: AppColors.softGold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              TabBar(
                controller: _tabs,
                isScrollable: true,
                tabAlignment: TabAlignment.center,
                indicatorColor: AppColors.gold,
                labelColor: AppColors.gold,
                unselectedLabelColor: AppColors.cream.withValues(alpha: 0.6),
                indicatorWeight: 3,
                labelStyle: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
                tabs: [
                  Tab(text: appState.tr('tabBackgrounds')),
                  Tab(text: appState.tr('tabVoices')),
                  Tab(text: appState.tr('tabAdhans')),
                  Tab(text: appState.tr('tabThemes')),
                ],
              ),
              Expanded(
                child: _loading
                    ? const Center(
                        child:
                            CircularProgressIndicator(color: AppColors.gold))
                    : TabBarView(
                        controller: _tabs,
                        children: [
                          _buildGrid('background'),
                          _buildGrid('voice'),
                          _buildGrid('adhan'),
                          _buildGrid('theme'),
                        ],
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGrid(String type) {
    final owned = _ownedList(type);
    final items = <StoreItem>[];
    for (final id in owned) {
      final item = findItem(type, id);
      if (item != null) items.add(item);
    }

    if (items.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.shopping_bag_outlined,
                  color: AppColors.gold.withValues(alpha: 0.6), size: 60),
              const SizedBox(height: 16),
              Text(
                appState.tr('noPurchases'),
                style: TextStyle(
                  color: AppColors.cream.withValues(alpha: 0.7),
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.82,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: items.length,
      itemBuilder: (context, i) => _PurchaseTile(
        item: items[i],
        active: _isActive(items[i]),
        nameAr: appState.isArabic,
        onTap: _isActive(items[i]) ? null : () => _activate(items[i]),
      ),
    );
  }
}

class _PurchaseTile extends StatelessWidget {
  const _PurchaseTile({
    required this.item,
    required this.active,
    required this.nameAr,
    required this.onTap,
  });

  final StoreItem item;
  final bool active;
  final bool nameAr;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: item.gradient,
          ),
          border: Border.all(
            color: active
                ? AppColors.gold
                : AppColors.gold.withValues(alpha: 0.3),
            width: active ? 2.5 : 1.2,
          ),
          boxShadow: active
              ? [
                  BoxShadow(
                    color: AppColors.gold.withValues(alpha: 0.5),
                    blurRadius: 16,
                    spreadRadius: 1,
                  )
                ]
              : null,
        ),
        child: Stack(
          children: [
            if (active)
              const Positioned(
                top: 8,
                right: 8,
                child: Icon(Icons.check_circle_rounded,
                    color: AppColors.gold, size: 22),
              ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(),
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.black.withValues(alpha: 0.35),
                      border: Border.all(
                        color: AppColors.gold.withValues(alpha: 0.6),
                      ),
                    ),
                    child: Icon(item.icon, color: AppColors.gold, size: 30),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    nameAr ? item.nameAr : item.nameEn,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.cream,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      height: 1.3,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    appState.tr(active ? 'active' : 'tapToActivate'),
                    style: TextStyle(
                      color: active
                          ? AppColors.gold
                          : AppColors.cream.withValues(alpha: 0.6),
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
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
