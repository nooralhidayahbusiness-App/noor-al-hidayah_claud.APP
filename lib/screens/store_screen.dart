import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/app_state.dart';
import '../core/responsive.dart';
import '../core/theme.dart';
import '../core/themed_colors.dart';
import '../services/auth_service.dart';
import '../services/premium_service.dart';
import '../widgets/animated_entry.dart';
import '../widgets/glass_card.dart';
import '../data/store_items.dart';

class StoreScreen extends StatefulWidget {
  const StoreScreen({super.key});

  @override
  State<StoreScreen> createState() => _StoreScreenState();
}

class _StoreScreenState extends State<StoreScreen> {
  bool _isPremium = false;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadPremium();
  }

  Future<void> _loadPremium() async {
    final uid = AuthService.currentUid;
    if (uid != null) {
      final p = await PremiumService.isUserPremium(uid);
      if (mounted) setState(() { _isPremium = p; _loading = false; });
    } else {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = AppState.of(context);
    final uid = AuthService.currentUid;

    return Scaffold(
      backgroundColor: AppColors.deepGreen,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          appState.tr('store'),
          style: TextStyle(color: AppColors.gold, fontWeight: FontWeight.bold),
        ),
        iconTheme: IconThemeData(color: AppColors.gold),
      ),
      body: _loading
          ? Center(child: CircularProgressIndicator(color: AppColors.gold))
          : SingleChildScrollView(
              padding: EdgeInsets.all(R.s(context, 16)),
              child: Column(
                children: [
                  // Premium banner (نابض)
                  if (!_isPremium) _buildPremiumBanner(context, appState),

                  // نقاط المستخدم
                  _buildPointsHeader(context, appState, uid),

                  SizedBox(height: R.s(context, 16)),

                  // تبويبات المتجر: خلفيات، أذان، ثيمات، خلفيات أذان
                  DefaultTabController(
                    length: 4,
                    child: Column(
                      children: [
                        TabBar(
                          indicatorColor: AppColors.gold,
                          labelColor: AppColors.gold,
                          unselectedLabelColor: AppColors.cream.withOpacity(0.6),
                          tabs: [
                            Tab(text: appState.tr('backgrounds')),
                            Tab(text: appState.tr('adhan')),
                            Tab(text: appState.tr('themes')),
                            Tab(text: appState.tr('adhan_backgrounds')),
                          ],
                        ),
                        SizedBox(
                          height: R.s(context, 500),
                          child: TabBarView(
                            children: [
                              _buildItemsGrid(context, appState, StoreItems.backgrounds, 'backgrounds'),
                              _buildItemsGrid(context, appState, StoreItems.adhans, 'adhans'),
                              _buildItemsGrid(context, appState, StoreItems.themes, 'themes'),
                              _buildItemsGrid(context, appState, StoreItems.adhanBackgrounds, 'adhanBackgrounds'),
                            ],
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

  Widget _buildPremiumBanner(BuildContext context, AppState appState) {
    return AnimatedEntry(
      child: GestureDetector(
        onTap: () {
          // الانتقال إلى شاشة Premium
          Navigator.pushNamed(context, '/premium');
        },
        child: Container(
          margin: EdgeInsets.only(bottom: R.s(context, 16)),
          padding: EdgeInsets.all(R.s(context, 16)),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.gold, AppColors.softGold],
            ),
            borderRadius: BorderRadius.circular(R.s(context, 16)),
            boxShadow: [
              BoxShadow(
                color: AppColors.gold.withOpacity(0.5),
                blurRadius: 20,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Row(
            children: [
              Icon(Icons.workspace_premium, color: AppColors.deepGreen, size: R.s(context, 32)),
              SizedBox(width: R.s(context, 12)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      appState.tr('premium_title'),
                      style: TextStyle(
                        color: AppColors.deepGreen,
                        fontSize: R.f(context, 16),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      appState.tr('premium_store_hint'),
                      style: TextStyle(color: AppColors.deepGreen.withOpacity(0.8), fontSize: R.f(context, 12)),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios, color: AppColors.deepGreen, size: R.s(context, 16)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPointsHeader(BuildContext context, AppState appState, String? uid) {
    return StreamBuilder<DocumentSnapshot>(
      stream: uid != null
          ? FirebaseFirestore.instance.collection('users').doc(uid).snapshots()
          : const Stream.empty(),
      builder: (context, snap) {
        final data = snap.data?.data() as Map<String, dynamic>?;
        final stats = (data?['stats'] ?? {}) as Map<String, dynamic>;
        final points = (stats['points'] ?? 0) as int;

        return GlassCard(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.stars, color: AppColors.gold, size: R.s(context, 24)),
              SizedBox(width: R.s(context, 8)),
              Text(
                '$points ${appState.tr('points')}',
                style: TextStyle(
                  color: AppColors.gold,
                  fontSize: R.f(context, 18),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildItemsGrid(
    BuildContext context,
    AppState appState,
    List<StoreItem> items,
    String category,
  ) {
    return GridView.builder(
      padding: EdgeInsets.only(top: R.s(context, 12)),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: R.s(context, 12),
        mainAxisSpacing: R.s(context, 12),
        childAspectRatio: 0.85,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return _buildStoreItemCard(context, appState, item, category);
      },
    );
  }

  Widget _buildStoreItemCard(
    BuildContext context,
    AppState appState,
    StoreItem item,
    String category,
  ) {
    final uid = AuthService.currentUid;
    final isPremium = _isPremium;

    return StreamBuilder<DocumentSnapshot>(
      stream: uid != null
          ? FirebaseFirestore.instance.collection('users').doc(uid).snapshots()
          : const Stream.empty(),
      builder: (context, snap) {
        final data = snap.data?.data() as Map<String, dynamic>?;
        final inventory = (data?['inventory'] ?? {}) as Map<String, dynamic>;
        final owned = (inventory[category] as List?)?.contains(item.id) ?? false;
        final active = inventory['active${category[0].toUpperCase()}${category.substring(1)}'] == item.id;

        final canBuy = isPremium || (data?['stats']?['points'] ?? 0) >= item.cost;

        return GlassCard(
          child: Column(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage(item.preview),
                      fit: BoxFit.cover,
                    ),
                    borderRadius: BorderRadius.circular(R.s(context, 12)),
                  ),
                ),
              ),
              SizedBox(height: R.s(context, 8)),
              Text(
                appState.tr(item.nameKey),
                style: TextStyle(color: AppColors.cream, fontSize: R.f(context, 13)),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: R.s(context, 6)),
              if (active)
                _badge(context, appState.tr('active'), AppColors.emerald)
              else if (owned)
                _badge(context, appState.tr('owned'), AppColors.gold)
              else
                GestureDetector(
                  onTap: canBuy
                      ? () async {
                          // شراء
                          await _purchaseItem(context, appState, item, category, isPremium);
                        }
                      : null,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: R.s(context, 12),
                      vertical: R.s(context, 6),
                    ),
                    decoration: BoxDecoration(
                      color: canBuy ? AppColors.gold : Colors.grey,
                      borderRadius: BorderRadius.circular(R.s(context, 20)),
                    ),
                    child: Text(
                      isPremium ? appState.tr('free') : '${item.cost} ${appState.tr('points')}',
                      style: TextStyle(
                        color: AppColors.deepGreen,
                        fontWeight: FontWeight.bold,
                        fontSize: R.f(context, 12),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _badge(BuildContext context, String text, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: R.s(context, 12), vertical: R.s(context, 6)),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(R.s(context, 20)),
      ),
      child: Text(
        text,
        style: TextStyle(color: AppColors.deepGreen, fontWeight: FontWeight.bold, fontSize: R.f(context, 12)),
      ),
    );
  }

  Future<void> _purchaseItem(
    BuildContext context,
    AppState appState,
    StoreItem item,
    String category,
    bool isPremium,
  ) async {
    final uid = AuthService.currentUid;
    if (uid == null) return;

    try {
      final userRef = FirebaseFirestore.instance.collection('users').doc(uid);

      await FirebaseFirestore.instance.runTransaction((tx) async {
        final snap = await tx.get(userRef);
        final data = snap.data() as Map<String, dynamic>;
        final stats = (data['stats'] ?? {}) as Map<String, dynamic>;
        final points = (stats['points'] ?? 0) as int;
        final inventory = (data['inventory'] ?? {}) as Map<String, dynamic>;

        final owned = (inventory[category] as List?)?.contains(item.id) ?? false;
        if (owned) return;

        if (!isPremium && points < item.cost) {
          throw Exception('نقاط غير كافية');
        }

        final newPoints = isPremium ? points : points - item.cost;
        final newList = List<String>.from(inventory[category] ?? []);
        newList.add(item.id);

        tx.update(userRef, {
          'stats.points': newPoints,
          'inventory.$category': newList,
          'inventory.active${category[0].toUpperCase()}${category.substring(1)}': item.id,
        });
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(appState.tr('purchase_success')), backgroundColor: AppColors.emerald),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
        );
      }
    }
  }
}

class StoreItem {
  final String id;
  final String nameKey;
  final String preview;
  final int cost;

  const StoreItem({required this.id, required this.nameKey, required this.preview, required this.cost});
}
