import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/app_state.dart';
import '../core/prayer_state.dart';
import '../core/responsive.dart';
import '../core/theme.dart';
import '../data/currencies.dart';
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
  String _currencyCode = 'USD';

  @override
  void initState() {
    super.initState();
    _init();
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  Future<void> _init() async {
    await _loadSavedCurrency();
    await _loadPrices();
  }

  Future<void> _loadSavedCurrency() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString('zakat_currency');
    if (saved != null) {
      _currencyCode = saved;
      return;
    }
    // كشف تلقائي من الموقع
    final label = prayerState.location?.label ?? '';
    final detected = detectCurrencyFromLocation(label);
    if (detected != null) {
      _currencyCode = detected;
    } else {
      _currencyCode = 'USD';
    }
    await prefs.setString('zakat_currency', _currencyCode);
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

  Future<void> _changeCurrency(String code) async {
    setState(() => _currencyCode = code);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('zakat_currency', code);
  }

  void _openCurrencyPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _CurrencyPickerSheet(
        selected: _currencyCode,
        onSelect: (code) {
          _changeCurrency(code);
          Navigator.pop(context);
        },
      ),
    );
  }

  Currency get _currency =>
      currencyByCode(_currencyCode) ??
      const Currency(
          code: 'USD', symbol: '\$', nameAr: 'دولار', nameEn: 'Dollar');

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

              // ===== تنبيه =====
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: R.s(context, 16),
                  vertical: R.s(context, 4),
                ),
                child: GlassCard(
                  ornament: false,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.info_outline_rounded,
                          color: AppColors.gold, size: R.s(context, 16)),
                      SizedBox(width: R.s(context, 8)),
                      Expanded(
                        child: Text(
                          appState.tr('zakatDisclaimer'),
                          style: TextStyle(
                            fontSize: R.f(context, 10),
                            height: 1.4,
                            color: AppColors.cream.withValues(alpha: 0.9),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // ===== زر العملة + الأسعار =====
              Padding(
                padding: EdgeInsets.symmetric(horizontal: R.s(context, 16)),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: _openCurrencyPicker,
                        child: GlassCard(
                          ornament: false,
                          child: Row(
                            children: [
                              Icon(Icons.attach_money_rounded,
                                  color: AppColors.gold,
                                  size: R.s(context, 16)),
                              SizedBox(width: R.s(context, 6)),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${_currency.code} ${_currency.symbol}',
                                      style: TextStyle(
                                        fontSize: R.f(context, 12),
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.softGold,
                                      ),
                                    ),
                                    Text(
                                      appState.isArabic
                                          ? _currency.nameAr
                                          : _currency.nameEn,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: R.f(context, 9.5),
                                        color: AppColors.cream
                                            .withValues(alpha: 0.7),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Icon(Icons.unfold_more_rounded,
                                  color: AppColors.softGold
                                      .withValues(alpha: 0.7),
                                  size: R.s(context, 18)),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: R.s(context, 6)),

              // ===== حالة الأسعار =====
              Padding(
                padding: EdgeInsets.symmetric(horizontal: R.s(context, 16)),
                child: _PriceStatus(
                  loading: _loadingPrices,
                  failed: _priceFetchFailed,
                  onRetry: _loadPrices,
                  code: _currencyCode,
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
                  children: [
                    _MoneyTab(currencyCode: _currencyCode),
                    _GoldTab(currencyCode: _currencyCode),
                    _SilverTab(currencyCode: _currencyCode),
                    const _CropsTab(),
                    const _LivestockTab(),
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

// ==================== اختيار العملة ====================
class _CurrencyPickerSheet extends StatefulWidget {
  const _CurrencyPickerSheet({
    required this.selected,
    required this.onSelect,
  });

  final String selected;
  final ValueChanged<String> onSelect;

  @override
  State<_CurrencyPickerSheet> createState() => _CurrencyPickerSheetState();
}

class _CurrencyPickerSheetState extends State<_CurrencyPickerSheet> {
  final _search = TextEditingController();
  List<Currency> _filtered = kCurrencies;

  @override
  void initState() {
    super.initState();
    _search.addListener(_filter);
  }

  void _filter() {
    final q = _search.text.trim().toLowerCase();
    setState(() {
      if (q.isEmpty) {
        _filtered = kCurrencies;
      } else {
        _filtered = kCurrencies.where((c) {
          return c.code.toLowerCase().contains(q) ||
              c.nameEn.toLowerCase().contains(q) ||
              c.nameAr.contains(q);
        }).toList();
      }
    });
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.deepGreen,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.all(R.s(context, 14)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.gold.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          SizedBox(height: R.s(context, 10)),
          Text(
            appState.tr('zakatChooseCurrency'),
            style: TextStyle(
              fontSize: R.f(context, 14),
              fontWeight: FontWeight.w700,
              color: AppColors.softGold,
            ),
          ),
          SizedBox(height: R.s(context, 10)),
          TextField(
            controller: _search,
            style: TextStyle(
              color: AppColors.cream,
              fontSize: R.f(context, 13),
            ),
            decoration: InputDecoration(
              hintText: appState.tr('zakatSearchCurrency'),
              hintStyle: TextStyle(
                color: AppColors.cream.withValues(alpha: 0.5),
              ),
              prefixIcon: const Icon(Icons.search_rounded,
                  color: AppColors.gold),
              filled: true,
              fillColor: Colors.black.withValues(alpha: 0.25),
              contentPadding:
                  EdgeInsets.symmetric(vertical: R.s(context, 10)),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                    color: AppColors.gold.withValues(alpha: 0.4)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.gold),
              ),
            ),
          ),
          SizedBox(height: R.s(context, 8)),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.5,
            child: ListView.builder(
              itemCount: _filtered.length,
              itemBuilder: (context, i) {
                final c = _filtered[i];
                final isSel = c.code == widget.selected;
                return Padding(
                  padding: EdgeInsets.only(bottom: R.s(context, 4)),
                  child: GestureDetector(
                    onTap: () => widget.onSelect(c.code),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: R.s(context, 10),
                        vertical: R.s(context, 8),
                      ),
                      decoration: BoxDecoration(
                        color: isSel
                            ? AppColors.gold.withValues(alpha: 0.2)
                            : Colors.black.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSel
                              ? AppColors.gold
                              : AppColors.gold.withValues(alpha: 0.25),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: R.s(context, 42),
                            alignment: Alignment.center,
                            child: Text(
                              c.code,
                              style: TextStyle(
                                fontSize: R.f(context, 12),
                                fontWeight: FontWeight.w800,
                                color: isSel
                                    ? AppColors.gold
                                    : AppColors.cream,
                              ),
                            ),
                          ),
                          SizedBox(width: R.s(context, 6)),
                          Expanded(
                            child: Text(
                              appState.isArabic ? c.nameAr : c.nameEn,
                              style: TextStyle(
                                fontSize: R.f(context, 12),
                                color: isSel
                                    ? AppColors.gold
                                    : AppColors.cream,
                              ),
                            ),
                          ),
                          Text(
                            c.symbol,
                            style: TextStyle(
                              fontSize: R.f(context, 12),
                              color: AppColors.softGold
                                  .withValues(alpha: 0.8),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
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
    required this.code,
  });

  final bool loading;
  final bool failed;
  final VoidCallback onRetry;
  final String code;

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
              fontSize: R.f(context, 10),
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
                color: AppColors.gold, size: R.s(context, 13)),
            SizedBox(width: R.s(context, 4)),
            Text(
              appState.tr('zakatPriceFailed'),
              style: TextStyle(
                fontSize: R.f(context, 10),
                color: AppColors.gold,
              ),
            ),
          ],
        ),
      );
    }
    final goldPerG = MetalsService.goldPerGram(code);
    final silverPerG = MetalsService.silverPerGram(code);
    final sym = currencyByCode(code)?.symbol ?? code;
    return Text(
      '${appState.tr('zakatLivePrices')} · 1g Au = ${goldPerG.toStringAsFixed(2)} $sym · 1g Ag = ${silverPerG.toStringAsFixed(2)} $sym',
      textAlign: TextAlign.center,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        fontSize: R.f(context, 9),
        color: AppColors.cream.withValues(alpha: 0.6),
      ),
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
          borderSide: const BorderSide(color: AppColors.gold, width: 1.5),
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
    required this.unit,
  });

  final String title;
  final List<MapEntry<String, String>> rows;
  final double due;
  final String dueLabel;
  final bool belowNisab;
  final String unit;

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
                    '$unit ${due.toStringAsFixed(2)}',
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
  const _MoneyTab({required this.currencyCode});

  final String currencyCode;

  @override
  State<_MoneyTab> createState() => _MoneyTabState();
}

class _MoneyTabState extends State<_MoneyTab> {
  final _amount = TextEditingController();

  double get _amountV => double.tryParse(_amount.text) ?? 0;
  double get _goldPerG => MetalsService.goldPerGram(widget.currencyCode);
  double get _nisab => 85 * _goldPerG;
  bool get _reached => _amountV >= _nisab && _nisab > 0;
  double get _due => _reached ? _amountV * 0.025 : 0;
  String get _symbol =>
      currencyByCode(widget.currencyCode)?.symbol ?? widget.currencyCode;

  @override
  void dispose() {
    _amount.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.all(R.s(context, 16)),
      children: [
        _NumField(
          controller: _amount,
          label: appState.tr('zakatMoneyAmount'),
          suffix: _symbol,
          onChanged: (_) => setState(() {}),
        ),
        SizedBox(height: R.s(context, 6)),
        Text(
          '${appState.tr('zakatMoneyNisabHint')} · ${_goldPerG.toStringAsFixed(2)} $ _symbol/g',
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
              '$_symbol ${_amountV.toStringAsFixed(2)}',
            ),
            MapEntry(
              appState.tr('zakatNisab'),
              '$_symbol ${_nisab.toStringAsFixed(2)}',
            ),
          ],
          due: _due,
          dueLabel: appState.tr('zakatDueAmount'),
          belowNisab: !_reached,
          unit: _symbol,
        ),
      ],
    );
  }
}

// ==================== تبويب: الذهب ====================
class _GoldTab extends StatefulWidget {
  const _GoldTab({required this.currencyCode});

  final String currencyCode;

  @override
  State<_GoldTab> createState() => _GoldTabState();
}

class _GoldTabState extends State<_GoldTab> {
  final _weight = TextEditingController();
  int _karat = 24;

  double get _weightV => double.tryParse(_weight.text) ?? 0;
  double get _pricePerG => MetalsService.goldPerGram(widget.currencyCode);
  double get _pureWeight => _weightV * (_karat / 24.0);
  double get _value => _weightV * _pricePerG * (_karat / 24.0);
  bool get _reached => _pureWeight >= 85;
  double get _due => _reached ? _value * 0.025 : 0;
  String get _symbol =>
      currencyByCode(widget.currencyCode)?.symbol ?? widget.currencyCode;

  @override
  void dispose() {
    _weight.dispose();
    super.dispose();
  }

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
                  padding:
                      EdgeInsets.symmetric(horizontal: R.s(context, 2)),
                  child: GestureDetector(
                    onTap: () => setState(() => _karat = k),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding:
                          EdgeInsets.symmetric(vertical: R.s(context, 8)),
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
        SizedBox(height: R.s(context, 6)),
        Text(
          '${appState.tr('zakatLiveGold')} ${_pricePerG.toStringAsFixed(2)} $_symbol/g',
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
              appState.tr('zakatPureWeight'),
              '${_pureWeight.toStringAsFixed(2)} g',
            ),
            MapEntry(
              appState.tr('zakatNisab'),
              '85.00 g',
            ),
            MapEntry(
              appState.tr('zakatGoldValue'),
              '$_symbol ${_value.toStringAsFixed(2)}',
            ),
          ],
          due: _due,
          dueLabel: appState.tr('zakatDueAmount'),
          belowNisab: !_reached,
          unit: _symbol,
        ),
      ],
    );
  }
}

// ==================== تبويب: الفضة ====================
class _SilverTab extends StatefulWidget {
  const _SilverTab({required this.currencyCode});

  final String currencyCode;

  @override
  State<_SilverTab> createState() => _SilverTabState();
}

class _SilverTabState extends State<_SilverTab> {
  final _weight = TextEditingController();

  double get _weightV => double.tryParse(_weight.text) ?? 0;
  double get _pricePerG => MetalsService.silverPerGram(widget.currencyCode);
  double get _value => _weightV * _pricePerG;
  bool get _reached => _weightV >= 595;
  double get _due => _reached ? _value * 0.025 : 0;
  String get _symbol =>
      currencyByCode(widget.currencyCode)?.symbol ?? widget.currencyCode;

  @override
  void dispose() {
    _weight.dispose();
    super.dispose();
  }

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
        SizedBox(height: R.s(context, 6)),
        Text(
          '${appState.tr('zakatLiveSilver')} ${_pricePerG.toStringAsFixed(3)} $_symbol/g',
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
              appState.tr('zakatNisab'),
              '595.00 g',
            ),
            MapEntry(
              appState.tr('zakatSilverValue'),
              '$_symbol ${_value.toStringAsFixed(2)}',
            ),
          ],
          due: _due,
          dueLabel: appState.tr('zakatDueAmount'),
          belowNisab: !_reached,
          unit: _symbol,
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

  double get _weightV => double.tryParse(_weight.text) ?? 0;
  bool get _reached => _weightV >= 653;
  double get _due => _reached ? _weightV * (_rainFed ? 0.10 : 0.05) : 0;

  @override
  void dispose() {
    _weight.dispose();
    super.dispose();
  }

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
            MapEntry(appState.tr('zakatNisab'), '653.00 kg'),
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
          unit: 'kg',
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
        return '${_n ~/ 100} ${appState.tr('zakatSheep')}';
      case 'cow':
        if (_n < 30) return appState.tr('zakatNoZakat');
        if (_n <= 39) {
          return '1 ${appState.tr('zakatCalf')} (${appState.tr('zakatTabii')})';
        }
        if (_n <= 59) {
          return '1 ${appState.tr('zakatCalf')} (${appState.tr('zakatMusinnah')})';
        }
        if (_n <= 69) return '2 ${appState.tr('zakatCalf')}';
        return '${2 + (_n - 60) ~/ 30} ${appState.tr('zakatCalf')}';
      case 'camel':
        if (_n < 5) return appState.tr('zakatNoZakat');
        if (_n <= 24) return '1 ${appState.tr('zakatSheep')}';
        if (_n <= 35) return '1 ${appState.tr('zakatBintMakhad')}';
        if (_n <= 45) return '1 ${appState.tr('zakatBintLabun')}';
        if (_n <= 60) return '1 ${appState.tr('zakatHiqqah')}';
        if (_n <= 75) return '1 ${appState.tr('zakatJadhah')}';
        if (_n <= 90) return '2 ${appState.tr('zakatBintLabun')}';
        if (_n <= 120) return '2 ${appState.tr('zakatHiqqah')}';
        return '${_n ~/ 50} ${appState.tr('zakatHiqqah')}';
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
