import 'dart:ui' as ui;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../core/app_state.dart';
import '../core/responsive.dart';
import '../core/theme.dart';
import '../core/theme_palette.dart';
import '../core/theme_state.dart';
import '../data/store_items.dart';
import '../services/adhan_service.dart';
import '../services/premium_service.dart';
import '../services/user_service.dart';
import '../widgets/auth_widgets.dart';
import '../widgets/glass_card.dart';
import '../widgets/themed_background.dart';
import '../widgets/theme_preview.dart';
import 'my_purchases_screen.dart';
import 'premium_screen.dart';

class StoreScreen extends StatefulWidget {
  const StoreScreen({super.key});

  @override
  State<StoreScreen> createState() => _StoreScreenState();
}

class _StoreScreenState extends State<StoreScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs = TabController(length: 4, vsync: this);

  bool _loading = true;
  bool _isPremium = false;
  int _points = 0;
  Map<String, dynamic> _inventory = {};

  String? _expandedKey;
  String? _playingReciterId;
  String? _busyKey;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _tabs.dispose();
    adhanService.stop();
    super.dispose();
  }

  String _keyOf(StoreItem item) => '${item.type}|${item.id}';

  String _listKey(String type) => switch (type) {
        'background' => 'backgrounds',
        'adhan' => 'adhans',
        'adhanBackground' => 'adhanBackgrounds',
        'theme' => 'themes',
        _ => 'backgrounds',
      };

  String _activeKey(String type) => switch (type) {
        'background' => 'activeBackground',
        'adhan' => 'activeAdhan',
        'adhanBackground' => 'activeAdhanBackground',
        'theme' => 'activeTheme',
        _ => 'activeBackground',
      };

  List<String> _ownedList(String type) {
    final list = (_inventory[_listKey(type)] as List?) ?? ['default'];
    return list.map((e) => e.toString()).toList();
  }

  bool _isOwned(StoreItem item) =>
      item.price == 0 || _ownedList(item.type).contains(item.id);

  bool _isActive(StoreItem item) {
    if (item.type == 'adhanBackground') {
      return themeState.adhanBackgroundId == item.id;
    }
    return (_inventory[_activeKey(item.type)] as String?) == item.id;
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      await userService.migrateInventory();
      final stats = await userService.loadStats();
      final inv = await userService.loadInventory();

      final uid = FirebaseAuth.instance.currentUser?.uid;
      final isPremium = uid == null
          ? false
          : await PremiumService.fetchIsUserPremium(uid);

      if (mounted) {
        setState(() {
          _points = (stats['points'] as num?)?.toInt() ?? 0;
          _inventory = inv;
          _isPremium = isPremium;
        });
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _applyActivation(StoreItem item) async {
    switch (item.type) {
      case 'background':
        await themeState.setBackground(item.id);
        break;
      case 'adhan':
        await themeState.setAdhan(item.id);
        await adhanService.setReciter(item.id);
        break;
      case 'adhanBackground':
        await themeState.setAdhanBackground(item.id);
        break;
      case 'theme':
        await themeState.setTheme(item.id);
        break;
    }
  }

  Future<void> _togglePlay(StoreItem item) async {
    if (_playingReciterId == item.id) {
      await adhanService.stop();
      if (mounted) setState(() => _playingReciterId = null);
      return;
    }

    await adhanService.stop();

    setState(() => _playingReciterId = item.id);
    final ok = await adhanService.play(reciterId: item.id);
    if (!ok && mounted) {
      setState(() => _playingReciterId = null);
    }

    Future.delayed(const Duration(seconds: 30), () {
      if (mounted && _playingReciterId == item.id) {
        adhanService.stop();
        setState(() => _playingReciterId = null);
      }
    });
  }

  Future<void> _purchase(StoreItem item) async {
    if (!_isPremium && _points < item.price) {
      await _showInsufficientPoints();
      return;
    }

    final confirmed = await _showPurchaseDialog(item);
    if (confirmed != true) return;

    setState(() => _busyKey = _keyOf(item));
    try {
      if (!_isPremium) {
        await userService.addPoints(-item.price);
      }
      await userService.unlockItem(_listKey(item.type), item.id);
      await _applyActivation(item);
      await _load();
      if (mounted) {
        showAuthMessage(context, appState.tr('purchaseSuccess'));
        setState(() => _expandedKey = null);
      }
    } catch (e) {
      if (mounted) {
        showAuthMessage(context, 'حدث خطأ: $e', error: true);
      }
    } finally {
      if (mounted) setState(() => _busyKey = null);
    }
  }

  Future<void> _activateOwned(StoreItem item) async {
    if (_isActive(item)) return;
    setState(() => _busyKey = _keyOf(item));
    try {
      await _applyActivation(item);
      await _load();
      if (mounted) {
        showAuthMessage(context, appState.tr('itemActivated'));
        setState(() => _expandedKey = null);
      }
    } finally {
      if (mounted) setState(() => _busyKey = null);
    }
  }

  Future<void> _deactivate(StoreItem item) async {
    final confirmed = await _showDeactivateDialog(item);
    if (confirmed != true) return;

    setState(() => _busyKey = _keyOf(item));
    try {
      final defaultItem = StoreItem(
        id: 'default',
        type: item.type,
        nameAr: 'الافتراضي',
        nameEn: 'Default',
        descAr: '',
        descEn: '',
        price: 0,
        gradient: const [],
        icon: Icons.circle_outlined,
      );
      await _applyActivation(defaultItem);
      await _load();
      if (mounted) {
        showAuthMessage(context, appState.tr('deactivatedToDefault'));
        setState(() => _expandedKey = null);
      }
    } finally {
      if (mounted) setState(() => _busyKey = null);
    }
  }

  void _preview(StoreItem item) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.92),
      builder: (_) => _PreviewDialog(item: item),
    );
  }

  Future<bool?> _showPurchaseDialog(StoreItem item) {
    return showDialog<bool>(
      context: context,
      builder: (_) => _PurchaseDialog(
        item: item,
        isPremium: _isPremium,
        points: _points,
      ),
    );
  }

  Future<bool?> _showDeactivateDialog(StoreItem item) {
    return showDialog<bool>(
      context: context,
      builder: (_) => _DeactivateDialog(item: item),
    );
  }

  Future<void> _showInsufficientPoints() async {
    await showDialog<void>(
      context: context,
      builder: (_) => const _InsufficientPointsDialog(),
    );
  }

  Future<void> _openMyPurchases() async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const MyPurchasesScreen()),
    );
    await _load();
  }

  Future<void> _openPremium() async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const PremiumScreen()),
    );
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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

              if (!_isPremium)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: _PremiumBanner(onTap: _openPremium),
                ),
              if (!_isPremium) const SizedBox(height: 12),

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
                  fontSize: 13,
                ),
                tabs: [
                  Tab(text: appState.tr('tabBackgrounds')),
                  Tab(text: appState.tr('tabAdhans')),
                  Tab(text: appState.tr('tabAdhanBgs')),
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
                          _buildGrid('adhan'),
                          _buildGrid('adhanBackground'),
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
        childAspectRatio: 0.82,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: items.length,
      itemBuilder: (context, i) {
        final item = items[i];
        final key = _keyOf(item);
        return _StoreCard(
          item: item,
          owned: _isOwned(item),
          active: _isActive(item),
          isPremium: _isPremium,
          expanded: _expandedKey == key,
          playing: _playingReciterId == item.id,
          busy: _busyKey == key,
          nameAr: appState.isArabic,
          onCardTap: () {
            setState(() {
              _expandedKey = (_expandedKey == key) ? null : key;
            });
          },
          onPlay: () => _togglePlay(item),
          onPreview: () => _preview(item),
          onPurchase: () => _purchase(item),
          onActivate: () => _activateOwned(item),
          onDeactivate: () => _deactivate(item),
        );
      },
    );
  }
}

class _StoreCard extends StatelessWidget {
  const _StoreCard({
    required this.item,
    required this.owned,
    required this.active,
    required this.isPremium,
    required this.expanded,
    required this.playing,
    required this.busy,
    required this.nameAr,
    required this.onCardTap,
    required this.onPlay,
    required this.onPreview,
    required this.onPurchase,
    required this.onActivate,
    required this.onDeactivate,
  });

  final StoreItem item;
  final bool owned;
  final bool active;
  final bool isPremium;
  final bool expanded;
  final bool playing;
  final bool busy;
  final bool nameAr;
  final VoidCallback onCardTap;
  final VoidCallback onPlay;
  final VoidCallback onPreview;
  final VoidCallback onPurchase;
  final VoidCallback onActivate;
  final VoidCallback onDeactivate;

  bool get _isAdhan => item.type == 'adhan';
  bool get _isBackground =>
      item.type == 'background' ||
      item.type == 'adhanBackground' ||
      item.type == 'theme';

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: busy ? null : onCardTap,
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
              : null,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(17),
          child: Stack(
            fit: StackFit.expand,
            children: [
              _buildBackground(context),

              if (item.type != 'theme')
                DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withValues(alpha: 0.05),
                        Colors.black.withValues(alpha: 0.85),
                      ],
                    ),
                  ),
                ),

              if (item.isVip)
                const Positioned(
                  top: 8,
                  left: 8,
                  child: _VipBadge(),
                ),

              if (active)
                const Positioned(
                  top: 8,
                  right: 8,
                  child: Icon(Icons.check_circle_rounded,
                      color: AppColors.gold, size: 22),
                ),

              if (!expanded)
                _buildCollapsedContent(context)
              else
                _buildExpandedContent(context),

              if (busy)
                Positioned.fill(
                  child: Container(
                    color: Colors.black.withValues(alpha: 0.5),
                    child: const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.gold,
                        strokeWidth: 2.5,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBackground(BuildContext context) {
    if (item.type == 'theme') {
      return ThemePreview(palette: paletteFor(item.id));
    }
    if (item.imagePath != null) {
      return Image.asset(
        item.imagePath!,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => _gradientBg(),
      );
    }
    return _gradientBg();
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

  Widget _buildCollapsedContent(BuildContext context) {
    return Positioned(
      left: 12,
      right: 12,
      bottom: 12,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(item.icon, color: AppColors.gold, size: 28),
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
              shadows: [Shadow(color: Colors.black87, blurRadius: 6)],
            ),
          ),
          const SizedBox(height: 6),
          _priceBadge(),
        ],
      ),
    );
  }

  Widget _buildExpandedContent(BuildContext context) {
    return Positioned.fill(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(17),
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            color: Colors.black.withValues(alpha: 0.55),
            padding: const EdgeInsets.all(10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  nameAr ? item.nameAr : item.nameEn,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: _buildActions(context),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildActions(BuildContext context) {
    if (_isAdhan) {
      final playBtn = _RoundIconButton(
        icon: playing ? Icons.stop_rounded : Icons.play_arrow_rounded,
        color: playing ? const Color(0xFFE53935) : AppColors.gold,
        onTap: onPlay,
      );

      if (owned) {
        if (active) {
          return [
            playBtn,
            _RoundIconButton(
              icon: Icons.stop_circle_outlined,
              color: const Color(0xFFE53935),
              onTap: onDeactivate,
            ),
          ];
        }
        return [
          playBtn,
          _RoundIconButton(
            icon: Icons.check_circle_rounded,
            color: const Color(0xFF4CAF50),
            onTap: onActivate,
          ),
        ];
      }
      return [
        playBtn,
        _RoundIconButton(
          icon: Icons.shopping_cart_rounded,
          color: const Color(0xFF4CAF50),
          onTap: onPurchase,
        ),
      ];
    }

    if (_isBackground) {
      final previewBtn = _RoundIconButton(
        icon: Icons.visibility_rounded,
        color: AppColors.gold,
        onTap: onPreview,
      );

      if (owned) {
        if (active) {
          return [
            previewBtn,
            _RoundIconButton(
              icon: Icons.stop_circle_outlined,
              color: const Color(0xFFE53935),
              onTap: onDeactivate,
            ),
          ];
        }
        return [
          previewBtn,
          _RoundIconButton(
            icon: Icons.check_circle_rounded,
            color: const Color(0xFF4CAF50),
            onTap: onActivate,
          ),
        ];
      }
      return [
        previewBtn,
        _RoundIconButton(
          icon: Icons.shopping_cart_rounded,
          color: const Color(0xFF4CAF50),
          onTap: onPurchase,
        ),
      ];
    }

    return const [];
  }

  Widget _priceBadge() {
    if (active) {
      return _pill(label: appState.tr('active'), color: AppColors.gold);
    }
    if (owned) {
      return _pill(
          label: appState.tr('owned'),
          color: AppColors.gold.withValues(alpha: 0.7));
    }
    if (isPremium) {
      return _pill(label: 'FREE 🎁', color: const Color(0xFFFFD700));
    }
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.stars_rounded, color: AppColors.gold, size: 12),
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
    );
  }

  Widget _pill({required String label, required Color color}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Color(0xFF041F18),
          fontWeight: FontWeight.w700,
          fontSize: 10,
        ),
      ),
    );
  }
}

class _RoundIconButton extends StatelessWidget {
  const _RoundIconButton({
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 46,
        height: 46,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.black.withValues(alpha: 0.6),
          border: Border.all(color: color, width: 2),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.4),
              blurRadius: 12,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Icon(icon, color: color, size: 24),
      ),
    );
  }
}

class _PreviewDialog extends StatelessWidget {
  const _PreviewDialog({required this.item});

  final StoreItem item;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.all(R.s(context, 12)),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: AspectRatio(
              aspectRatio: 9 / 16,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  if (item.type == 'theme')
                    ThemePreview(palette: paletteFor(item.id))
                  else if (item.imagePath != null)
                    Image.asset(item.imagePath!, fit: BoxFit.cover)
                  else
                    DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: item.gradient,
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                    ),
                  Positioned(
                    left: 16,
                    right: 16,
                    bottom: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: AppColors.gold.withValues(alpha: 0.6),
                        ),
                      ),
                      child: Text(
                        appState.isArabic
                            ? item.nameAr
                            : item.nameEn,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: AppColors.softGold,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: 8,
            right: 8,
            child: GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.black.withValues(alpha: 0.7),
                  border: Border.all(color: AppColors.gold, width: 1.5),
                ),
                child: const Icon(Icons.close_rounded,
                    color: AppColors.gold, size: 22),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PurchaseDialog extends StatelessWidget {
  const _PurchaseDialog({
    required this.item,
    required this.isPremium,
    required this.points,
  });

  final StoreItem item;
  final bool isPremium;
  final int points;

  @override
  Widget build(BuildContext context) {
    final ar = appState.isArabic;
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.all(R.s(context, 24)),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.deepGreen,
              AppColors.green.withValues(alpha: 0.95),
            ],
          ),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: AppColors.gold.withValues(alpha: 0.6),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.gold.withValues(alpha: 0.3),
              blurRadius: 24,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.gold.withValues(alpha: 0.15),
                border: Border.all(color: AppColors.gold, width: 2),
              ),
              child: const Icon(Icons.shopping_cart_rounded,
                  color: AppColors.gold, size: 30),
            ),
            const SizedBox(height: 14),
            Text(
              ar ? item.nameAr : item.nameEn,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.softGold,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.stars_rounded,
                      color: AppColors.gold, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    isPremium
                        ? '${appState.tr('price')}: ${appState.tr('free')} 🎁'
                        : '${item.price} ${appState.tr('points')}',
                    style: const TextStyle(
                      color: AppColors.gold,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 6),
            Text(
              '${appState.tr('yourBalance')}: $points ${appState.tr('points')}',
              style: TextStyle(
                color: AppColors.cream.withValues(alpha: 0.6),
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context, false),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.softGold,
                      side: BorderSide(
                        color: AppColors.softGold.withValues(alpha: 0.4),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: Text(
                      appState.tr('cancel'),
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context, true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4CAF50),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: Text(
                      appState.tr('buy'),
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _DeactivateDialog extends StatelessWidget {
  const _DeactivateDialog({required this.item});

  final StoreItem item;

  @override
  Widget build(BuildContext context) {
    final ar = appState.isArabic;
    final isAdhan = item.type == 'adhan';

    final message = isAdhan
        ? (ar
            ? 'عند إلغاء استعمال هذا المؤذن، ستعود شاشة الأذان لاستخدام الأذان الافتراضي (بدون صوت أو بالأذان الأساسي).'
            : 'When you deactivate this reciter, the Adhan screen will use the default Adhan.')
        : (ar
            ? 'عند إلغاء استعمال هذه الخلفية، ستعود الخلفية إلى الافتراضية.'
            : 'When you deactivate this background, it will return to the default.');

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.all(R.s(context, 24)),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.deepGreen,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: const Color(0xFFE53935).withValues(alpha: 0.6),
            width: 1.5,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFE53935).withValues(alpha: 0.15),
                border:
                    Border.all(color: const Color(0xFFE53935), width: 2),
              ),
              child: const Icon(Icons.warning_amber_rounded,
                  color: Color(0xFFE53935), size: 30),
            ),
            const SizedBox(height: 14),
            Text(
              ar ? 'إلغاء الاستعمال؟' : 'Deactivate?',
              style: const TextStyle(
                color: AppColors.softGold,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.cream.withValues(alpha: 0.8),
                fontSize: 13,
                height: 1.6,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context, false),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.softGold,
                      side: BorderSide(
                        color: AppColors.softGold.withValues(alpha: 0.4),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: Text(
                      appState.tr('cancel'),
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context, true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE53935),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: Text(
                      ar ? 'إلغاء الاستعمال' : 'Deactivate',
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _InsufficientPointsDialog extends StatelessWidget {
  const _InsufficientPointsDialog();

  @override
  Widget build(BuildContext context) {
    final ar = appState.isArabic;
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.all(R.s(context, 20)),
      child: Container(
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.deepGreen,
              AppColors.green.withValues(alpha: 0.95),
            ],
          ),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: AppColors.gold.withValues(alpha: 0.5),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.gold.withValues(alpha: 0.25),
              blurRadius: 30,
              spreadRadius: 3,
            ),
          ],
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Align(
                alignment: Alignment.topRight,
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.black.withValues(alpha: 0.4),
                      border: Border.all(
                        color: AppColors.gold.withValues(alpha: 0.6),
                      ),
                    ),
                    child: const Icon(Icons.close_rounded,
                        color: AppColors.gold, size: 18),
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Center(
                child: Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.gold.withValues(alpha: 0.15),
                    border: Border.all(color: AppColors.gold, width: 2),
                  ),
                  child: const Icon(Icons.stars_rounded,
                      color: AppColors.gold, size: 36),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                ar
                    ? 'عزيزي المستعمل، نعتذر منك'
                    : 'Dear user, we apologize',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.softGold,
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                ar
                    ? 'نقاطك غير كافية لهذا المنتج'
                    : 'Your points are not enough for this product',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.cream.withValues(alpha: 0.8),
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 20),
              Divider(color: AppColors.gold.withValues(alpha: 0.25)),
              const SizedBox(height: 16),
              Text(
                ar
                    ? 'يمكنك أن تجمع نقاطاً مجانية من خلال:'
                    : 'You can collect free points through:',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.cream.withValues(alpha: 0.7),
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 14),
              _MethodCard(
                icon: Icons.quiz_rounded,
                title: ar
                    ? 'أكمل 5 تحديات يومية واكسب نقاط'
                    : 'Complete 5 daily challenges and earn points',
                buttonLabel: ar ? 'التحديات' : 'Challenges',
                color: AppColors.gold,
                onTap: () {
                  Navigator.pop(context);
                  Navigator.of(context).push(
                    MaterialPageRoute(
                        builder: (_) => const ChallengeScreen()),
                  );
                },
              ),
              const SizedBox(height: 10),
              _MethodCard(
                icon: Icons.play_circle_fill_rounded,
                title: ar
                    ? 'اجمع حتى 1000 نقطة يومياً من مشاهدة الإعلانات'
                    : 'Collect up to 1000 points daily by watching ads',
                buttonLabel: ar ? 'مشاهدة الإعلانات' : 'Watch Ads',
                color: const Color(0xFF4CAF50),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.of(context).push(
                    MaterialPageRoute(
                        builder: (_) => const ChallengeScreen()),
                  );
                },
              ),
              const SizedBox(height: 20),
              Divider(color: AppColors.gold.withValues(alpha: 0.25)),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.gold.withValues(alpha: 0.2),
                      AppColors.deepGreen.withValues(alpha: 0.9),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppColors.gold.withValues(alpha: 0.5),
                  ),
                ),
                child: Column(
                  children: [
                    const Icon(Icons.workspace_premium_rounded,
                        color: AppColors.gold, size: 30),
                    const SizedBox(height: 8),
                    Text(
                      ar
                          ? 'جرّب Premium — 10,000 نقطة شهرياً + متجر مجاني كامل + مضاعفة نقاط التحدي + المزيد'
                          : 'Try Premium — 10,000 points monthly + free store + 2x challenge points + more',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: AppColors.softGold,
                        fontSize: 12,
                        height: 1.6,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          Navigator.of(context).push(
                            MaterialPageRoute(
                                builder: (_) => const PremiumScreen()),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.gold,
                          foregroundColor: AppColors.deepGreen,
                          padding:
                              const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: Text(
                          ar ? 'اشترك في Premium' : 'Subscribe to Premium',
                          style: const TextStyle(
                              fontWeight: FontWeight.w800),
                        ),
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
}

class _MethodCard extends StatelessWidget {
  const _MethodCard({
    required this.icon,
    required this.title,
    required this.buttonLabel,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String buttonLabel;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 22),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: AppColors.cream.withValues(alpha: 0.9),
                    fontSize: 12.5,
                    height: 1.5,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onTap,
              style: ElevatedButton.styleFrom(
                backgroundColor: color,
                foregroundColor: AppColors.deepGreen,
                padding: const EdgeInsets.symmetric(vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                buttonLabel,
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PremiumBanner extends StatefulWidget {
  final VoidCallback onTap;

  const _PremiumBanner({required this.onTap});

  @override
  State<_PremiumBanner> createState() => _PremiumBannerState();
}

class _PremiumBannerState extends State<_PremiumBanner>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2000),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pulse,
      builder: (context, child) {
        final t = _pulse.value;
        return GestureDetector(
          onTap: widget.onTap,
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                colors: [
                  AppColors.gold.withValues(alpha: 0.25 + 0.08 * t),
                  AppColors.deepGreen.withValues(alpha: 0.9),
                ],
              ),
              border: Border.all(
                color: AppColors.gold.withValues(alpha: 0.6 + 0.3 * t),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.gold.withValues(alpha: 0.2 + 0.2 * t),
                  blurRadius: 14 + 6 * t,
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.gold.withValues(alpha: 0.2),
                    border: Border.all(color: AppColors.gold, width: 1.5),
                  ),
                  child: const Icon(
                    Icons.workspace_premium_rounded,
                    color: AppColors.gold,
                    size: 26,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Text(
                            'Premium',
                            style: TextStyle(
                              color: AppColors.softGold,
                              fontSize: 15,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.gold,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              'NEW',
                              style: TextStyle(
                                color: AppColors.deepGreen,
                                fontSize: 8.5,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text(
                        appState.isArabic
                            ? 'ميزات حصرية + دعم مباشر للتطوير'
                            : 'Exclusive features + direct support',
                        style: TextStyle(
                          color: AppColors.cream.withValues(alpha: 0.75),
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  color: AppColors.gold.withValues(alpha: 0.8),
                  size: 22,
                ),
              ],
            ),
          ),
        );
      },
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
