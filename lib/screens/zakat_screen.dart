import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/app_state.dart';
import '../core/responsive.dart';
import '../core/theme.dart';
import '../services/metals_service.dart';
import '../widgets/glass_card.dart';
import '../widgets/themed_background.dart';

class ZakatScreen extends StatefulWidget {
  const ZakatScreen({super.key});

  @override
  State<ZakatScreen> createState() => _ZakatScreenState();
}

class _ZakatScreenState extends State<ZakatScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs = TabController(length: 5, vsync: this);
  bool _loadingPrices = true;
  bool _priceFetchFailed = false;

  @override
  void initState() {
    super.initState();
    _loadPrices();
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  Future<void> _loadPrices() async {
    setState(() {
      _loadingPrices = true;
      _priceFetchFailed = false;
    });
    final ok = await MetalsService.fetch();
    if (mounted) {
      setState(() {
        _loadingPrices = false;
        _priceFetchFailed = !ok;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ThemedBackground(
        child: SafeArea(
          child: Column(
            children: [
              // ===== الهيدر =====
              Padding(
                padding: EdgeInsetsDirectional.fromSTEB(
                  R.s(context, 6),
                  R.s(context, 6),
                  R.s(context, 16),
                  0,
                ),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.of(context).maybePop(),
                      color: AppColors.softGold,
                      iconSize: R.s(context, 22),
                      icon: const Icon(Icons.arrow_back_rounded),
                    ),
                    const Spacer(),
                    Text(
                      appState.tr('zakat'),
                      style: TextStyle(
                        fontSize: R.f(context, 15),
                        fontWeight: FontWeight.w700,
                        color: AppColors.softGold,
                      ),
                    ),
                    SizedBox(width: R.s(context, 40)),
                  ],
                ),
              ),

              // ===== تنبيه: حاسبة فقط =====
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: R.s(context, 16),
                  vertical: R.s(context, 6),
                ),
                child: GlassCard(
                  ornament: false,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.info_outline_rounded,
                        color: AppColors.gold,
                        size: R.s(context, 18),
                      ),
                      SizedBox(width: R.s(context, 8)),
                      Expanded(
                        child: Text(
                          appState.tr('zakatDisclaimer'),
                          style: TextStyle(
                            fontSize: R.f(context, 10.5),
                            height: 1.5,
                            color: AppColors.cream.withValues(alpha: 0.9),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // ===== حالة الأسعار =====
              Padding(
                padding: EdgeInsets.symmetric(horizontal: R.s(context, 16)),
                child: _PriceStatus(
                  loading: _loadingPrices,
                  failed: _priceFetchFailed,
                  onRetry: _loadPrices,
                ),
              ),

              SizedBox(height: R.s(context, 4)),

              // ===== التبويبات =====
              TabBar(
                controller: _tabs,
                isScrollable: true,
                tabAlignment: TabAlignment.center,
                indicatorColor: AppColors.gold,
                labelColor: AppColors.gold,
                unselectedLabelColor:
                    AppColors.cream.withValues(alpha: 0.6),
                indicatorWeight: 3,
                labelStyle: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: R.f(context, 12.5),
                ),
                tabs: [
                  Tab(text: appState.tr('zakatTabMoney')),
                  Tab(text: appState.tr('zakatTabGold')),
                  Tab(text: appState.tr('zakatTabSilver')),
                  Tab(text: appState.tr('zakatTabCrops')),
                  Tab(text: appState.tr('zakatTabLivestock')),
                ],
              ),

              // ===== المحتوى =====
              Expanded(
                child: TabBarView(
                  controller: _tabs,
                  children: const [
                    _MoneyTab(),
                    _GoldTab(),
                    _SilverTab(),
                    _CropsTab(),
                    _LivestockTab(),
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

// ==================== حالة الأسعار ====================
class _PriceStatus extends StatelessWidget {
  const _PriceStatus({
    required this.loading,
    required this.failed,
    required this.onRetry,
  });

  final bool loading;
  final bool failed;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: R.s(context, 12),
            height: R.s(context, 12),
            child: const CircularProgressIndicator(
              strokeWidth: 2,
              color: AppColors.gold,
            ),
          ),
          SizedBox(width: R.s(context, 6)),
          Text(
            appState.tr('zakatFetchingPrices'),
            style: TextStyle(
              fontSize: R.f(context, 10.5),
              color: AppColors.cream.withValues(alpha: 0.7),
            ),
          ),
        ],
      );
    }
    if (failed) {
      return GestureDetector(
        onTap: onRetry,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.refresh_rounded,
                color: AppColors.gold, size: R.s(context, 14)),
            SizedBox(width: R.s(context, 4)),
            Text(
              appState.tr('zakatPriceFailed'),
              style: TextStyle(
                fontSize: R.f(context, 10.5),
                color: AppColors.gold,
              ),
            ),
          ],
        ),
      );
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.check_circle_rounded,
            color: AppColors.gold, size: R.s(context, 12)),
        SizedBox(width: R.s(context, 4)),
        Text(
          '${appState.tr('zakatPriceLive')} · ${MetalsService.goldPerGramUsd.toStringAsFixed(2)} \$/g',
          style: TextStyle(
            fontSize: R.f(context, 10),
            color: AppColors.cream.withValues(alpha: 0.6),
          ),
        ),
      ],
    );
  }
}

// ==================== حقل رقمي ====================
class _NumField extends StatelessWidget {
  const _NumField({
    required this.controller,
    required this.label,
    required this.suffix,
    this.onChanged,
  });

  final TextEditingController controller;
  final String label;
  final String suffix;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
      ],
      onChanged: onChanged,
      style: TextStyle(
        color: AppColors.cream,
        fontSize: R.f(context, 14),
      ),
      textAlign: TextAlign.end,
      decoration: InputDecoration(
        labelText: label,
        labelStyle:
            TextStyle(color: AppColors.cream.withValues(alpha: 0.7)),
        suffixText: suffix,
        suffixStyle: TextStyle(
          color: AppColors.gold,
          fontSize: R.f(context, 12),
          fontWeight: FontWeight.w600,
        ),
        filled: true,
        fillColor: Colors.black.withValues(alpha: 0.25),
        contentPadding: EdgeInsets.symmetric(
          horizontal: R.s(context, 12),
          vertical: R.s(context, 14),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide:
              BorderSide(color: AppColors.gold.withValues(alpha: 0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: AppColors.gold, width: 1.5),
        ),
      ),
    );
  }
}

// ==================== بطاقة النتيجة ====================
class _ResultCard extends StatelessWidget {
  const _ResultCard({
    required this.title,
    required this.rows,
    required this.due,
    required this.dueLabel,
    required this.belowNisab,
  });

  final String title;
  final List<MapEntry<String, String>> rows;
  final double due;
  final String dueLabel;
  final bool belowNisab;

  @override
  Widget build(BuildContext context) {
    final showDue = !belowNisab && due > 0;
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(Icons.calculate_rounded,
                  color: AppColors.gold, size: R.s(context, 18)),
              SizedBox(width: R.s(context, 6)),
              Text(
                title,
                style: TextStyle(
                  fontSize: R.f(context, 13),
                  fontWeight: FontWeight.w700,
                  color: AppColors.softGold,
                ),
              ),
            ],
          ),
          SizedBox(height: R.s(context, 8)),
          for (final row in rows)
            Padding(
              padding: EdgeInsets.only(bottom: R.s(context, 4)),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      row.key,
                      style: TextStyle(
                        fontSize: R.f(context, 11.5),
                        color: AppColors.cream.withValues(alpha: 0.75),
                      ),
                    ),
                  ),
                  Text(
                    row.value,
                    style: TextStyle(
                      fontSize: R.f(context, 11.5),
                      fontWeight: FontWeight.w600,
                      color: AppColors.cream,
                    ),
                  ),
                ],
              ),
            ),
          SizedBox(height: R.s(context, 8)),
          Container(
            padding: EdgeInsets.all(R.s(context, 10)),
            decoration: BoxDecoration(
              color: showDue
                  ? AppColors.gold.withValues(alpha: 0.15)
                  : Colors.black.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: showDue
                    ? AppColors.gold
                    : AppColors.gold.withValues(alpha: 0.3),
              ),
            ),
            child: Column(
              children: [
                Text(
                  belowNisab
                      ? appState.tr('zakatBelowNisab')
                      : dueLabel,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: R.f(context, 11),
                    color: belowNisab
                        ? AppColors.cream.withValues(alpha: 0.7)
                        : AppColors.softGold,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (showDue) ...[
                  SizedBox(height: R.s(context, 4)),
                  Text(
                    due.toStringAsFixed(2),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: R.f(context, 22),
                      fontWeight: FontWeight.w900,
                      color: AppColors.gold,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ==================== تبويب: المال ====================
class _MoneyTab extends StatefulWidget {
  const _MoneyTab();

  @override
  State<_MoneyTab> createState() => _MoneyTabState();
}

class _MoneyTabState extends State<_MoneyTab> {
  final _amount = TextEditingController();
  final _goldPrice = TextEditingController();

  @override
  void initState() {
    super.initState();
    _goldPrice.text = MetalsService.goldPerGramUsd.toStringAsFixed(2);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _refreshPrice();
    });
  }

  void _refreshPrice() {
    if (MetalsService.lastFetch != null) {
      _goldPrice.text = MetalsService.goldPerGramUsd.toStringAsFixed(2);
      setState(() {});
    }
  }

  @override
  void dispose() {
    _amount.dispose();
    _goldPrice.dispose();
    super.dispose();
  }

  double get _amountV => double.tryParse(_amount.text) ?? 0;
  double get _goldPriceV => double.tryParse(_goldPrice.text) ?? 0;
  double get _nisab => 85 * _goldPriceV;
  bool get _reached => _amountV >= _nisab && _nisab > 0;
  double get _due => _reached ? _amountV * 0.025 : 0;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.all(R.s(context, 16)),
      children: [
        _NumField(
          controller: _amount,
          label: appState.tr('zakatMoneyAmount'),
          suffix: appState.tr('currencyUnit'),
          onChanged: (_) => setState(() {}),
        ),
        SizedBox(height: R.s(context, 10)),
        _NumField(
          controller: _goldPrice,
          label: appState.tr('zakatGoldPrice'),
          suffix: '/ g',
          onChanged: (_) => setState(() {}),
        ),
        SizedBox(height: R.s(context, 6)),
        Text(
          appState.tr('zakatMoneyNisabHint'),
          style: TextStyle(
            fontSize: R.f(context, 10),
            color: AppColors.cream.withValues(alpha: 0.6),
          ),
        ),
        SizedBox(height: R.s(context, 14)),
        _ResultCard(
          title: appState.tr('zakatResult'),
          rows: [
            MapEntry(
              appState.tr('zakatMoneyAmount'),
              _amountV.toStringAsFixed(2),
            ),
            MapEntry(
              appState.tr('zakatNisab'),
              _nisab.toStringAsFixed(2),
            ),
          ],
          due: _due,
          dueLabel: appState.tr('zakatDueAmount'),
          belowNisab: !_reached,
        ),
      ],
    );
  }
}

// ==================== تبويب: الذهب ====================
class _GoldTab extends StatefulWidget {
  const _GoldTab();

  @override
  State<_GoldTab> createState() => _GoldTabState();
}

class _GoldTabState extends State<_GoldTab> {
  final _weight = TextEditingController();
  final _price = TextEditingController();
  int _karat = 24;

  @override
  void initState() {
    super.initState();
    _price.text = MetalsService.goldPerGramUsd.toStringAsFixed(2);
  }

  @override
  void dispose() {
    _weight.dispose();
    _price.dispose();
    super.dispose();
  }

  double get _weightV => double.tryParse(_weight.text) ?? 0;
  double get _priceV => double.tryParse(_price.text) ?? 0;
  double get _pureWeight => _weightV * (_karat / 24.0);
  double get _value => _weightV * _priceV * (_karat / 24.0);
  bool get _reached => _pureWeight >= 85;
  double get _due => _reached ? _value * 0.025 : 0;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.all(R.s(context, 16)),
      children: [
        _NumField(
          controller: _weight,
          label: appState.tr('zakatGoldWeight'),
          suffix: 'g',
          onChanged: (_) => setState(() {}),
        ),
        SizedBox(height: R.s(context, 10)),
        // اختيار العيار
        Text(
          appState.tr('zakatKarat'),
          style: TextStyle(
            fontSize: R.f(context, 12),
            color: AppColors.cream.withValues(alpha: 0.8),
          ),
        ),
        SizedBox(height: R.s(context, 6)),
        Row(
          children: [
            for (final k in [24, 22, 21, 18, 14])
              Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: R.s(context, 2)),
                  child: GestureDetector(
                    onTap: () => setState(() => _karat = k),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: EdgeInsets.symmetric(
                          vertical: R.s(context, 8)),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: _karat == k
                            ? AppColors.gold
                            : AppColors.gold.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.gold.withValues(alpha: 0.6),
                        ),
                      ),
                      child: Text(
                        '$k',
                        style: TextStyle(
                          fontSize: R.f(context, 12),
                          fontWeight: FontWeight.w700,
                          color: _karat == k
                              ? AppColors.deepGreen
                              : AppColors.gold,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
        SizedBox(height: R.s(context, 10)),
        _NumField(
          controller: _price,
          label: appState.tr('zakatGoldPrice24'),
          suffix: '/ g',
          onChanged: (_) => setState(() {}),
        ),
        SizedBox(height: R.s(context, 14)),
        _ResultCard(
          title: appState.tr('zakatResult'),
          rows: [
            MapEntry(
              appState.tr('zakatPureWeight'),
              '${_pureWeight.toStringAsFixed(2)} g',
            ),
            MapEntry(
              appState.tr('zakatNisab'),
              '85.00 g',
            ),
            MapEntry(
              appState.tr('zakatGoldValue'),
              _value.toStringAsFixed(2),
            ),
          ],
          due: _due,
          dueLabel: appState.tr('zakatDueAmount'),
          belowNisab: !_reached,
        ),
      ],
    );
  }
}

// ==================== تبويب: الفضة ====================
class _SilverTab extends StatefulWidget {
  const _SilverTab();

  @override
  State<_SilverTab> createState() => _SilverTabState();
}

class _SilverTabState extends State<_SilverTab> {
  final _weight = TextEditingController();
  final _price = TextEditingController();

  @override
  void initState() {
    super.initState();
    _price.text = MetalsService.silverPerGramUsd.toStringAsFixed(3);
  }

  @override
  void dispose() {
    _weight.dispose();
    _price.dispose();
    super.dispose();
  }

  double get _weightV => double.tryParse(_weight.text) ?? 0;
  double get _priceV => double.tryParse(_price.text) ?? 0;
  double get _value => _weightV * _priceV;
  bool get _reached => _weightV >= 595;
  double get _due => _reached ? _value * 0.025 : 0;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.all(R.s(context, 16)),
      children: [
        _NumField(
          controller: _weight,
          label: appState.tr('zakatSilverWeight'),
          suffix: 'g',
          onChanged: (_) => setState(() {}),
        ),
        SizedBox(height: R.s(context, 10)),
        _NumField(
          controller: _price,
          label: appState.tr('zakatSilverPrice'),
          suffix: '/ g',
          onChanged: (_) => setState(() {}),
        ),
        SizedBox(height: R.s(context, 14)),
        _ResultCard(
          title: appState.tr('zakatResult'),
          rows: [
            MapEntry(
              appState.tr('zakatNisab'),
              '595.00 g',
            ),
            MapEntry(
              appState.tr('zakatSilverValue'),
              _value.toStringAsFixed(2),
            ),
          ],
          due: _due,
          dueLabel: appState.tr('zakatDueAmount'),
          belowNisab: !_reached,
        ),
      ],
    );
  }
}

// ==================== تبويب: الزروع ====================
class _CropsTab extends StatefulWidget {
  const _CropsTab();

  @override
  State<_CropsTab> createState() => _CropsTabState();
}

class _CropsTabState extends State<_CropsTab> {
  final _weight = TextEditingController();
  bool _rainFed = true;

  @override
  void dispose() {
    _weight.dispose();
    super.dispose();
  }

  double get _weightV => double.tryParse(_weight.text) ?? 0;
  bool get _reached => _weightV >= 653;
  double get _due => _reached
      ? _weightV * (_rainFed ? 0.10 : 0.05)
      : 0;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.all(R.s(context, 16)),
      children: [
        _NumField(
          controller: _weight,
          label: appState.tr('zakatCropWeight'),
          suffix: 'kg',
          onChanged: (_) => setState(() {}),
        ),
        SizedBox(height: R.s(context, 10)),
        Text(
          appState.tr('zakatIrrigationType'),
          style: TextStyle(
            fontSize: R.f(context, 12),
            color: AppColors.cream.withValues(alpha: 0.8),
          ),
        ),
        SizedBox(height: R.s(context, 6)),
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _rainFed = true),
                child: _IrrigationChip(
                  label: appState.tr('zakatRainFed'),
                  subtitle: '10%',
                  selected: _rainFed,
                ),
              ),
            ),
            SizedBox(width: R.s(context, 8)),
            Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _rainFed = false),
                child: _IrrigationChip(
                  label: appState.tr('zakatIrrigated'),
                  subtitle: '5%',
                  selected: !_rainFed,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: R.s(context, 14)),
        _ResultCard(
          title: appState.tr('zakatResult'),
          rows: [
            MapEntry(
              appState.tr('zakatNisab'),
              '653.00 kg',
            ),
            MapEntry(
              appState.tr('zakatCropWeight'),
              '${_weightV.toStringAsFixed(2)} kg',
            ),
            MapEntry(
              appState.tr('zakatCropRate'),
              _rainFed ? '10%' : '5%',
            ),
          ],
          due: _due,
          dueLabel: appState.tr('zakatDueWeight'),
          belowNisab: !_reached,
        ),
      ],
    );
  }
}

class _IrrigationChip extends StatelessWidget {
  const _IrrigationChip({
    required this.label,
    required this.subtitle,
    required this.selected,
  });

  final String label;
  final String subtitle;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: EdgeInsets.all(R.s(context, 10)),
      decoration: BoxDecoration(
        color: selected
            ? AppColors.gold.withValues(alpha: 0.2)
            : Colors.black.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: selected
              ? AppColors.gold
              : AppColors.gold.withValues(alpha: 0.3),
          width: selected ? 1.5 : 1,
        ),
      ),
      child: Column(
        children: [
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: R.f(context, 11.5),
              fontWeight: FontWeight.w600,
              color: selected ? AppColors.gold : AppColors.cream,
            ),
          ),
          SizedBox(height: R.s(context, 2)),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: R.f(context, 10),
              color: AppColors.cream.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }
}

// ==================== تبويب: الأنعام ====================
class _LivestockTab extends StatefulWidget {
  const _LivestockTab();

  @override
  State<_LivestockTab> createState() => _LivestockTabState();
}

class _LivestockTabState extends State<_LivestockTab> {
  String _animal = 'sheep';
  final _count = TextEditingController();

  @override
  void dispose() {
    _count.dispose();
    super.dispose();
  }

  int get _n => int.tryParse(_count.text) ?? 0;

  String _computeZakat() {
    if (_n <= 0) return '—';
    switch (_animal) {
      case 'sheep':
        if (_n < 40) return appState.tr('zakatNoZakat');
        if (_n <= 120) return '1 ${appState.tr('zakatSheep')}';
        if (_n <= 200) return '2 ${appState.tr('zakatSheep')}';
        if (_n <= 399) return '3 ${appState.tr('zakatSheep')}';
        final hundreds = _n ~/ 100;
        return '$hundreds ${appState.tr('zakatSheep')}';
      case 'cow':
        if (_n < 30) return appState.tr('zakatNoZakat');
        if (_n <= 39) return '1 ${appState.tr('zakatCalf')} (${appState.tr('zakatTabii')})';
        if (_n <= 59) return '1 ${appState.tr('zakatCalf')} (${appState.tr('zakatMusinnah')})';
        if (_n <= 69) return '2 ${appState.tr('zakatCalf')}';
        final extra = (_n - 60) ~/ 30;
        return '${2 + extra} ${appState.tr('zakatCalf')}';
      case 'camel':
        if (_n < 5) return appState.tr('zakatNoZakat');
        if (_n <= 24) return '1 ${appState.tr('zakatSheep')}';
        if (_n <= 35) return '1 ${appState.tr('zakatBintMakhad')}';
        if (_n <= 45) return '1 ${appState.tr('zakatBintLabun')}';
        if (_n <= 60) return '1 ${appState.tr('zakatHiqqah')}';
        if (_n <= 75) return '1 ${appState.tr('zakatJadhah')}';
        if (_n <= 90) return '2 ${appState.tr('zakatBintLabun')}';
        if (_n <= 120) return '2 ${appState.tr('zakatHiqqah')}';
        final hundreds = _n ~/ 50;
        return '$hundreds ${appState.tr('zakatHiqqah')}';
    }
    return '—';
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.all(R.s(context, 16)),
      children: [
        Text(
          appState.tr('zakatAnimalType'),
          style: TextStyle(
            fontSize: R.f(context, 12),
            color: AppColors.cream.withValues(alpha: 0.8),
          ),
        ),
        SizedBox(height: R.s(context, 6)),
        Row(
          children: [
            for (final a in ['sheep', 'cow', 'camel'])
              Expanded(
                child: Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: R.s(context, 2)),
                  child: GestureDetector(
                    onTap: () => setState(() => _animal = a),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: EdgeInsets.symmetric(
                          vertical: R.s(context, 10)),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: _animal == a
                            ? AppColors.gold
                            : AppColors.gold.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.gold.withValues(alpha: 0.6),
                        ),
                      ),
                      child: Text(
                        appState.tr('zakat_$a'),
                        style: TextStyle(
                          fontSize: R.f(context, 11.5),
                          fontWeight: FontWeight.w700,
                          color: _animal == a
                              ? AppColors.deepGreen
                              : AppColors.gold,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
        SizedBox(height: R.s(context, 12)),
        _NumField(
          controller: _count,
          label: appState.tr('zakatAnimalCount'),
          suffix: appState.tr('zakatHead'),
          onChanged: (_) => setState(() {}),
        ),
        SizedBox(height: R.s(context, 14)),
        GlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Icon(Icons.calculate_rounded,
                      color: AppColors.gold, size: R.s(context, 18)),
                  SizedBox(width: R.s(context, 6)),
                  Text(
                    appState.tr('zakatResult'),
                    style: TextStyle(
                      fontSize: R.f(context, 13),
                      fontWeight: FontWeight.w700,
                      color: AppColors.softGold,
                    ),
                  ),
                ],
              ),
              SizedBox(height: R.s(context, 10)),
              Container(
                padding: EdgeInsets.all(R.s(context, 10)),
                decoration: BoxDecoration(
                  color: AppColors.gold.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.gold),
                ),
                child: Text(
                  _computeZakat(),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: R.f(context, 16),
                    fontWeight: FontWeight.w800,
                    color: AppColors.gold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
