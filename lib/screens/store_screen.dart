import 'package:flutter/material.dart';
import '../widgets/themed_background.dart';
import '../core/app_state.dart';
import '../core/theme.dart';
import '../core/theme_palette.dart';
import '../core/theme_state.dart';
import '../data/store_items.dart';
import '../services/user_service.dart';
import '../widgets/auth_widgets.dart';
import '../widgets/glass_card.dart';
import '../widgets/theme_preview.dart';
import 'my_purchases_screen.dart';

class StoreScreen extends StatefulWidget {
  const StoreScreen({super.key});

  @override
  State<StoreScreen> createState() => _StoreScreenState();
}

class _StoreScreenState extends State<StoreScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs = TabController(length: 4, vsync: this);

  bool _loading = true;
  int _points = 0;
  Map<String, dynamic> _inventory = {};
  String? _busyId;

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
      await userService.migrateInventory();
      final stats = await userService.loadStats();
      final inv = await userService.loadInventory();
      if (mounted) {
        setState(() {
          _points = (stats['points'] as num?)?.toInt() ?? 0;
          _inventory = inv;
        });
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  List<String> _ownedList(String type) {
    final key = _listKey(type);
    final list = (_inventory[key] as List?) ?? ['default'];
    return list.map((e) => e.toString()).toList();
  }

  String _listKey(String type) => switch (type) {
        'background' => 'backgrounds',
        'voice' => 'voices',
        'adhan' => 'adhans',
        'theme' => 'themes',
        _ => 'backgrounds',
      };

  String _activeKey(String type) => switch (type) {
        'background' => 'activeBackground',
        'voice' => 'activeVoice',
        'adhan' => 'activeAdhan',
        'theme' => 'activeTheme',
        _ => 'activeBackground',
      };

  bool _isOwned(StoreItem item) =>
      item.price == 0 || _ownedList(item.type).contains(item.id);

  bool _isActive(StoreItem item) =>
      (_inventory[_activeKey(item.type)] as String?) == item.id;

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
  }

  Future<void> _onItemTap(StoreItem item) async {
    if (_busyId != null) return;

    if (_isOwned(item)) {
      if (_isActive(item)) return;
      setState(() => _busyId = item.id);
      try {
        await _activate(item);
        await _load();
        if (mounted) {
          showAuthMessage(context, appState.tr('itemActivated'));
        }
      } finally {
        if (mounted) setState(() => _busyId = null);
      }
      return;
    }

    if (_points < item.price) {
      showAuthMessage(context, appState.tr('notEnoughPoints'), error: true);
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.deepGreen,
        title: Text(
          appState.tr('confirmPurchase'),
          style: const TextStyle(color: AppColors.softGold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    appState.isArabic ? item.nameAr : item.nameEn,
                    style: const TextStyle(
                      color: AppColors.gold,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                if (item.isVip) const _VipBadge(),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              '${appState.tr('price')}: ${item.price} ${appState.tr('points')}',
              style: const TextStyle(color: AppColors.cream),
            ),
            const SizedBox(height: 6),
            Text(
              '${appState.tr('yourBalance')}: $_points',
              style: TextStyle(
                color: AppColors.cream.withValues(alpha: 0.75),
                fontSize: 13,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(appState.tr('cancel'),
                style: const TextStyle(color: AppColors.softGold)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(appState.tr('buy'),
                style: const TextStyle(color: AppColors.gold)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _busyId = item.id);
    try {
      await userService.addPoints(-item.price);
      await userService.unlockItem(_listKey(item.type), item.id);
      await _activate(item);
      await _load();
      if (mounted) {
        showAuthMessage(context, appState.tr('purchaseSuccess'));
      }
    } finally {
      if (mounted) setState(() => _busyId = null);
    }
  }

  Future<void> _openMyPurchases() async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const MyPurchasesScreen()),
    );
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold
      body: ThemedBackground(
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
                      appState.tr('store'),
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: AppColors.softGold,
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      tooltip: appState.tr('myPurchases'),
                      onPressed: _openMyPurchases,
                      color: AppColors.softGold,
                      icon: const Icon(Icons.shopping_bag_rounded),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: GlassCard(
                  child: Row(
                    children: [
                      const Icon(Icons.stars_rounded,
                          color: AppColors.gold, size: 26),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          appState.tr('yourBalance'),
                          style: const TextStyle(
                            color: AppColors.cream,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      Text(
                        '$_points',
                        style: const TextStyle(
                          color: AppColors.gold,
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TabBar(
                controller: _tabs,
                isScrollable: true,
                tabAlignment: TabAlignment.center,
                indicatorColor: AppColors.gold,
                labelColor: AppColors.gold,
                unselectedLabelColor:
                    AppColors.cream.withValues(alpha: 0.6),
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
                        child: CircularProgressIndicator(
                            color: AppColors.gold))
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
    final items = itemsOfType(type);
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.78,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: items.length,
      itemBuilder: (context, i) => _StoreTile(
        item: items[i],
        owned: _isOwned(items[i]),
        active: _isActive(items[i]),
        busy: _busyId == items[i].id,
        nameAr: appState.isArabic,
        onTap: () => _onItemTap(items[i]),
      ),
    );
  }
}

class _StoreTile extends StatelessWidget {
  const _StoreTile({
    required this.item,
    required this.owned,
    required this.active,
    required this.busy,
    required this.nameAr,
    required this.onTap,
  });

  final StoreItem item;
  final bool owned;
  final bool active;
  final bool busy;
  final bool nameAr;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: busy ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: active
                ? AppColors.gold
                : (item.isVip
                    ? const Color(0xFFFFD700)
                    : AppColors.gold.withValues(alpha: 0.3)),
            width: active ? 2.5 : (item.isVip ? 1.8 : 1.2),
          ),
          boxShadow: active
              ? [
                  BoxShadow(
                    color: AppColors.gold.withValues(alpha: 0.5),
                    blurRadius: 16,
                    spreadRadius: 1,
                  )
                ]
              : (item.isVip
                  ? [
                      BoxShadow(
                        color: const Color(0xFFFFD700)
                            .withValues(alpha: 0.25),
                        blurRadius: 12,
                      )
                    ]
                  : null),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(17),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // الخلفية: معاينة ثيم أو صورة أو gradient
              if (item.type == 'theme')
                ThemePreview(palette: paletteFor(item.id))
              else if (item.imagePath != null)
                Image.asset(
                  item.imagePath!,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => _gradientBg(),
                )
              else
                _gradientBg(),

              // تعتيم لتحسين وضوح النص (فقط للصور)
              if (item.type != 'theme')
                DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withValues(alpha: 0.1),
                        Colors.black.withValues(alpha: 0.75),
                      ],
                    ),
                  ),
                ),

              // شارات VIP
              if (item.isVip)
                const Positioned(
                  top: 8,
                  left: 8,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _VipBadge(),
                      SizedBox(height: 4),
                      _AnimatedBadge(),
                    ],
                  ),
                ),

              if (active)
                const Positioned(
                  top: 8,
                  right: 8,
                  child: Icon(Icons.check_circle_rounded,
                      color: AppColors.gold, size: 22),
                ),

              Positioned(
                top: item.isVip ? null : 8,
                bottom: 8,
                right: 8,
                child: _buildBadge(),
              ),

              Positioned(
                left: 10,
                right: 10,
                bottom: 40,
                child: Column(
                  children: [
                    Icon(item.icon, color: AppColors.gold, size: 26),
                    const SizedBox(height: 6),
                    Text(
                      nameAr ? item.nameAr : item.nameEn,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        height: 1.3,
                        shadows: [
                          Shadow(color: Colors.black87, blurRadius: 6),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _gradientBg() => DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: item.gradient,
          ),
        ),
      );

  Widget _buildBadge() {
    if (busy) {
      return Container(
        padding: const EdgeInsets.all(6),
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.black54,
        ),
        child: const SizedBox(
          width: 16,
          height: 16,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: AppColors.gold,
          ),
        ),
      );
    }
    if (active) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: AppColors.gold,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          appState.tr('active'),
          style: const TextStyle(
            color: AppColors.deepGreen,
            fontWeight: FontWeight.w700,
            fontSize: 11,
          ),
        ),
      );
    }
    if (owned) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(10),
          border:
              Border.all(color: AppColors.gold.withValues(alpha: 0.6)),
        ),
        child: Text(
          appState.tr('tapToActivate'),
          style: const TextStyle(
            color: AppColors.gold,
            fontSize: 10,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.gold),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.stars_rounded,
              color: AppColors.gold, size: 12),
          const SizedBox(width: 3),
          Text(
            '${item.price}',
            style: const TextStyle(
              color: AppColors.gold,
              fontWeight: FontWeight.w700,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}

class _VipBadge extends StatelessWidget {
  const _VipBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFFD700), Color(0xFFFFA000)],
        ),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFFD700).withValues(alpha: 0.6),
            blurRadius: 8,
          ),
        ],
      ),
      child: const Text(
        'VIP',
        style: TextStyle(
          color: Color(0xFF2A1500),
          fontSize: 10,
          fontWeight: FontWeight.w900,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

class _AnimatedBadge extends StatelessWidget {
  const _AnimatedBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: const Color(0xFFFFD700),
          width: 1,
        ),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.auto_awesome_rounded,
              color: Color(0xFFFFD700), size: 10),
          SizedBox(width: 3),
          Text(
            'ANIMATION',
            style: TextStyle(
              color: Color(0xFFFFD700),
              fontSize: 8,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}
