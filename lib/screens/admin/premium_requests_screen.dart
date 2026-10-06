import 'package:flutter/material.dart';

import '../../core/app_state.dart';
import '../../core/responsive.dart';
import '../../core/theme.dart';
import '../../models/premium_request.dart';
import '../../services/community_notification_service.dart';
import '../../services/premium_service.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/themed_background.dart';

// ============ ترجمات ============
const Map<String, Map<String, String>> _prTr = {
  'ar': {
    'title': 'طلبات Premium',
    'empty': 'لا توجد طلبات حالياً',
    'plan': 'الخطة',
    'amount': 'المبلغ',
    'paypal': 'حساب PayPal',
    'approve': 'موافقة',
    'reject': 'رفض',
    'approved': 'تمت الموافقة ✓',
    'rejected': 'تم الرفض',
    'error': 'خطأ',
    'user': 'مستخدم',
    'monthly': 'شهري',
    'quarterly': '3 أشهر',
    'yearly': 'سنوي',
    'days30': '30 يوم',
    'days90': '90 يوم',
    'days365': '365 يوم',
  },
  'en': {
    'title': 'Premium Requests',
    'empty': 'No pending requests',
    'plan': 'Plan',
    'amount': 'Amount',
    'paypal': 'PayPal account',
    'approve': 'Approve',
    'reject': 'Reject',
    'approved': 'Approved ✓',
    'rejected': 'Rejected',
    'error': 'Error',
    'user': 'User',
    'monthly': 'Monthly',
    'quarterly': '3 Months',
    'yearly': 'Yearly',
    'days30': '30 days',
    'days90': '90 days',
    'days365': '365 days',
  },
  'fr': {
    'title': 'Demandes Premium',
    'empty': 'Aucune demande',
    'plan': 'Forfait',
    'amount': 'Montant',
    'paypal': 'Compte PayPal',
    'approve': 'Approuver',
    'reject': 'Refuser',
    'approved': 'Approuvée ✓',
    'rejected': 'Refusée',
    'error': 'Erreur',
    'user': 'Utilisateur',
    'monthly': 'Mensuel',
    'quarterly': '3 mois',
    'yearly': 'Annuel',
    'days30': '30 jours',
    'days90': '90 jours',
    'days365': '365 jours',
  },
  'ur': {
    'title': 'پریمیم درخواستیں',
    'empty': 'کوئی درخواست نہیں',
    'plan': 'پلان',
    'amount': 'رقم',
    'paypal': 'PayPal اکاؤنٹ',
    'approve': 'منظور',
    'reject': 'مسترد',
    'approved': 'منظور ✓',
    'rejected': 'مسترد',
    'error': 'خرابی',
    'user': 'صارف',
    'monthly': 'ماہانہ',
    'quarterly': '3 ماہ',
    'yearly': 'سالانہ',
    'days30': '30 دن',
    'days90': '90 دن',
    'days365': '365 دن',
  },
  'ne': {
    'title': 'प्रिमियम अनुरोधहरू',
    'empty': 'कुनै अनुरोध छैन',
    'plan': 'योजना',
    'amount': 'रकम',
    'paypal': 'PayPal खाता',
    'approve': 'स्वीकार',
    'reject': 'अस्वीकार',
    'approved': 'स्वीकृत ✓',
    'rejected': 'अस्वीकृत',
    'error': 'त्रुटि',
    'user': 'प्रयोगकर्ता',
    'monthly': 'मासिक',
    'quarterly': '3 महिना',
    'yearly': 'वार्षिक',
    'days30': '30 दिन',
    'days90': '90 दिन',
    'days365': '365 दिन',
  },
  'id': {
    'title': 'Permintaan Premium',
    'empty': 'Tidak ada permintaan',
    'plan': 'Paket',
    'amount': 'Jumlah',
    'paypal': 'Akun PayPal',
    'approve': 'Setujui',
    'reject': 'Tolak',
    'approved': 'Disetujui ✓',
    'rejected': 'Ditolak',
    'error': 'Kesalahan',
    'user': 'Pengguna',
    'monthly': 'Bulanan',
    'quarterly': '3 Bulan',
    'yearly': 'Tahunan',
    'days30': '30 hari',
    'days90': '90 hari',
    'days365': '365 hari',
  },
  'ms': {
    'title': 'Permintaan Premium',
    'empty': 'Tiada permintaan',
    'plan': 'Pelan',
    'amount': 'Jumlah',
    'paypal': 'Akaun PayPal',
    'approve': 'Luluskan',
    'reject': 'Tolak',
    'approved': 'Diluluskan ✓',
    'rejected': 'Ditolak',
    'error': 'Ralat',
    'user': 'Pengguna',
    'monthly': 'Bulanan',
    'quarterly': '3 Bulan',
    'yearly': 'Tahunan',
    'days30': '30 hari',
    'days90': '90 hari',
    'days365': '365 hari',
  },
};

String _pr(String key) {
  final m = _prTr[appState.languageCode] ?? _prTr['ar']!;
  return m[key] ?? key;
}

class PremiumRequestsScreen extends StatefulWidget {
  const PremiumRequestsScreen({super.key});

  @override
  State<PremiumRequestsScreen> createState() => _PremiumRequestsScreenState();
}

class _PremiumRequestsScreenState extends State<PremiumRequestsScreen> {
  final CommunityNotificationService _notif = CommunityNotificationService();
  String? _busyUid;

  Future<void> _approve(PremiumRequest req) async {
    setState(() => _busyUid = req.uid);
    try {
      await premiumService.approveRequest(req);
      await _notif.sendFromAdmin(
        toUid: req.uid,
        type: 'premium_approved',
      );
      if (mounted) _snack(_pr('approved'));
    } catch (e) {
      if (mounted) _snack('${_pr('error')}: $e', error: true);
    } finally {
      if (mounted) setState(() => _busyUid = null);
    }
  }

  Future<void> _reject(PremiumRequest req) async {
    setState(() => _busyUid = req.uid);
    try {
      await premiumService.rejectRequest(req);
      await _notif.sendFromAdmin(
        toUid: req.uid,
        type: 'premium_rejected',
      );
      if (mounted) _snack(_pr('rejected'));
    } catch (e) {
      if (mounted) _snack('${_pr('error')}: $e', error: true);
    } finally {
      if (mounted) setState(() => _busyUid = null);
    }
  }

  void _snack(String msg, {bool error = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor:
              error ? const Color(0xFF5C1F1F) : AppColors.deepGreen,
          content: Text(
            msg,
            style: const TextStyle(color: AppColors.cream),
          ),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: appState,
      builder: (context, _) {
        return Directionality(
          textDirection: appState.direction,
          child: Scaffold(
            body: ThemedBackground(
              child: SafeArea(
                child: Column(
                  children: [
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
                            onPressed: () =>
                                Navigator.of(context).maybePop(),
                            color: AppColors.softGold,
                            iconSize: R.s(context, 22),
                            icon: const Icon(Icons.arrow_back_rounded),
                          ),
                          const Spacer(),
                          Text(
                            _pr('title'),
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
                    SizedBox(height: R.s(context, 6)),
                    Expanded(
                      child: StreamBuilder<List<PremiumRequest>>(
                        stream: premiumService.pendingRequestsStream(),
                        builder: (context, snap) {
                          if (snap.connectionState ==
                                  ConnectionState.waiting &&
                              !snap.hasData) {
                            return const Center(
                              child: CircularProgressIndicator(
                                  color: AppColors.gold),
                            );
                          }
                          final requests = snap.data ?? [];
                          if (requests.isEmpty) {
                            return Center(
                              child: Padding(
                                padding: EdgeInsets.all(R.s(context, 20)),
                                child: Text(
                                  _pr('empty'),
                                  style: TextStyle(
                                    fontSize: R.f(context, 14),
                                    color: AppColors.cream
                                        .withValues(alpha: 0.7),
                                  ),
                                ),
                              ),
                            );
                          }
                          return ListView.builder(
                            padding: EdgeInsets.all(R.s(context, 14)),
                            itemCount: requests.length,
                            itemBuilder: (context, i) => Padding(
                              padding: EdgeInsets.only(
                                  bottom: R.s(context, 10)),
                              child: _RequestCard(
                                request: requests[i],
                                busy: _busyUid == requests[i].uid,
                                onApprove: () => _approve(requests[i]),
                                onReject: () => _reject(requests[i]),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _RequestCard extends StatelessWidget {
  final PremiumRequest request;
  final bool busy;
  final VoidCallback onApprove;
  final VoidCallback onReject;

  const _RequestCard({
    required this.request,
    required this.busy,
    required this.onApprove,
    required this.onReject,
  });

  String _planLabel() {
    switch (request.plan) {
      case 'monthly':
        return _pr('monthly');
      case 'quarterly':
        return _pr('quarterly');
      case 'yearly':
        return _pr('yearly');
      default:
        return request.plan;
    }
  }

  String _daysLabel() {
    final d = request.daysForPlan;
    if (d == 30) return _pr('days30');
    if (d == 90) return _pr('days90');
    if (d == 365) return _pr('days365');
    return '$d ${appState.isArabic ? 'يوم' : 'days'}';
  }

  @override
  Widget build(BuildContext context) {
    final date = request.requestedAt;
    return GlassCard(
      ornament: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header: name + date
          Row(
            children: [
              Icon(
                Icons.workspace_premium_rounded,
                color: AppColors.gold,
                size: R.s(context, 18),
              ),
              SizedBox(width: R.s(context, 6)),
              Expanded(
                child: Text(
                  request.name.isEmpty ? _pr('user') : request.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: R.f(context, 14),
                    fontWeight: FontWeight.w700,
                    color: AppColors.softGold,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: R.s(context, 3)),
          Text(
            request.email,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: R.f(context, 10.5),
              color: AppColors.cream.withValues(alpha: 0.7),
            ),
          ),
          SizedBox(height: R.s(context, 3)),
          Text(
            '${date.day}/${date.month}/${date.year}',
            style: TextStyle(
              fontSize: R.f(context, 10.5),
              color: AppColors.gold.withValues(alpha: 0.8),
            ),
          ),
          SizedBox(height: R.s(context, 12)),

          // Info: plan, amount, paypal
          Container(
            padding: EdgeInsets.all(R.s(context, 10)),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(R.s(context, 12)),
            ),
            child: Column(
              children: [
                _infoRow(context, _pr('plan'),
                    '${_planLabel()} · ${_daysLabel()}'),
                SizedBox(height: R.s(context, 4)),
                _infoRow(context, _pr('amount'),
                    '\$${request.amount.toInt()}'),
                SizedBox(height: R.s(context, 4)),
                _infoRow(context, _pr('paypal'), request.paypalAccount),
              ],
            ),
          ),

          SizedBox(height: R.s(context, 14)),

          if (busy)
            const Center(
              child: SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.gold,
                ),
              ),
            )
          else
            Row(
              children: [
                Expanded(
                  child: _ActionBtn(
                    icon: Icons.check_rounded,
                    label: _pr('approve'),
                    color: AppColors.gold,
                    onTap: onApprove,
                  ),
                ),
                SizedBox(width: R.s(context, 6)),
                Expanded(
                  child: _ActionBtn(
                    icon: Icons.close_rounded,
                    label: _pr('reject'),
                    color: const Color(0xFFD32F2F),
                    onTap: onReject,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _infoRow(BuildContext context, String label, String value) {
    return Row(
      children: [
        Text(
          '$label:',
          style: TextStyle(
            color: AppColors.cream.withValues(alpha: 0.6),
            fontSize: R.f(context, 11.5),
          ),
        ),
        SizedBox(width: R.s(context, 6)),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.end,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: AppColors.softGold,
              fontSize: R.f(context, 11.5),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

class _ActionBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionBtn({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: R.s(context, 8),
          vertical: R.s(context, 12),
        ),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color, width: 1.2),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: R.s(context, 18)),
            SizedBox(width: R.s(context, 4)),
            Text(
              label,
              style: TextStyle(
                fontSize: R.f(context, 12),
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
