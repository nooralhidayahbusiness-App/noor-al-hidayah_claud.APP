import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../core/app_state.dart';
import '../core/responsive.dart';
import '../core/theme.dart';
import '../models/premium_request.dart';
import '../services/premium_service.dart';
import '../widgets/auth_widgets.dart';
import '../widgets/glass_card.dart';
import '../widgets/themed_background.dart';

const Map<String, Map<String, String>> _chkTr = {
  'ar': {
    'title': 'تأكيد الدفع',
    'step1': '1) ادفع عبر PayPal',
    'step1Desc': 'سيتم فتح PayPal لدفع {amount}\$. بعد الدفع، ارجع هنا وأكمل.',
    'payNow': 'افتح PayPal',
    'paid': 'تم الدفع ✓',
    'confirmPaid': 'لقد أكملت الدفع في PayPal',
    'step2': '2) أكمل بياناتك',
    'step2Desc': 'املأ البيانات التالية للمطابقة مع حساب PayPal',
    'name': 'الاسم الكامل',
    'email': 'البريد الإلكتروني',
    'paypal': 'حساب PayPal (@username أو email)',
    'confirm': 'إرسال الطلب',
    'sending': 'جارٍ الإرسال...',
    'errName': 'أدخل اسمك',
    'errEmail': 'أدخل بريدك',
    'errPaypal': 'أدخل حساب PayPal',
    'errPay': 'يجب تأكيد الدفع أولاً',
    'success': 'تم إرسال طلبك ✅',
    'successDesc': 'سيتم التفعيل خلال 24 ساعة',
    'summary': 'ملخص الطلب',
    'plan': 'الخطة',
    'amount': 'المبلغ',
    'note': 'ملاحظة: احفظ إشعار الدفع حتى يتم التحقق',
  },
  'en': {
    'title': 'Confirm Payment',
    'step1': '1) Pay via PayPal',
    'step1Desc': 'PayPal will open to pay {amount}\$. After paying, come back here.',
    'payNow': 'Open PayPal',
    'paid': 'Paid ✓',
    'confirmPaid': 'I have completed payment on PayPal',
    'step2': '2) Complete your info',
    'step2Desc': 'Fill in the following to match with your PayPal',
    'name': 'Full Name',
    'email': 'Email',
    'paypal': 'PayPal account (@username or email)',
    'confirm': 'Submit Request',
    'sending': 'Sending...',
    'errName': 'Enter your name',
    'errEmail': 'Enter your email',
    'errPaypal': 'Enter your PayPal',
    'errPay': 'You must confirm payment first',
    'success': 'Request sent ✅',
    'successDesc': 'Will be activated within 24h',
    'summary': 'Request Summary',
    'plan': 'Plan',
    'amount': 'Amount',
    'note': 'Note: Keep the payment receipt for verification',
  },
  'fr': {
    'title': 'Confirmer le paiement',
    'step1': '1) Payez via PayPal',
    'step1Desc': 'PayPal s\'ouvrira pour payer {amount}\$.',
    'payNow': 'Ouvrir PayPal',
    'paid': 'Payé ✓',
    'confirmPaid': 'J\'ai effectué le paiement sur PayPal',
    'step2': '2) Complétez vos infos',
    'step2Desc': 'Remplissez les informations suivantes',
    'name': 'Nom complet',
    'email': 'Email',
    'paypal': 'Compte PayPal (@username ou email)',
    'confirm': 'Envoyer',
    'sending': 'Envoi...',
    'errName': 'Entrez votre nom',
    'errEmail': 'Entrez votre email',
    'errPaypal': 'Entrez votre PayPal',
    'errPay': 'Vous devez confirmer le paiement',
    'success': 'Demande envoyée ✅',
    'successDesc': 'Activée sous 24h',
    'summary': 'Résumé',
    'plan': 'Forfait',
    'amount': 'Montant',
    'note': 'Note : gardez le reçu pour vérification',
  },
  'ur': {
    'title': 'ادائیگی کی تصدیق',
    'step1': '1) PayPal سے ادا کریں',
    'step1Desc': 'PayPal کھلے گا {amount}\$ ادا کرنے کے لیے۔',
    'payNow': 'PayPal کھولیں',
    'paid': 'ادا ہو گیا ✓',
    'confirmPaid': 'میں نے PayPal پر ادائیگی مکمل کر لی',
    'step2': '2) اپنی معلومات مکمل کریں',
    'step2Desc': 'درج ذیل معلومات بھریں',
    'name': 'پورا نام',
    'email': 'ای میل',
    'paypal': 'PayPal اکاؤنٹ',
    'confirm': 'درخواست بھیجیں',
    'sending': 'بھیجی جا رہی ہے...',
    'errName': 'نام درج کریں',
    'errEmail': 'ای میل درج کریں',
    'errPaypal': 'PayPal درج کریں',
    'errPay': 'پہلے ادائیگی کی تصدیق کریں',
    'success': 'درخواست بھیجی گئی ✅',
    'successDesc': '24 گھنٹوں میں فعال',
    'summary': 'خلاصہ',
    'plan': 'پلان',
    'amount': 'رقم',
    'note': 'نوٹ: ادائیگی کی رسید محفوظ کریں',
  },
  'ne': {
    'title': 'भुक्तानी पुष्टि',
    'step1': '1) PayPal बाट तिर्नुहोस्',
    'step1Desc': 'PayPal खुल्नेछ {amount}\$ तिर्न।',
    'payNow': 'PayPal खोल्नुहोस्',
    'paid': 'तिरियो ✓',
    'confirmPaid': 'मैले PayPal मा भुक्तानी गरिसकेँ',
    'step2': '2) जानकारी भर्नुहोस्',
    'step2Desc': 'तलको जानकारी भर्नुहोस्',
    'name': 'पूरा नाम',
    'email': 'इमेल',
    'paypal': 'PayPal खाता',
    'confirm': 'अनुरोध पठाउनुहोस्',
    'sending': 'पठाउँदै...',
    'errName': 'नाम प्रविष्ट गर्नुहोस्',
    'errEmail': 'इमेल प्रविष्ट गर्नुहोस्',
    'errPaypal': 'PayPal प्रविष्ट गर्नुहोस्',
    'errPay': 'पहिले भुक्तानी पुष्टि गर्नुहोस्',
    'success': 'अनुरोध पठाइयो ✅',
    'successDesc': '24 घण्टामा सक्रिय',
    'summary': 'सारांश',
    'plan': 'योजना',
    'amount': 'रकम',
    'note': 'नोट: भुक्तानी रसिद राख्नुहोस्',
  },
  'id': {
    'title': 'Konfirmasi Pembayaran',
    'step1': '1) Bayar via PayPal',
    'step1Desc': 'PayPal akan terbuka untuk {amount}\$.',
    'payNow': 'Buka PayPal',
    'paid': 'Dibayar ✓',
    'confirmPaid': 'Saya telah menyelesaikan pembayaran di PayPal',
    'step2': '2) Lengkapi info Anda',
    'step2Desc': 'Isi informasi berikut',
    'name': 'Nama Lengkap',
    'email': 'Email',
    'paypal': 'Akun PayPal',
    'confirm': 'Kirim Permintaan',
    'sending': 'Mengirim...',
    'errName': 'Masukkan nama',
    'errEmail': 'Masukkan email',
    'errPaypal': 'Masukkan PayPal',
    'errPay': 'Konfirmasi pembayaran dulu',
    'success': 'Permintaan terkirim ✅',
    'successDesc': 'Aktif dalam 24 jam',
    'summary': 'Ringkasan',
    'plan': 'Paket',
    'amount': 'Jumlah',
    'note': 'Catatan: simpan bukti pembayaran',
  },
  'ms': {
    'title': 'Sahkan Pembayaran',
    'step1': '1) Bayar via PayPal',
    'step1Desc': 'PayPal akan dibuka untuk {amount}\$.',
    'payNow': 'Buka PayPal',
    'paid': 'Dibayar ✓',
    'confirmPaid': 'Saya telah selesaikan pembayaran di PayPal',
    'step2': '2) Lengkapkan maklumat',
    'step2Desc': 'Isi maklumat berikut',
    'name': 'Nama Penuh',
    'email': 'E-mel',
    'paypal': 'Akaun PayPal',
    'confirm': 'Hantar Permintaan',
    'sending': 'Menghantar...',
    'errName': 'Masukkan nama',
    'errEmail': 'Masukkan e-mel',
    'errPaypal': 'Masukkan PayPal',
    'errPay': 'Sahkan pembayaran dahulu',
    'success': 'Permintaan dihantar ✅',
    'successDesc': 'Diaktifkan dalam 24 jam',
    'summary': 'Ringkasan',
    'plan': 'Pelan',
    'amount': 'Jumlah',
    'note': 'Nota: simpan resit pembayaran',
  },
};

String _ck(String key) {
  final m = _chkTr[appState.languageCode] ?? _chkTr['ar']!;
  return m[key] ?? key;
}

class PremiumCheckoutScreen extends StatefulWidget {
  final PremiumPlan plan;

  const PremiumCheckoutScreen({super.key, required this.plan});

  @override
  State<PremiumCheckoutScreen> createState() => _PremiumCheckoutScreenState();
}

class _PremiumCheckoutScreenState extends State<PremiumCheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _paypalCtrl = TextEditingController();

  bool _openedPaypal = false; // فتح الرابط
  bool _confirmedPaid = false; // ✅ أكّد بنفسه
  bool _sending = false;

  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser;
    _emailCtrl.text = user?.email ?? '';
    _nameCtrl.text = user?.displayName ?? '';
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _paypalCtrl.dispose();
    super.dispose();
  }

  Future<void> _openPaypal() async {
    final url = PremiumService.paypalUrlFor(widget.plan.price);
    final uri = Uri.parse(url);
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
      // ⚠️ لا نعتبره مدفوعاً — فقط "فتح"
      if (mounted) setState(() => _openedPaypal = true);
    } catch (_) {}
  }

  Future<void> _submit() async {
    if (!_confirmedPaid) {
      showAuthMessage(context, _ck('errPay'), error: true);
      return;
    }
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _sending = true);
    try {
      await premiumService.submitRequest(
        name: _nameCtrl.text.trim(),
        email: _emailCtrl.text.trim(),
        paypalAccount: _paypalCtrl.text.trim(),
        planId: widget.plan.id,
        amount: widget.plan.price,
      );

      if (!mounted) return;
      _showSuccessDialog();
    } catch (e) {
      if (mounted) showAuthMessage(context, '$e', error: true);
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.deepGreen,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: AppColors.gold.withValues(alpha: 0.5)),
        ),
        title: Column(
          children: [
            Icon(Icons.check_circle_rounded,
                color: AppColors.gold, size: R.s(context, 54)),
            SizedBox(height: R.s(context, 10)),
            Text(
              _ck('success'),
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.softGold),
            ),
          ],
        ),
        content: Text(
          _ck('successDesc'),
          textAlign: TextAlign.center,
          style: TextStyle(color: AppColors.cream.withValues(alpha: 0.8)),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              Navigator.of(context).pop();
            },
            child: const Text('OK',
                style: TextStyle(
                    color: AppColors.gold, fontWeight: FontWeight.bold)),
          ),
        ],
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
                    _buildAppBar(context),
                    Expanded(
                      child: ListView(
                        padding: EdgeInsets.all(R.s(context, 18)),
                        children: [
                          _buildSummary(context),
                          SizedBox(height: R.s(context, 20)),
                          _buildStep1(context),
                          SizedBox(height: R.s(context, 20)),
                          _buildStep2(context),
                          SizedBox(height: R.s(context, 20)),
                          _buildNote(context),
                          SizedBox(height: R.s(context, 20)),
                          _buildSubmitButton(context),
                        ],
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

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.green,
      elevation: 0,
      iconTheme: const IconThemeData(color: AppColors.cream),
      centerTitle: true,
      title: Text(
        _ck('title'),
        style: TextStyle(
          color: AppColors.softGold,
          fontSize: R.f(context, 16),
          fontWeight: FontWeight.bold,
        ),
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(
          height: 1,
          color: AppColors.gold.withValues(alpha: 0.3),
        ),
      ),
    );
  }

  Widget _buildSummary(BuildContext context) {
    return GlassCard(
      ornament: false,
      child: Column(
        children: [
          Row(
            children: [
              Icon(Icons.receipt_long_rounded,
                  color: AppColors.gold, size: R.s(context, 20)),
              SizedBox(width: R.s(context, 8)),
              Text(
                _ck('summary'),
                style: TextStyle(
                  color: AppColors.softGold,
                  fontSize: R.f(context, 14),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: R.s(context, 12)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(_ck('plan'),
                  style: TextStyle(
                      color: AppColors.cream.withValues(alpha: 0.7),
                      fontSize: R.f(context, 13))),
              Text(
                appState.isArabic
                    ? widget.plan.labelAr
                    : widget.plan.labelEn,
                style: TextStyle(
                    color: AppColors.softGold,
                    fontSize: R.f(context, 13),
                    fontWeight: FontWeight.bold),
              ),
            ],
          ),
          SizedBox(height: R.s(context, 6)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(_ck('amount'),
                  style: TextStyle(
                      color: AppColors.cream.withValues(alpha: 0.7),
                      fontSize: R.f(context, 13))),
              Text(
                '\$${widget.plan.price.toInt()}',
                style: TextStyle(
                    color: AppColors.gold,
                    fontSize: R.f(context, 18),
                    fontWeight: FontWeight.w900),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStep1(BuildContext context) {
    return GlassCard(
      ornament: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                _confirmedPaid
                    ? Icons.check_circle_rounded
                    : Icons.payment_rounded,
                color: _confirmedPaid
                    ? const Color(0xFF4CAF50)
                    : AppColors.gold,
                size: R.s(context, 20),
              ),
              SizedBox(width: R.s(context, 8)),
              Text(
                _ck('step1'),
                style: TextStyle(
                  color: AppColors.softGold,
                  fontSize: R.f(context, 14),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: R.s(context, 10)),
          Text(
            _ck('step1Desc').replaceAll(
              '{amount}',
              '${widget.plan.price.toInt()}',
            ),
            style: TextStyle(
              color: AppColors.cream.withValues(alpha: 0.75),
              fontSize: R.f(context, 12),
              height: 1.6,
            ),
          ),
          SizedBox(height: R.s(context, 14)),

          // زر فتح PayPal
          SizedBox(
            width: double.infinity,
            height: R.s(context, 50),
            child: ElevatedButton.icon(
              onPressed: _openPaypal,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0070BA),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(R.s(context, 14)),
                ),
              ),
              icon: Icon(Icons.open_in_new_rounded, size: R.s(context, 18)),
              label: Text(
                _openedPaypal ? _ck('paid') : _ck('payNow'),
                style: TextStyle(
                  fontSize: R.f(context, 14),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          // ✅ checkbox التأكيد اليدوي
          if (_openedPaypal) ...[
            SizedBox(height: R.s(context, 12)),
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: R.s(context, 8),
                vertical: R.s(context, 4),
              ),
              decoration: BoxDecoration(
                color: _confirmedPaid
                    ? const Color(0xFF4CAF50).withValues(alpha: 0.12)
                    : Colors.black.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(R.s(context, 12)),
                border: Border.all(
                  color: _confirmedPaid
                      ? const Color(0xFF4CAF50)
                      : AppColors.gold.withValues(alpha: 0.4),
                  width: 1.2,
                ),
              ),
              child: CheckboxListTile(
                value: _confirmedPaid,
                onChanged: (v) =>
                    setState(() => _confirmedPaid = v ?? false),
                activeColor: const Color(0xFF4CAF50),
                checkColor: Colors.white,
                contentPadding: EdgeInsets.zero,
                controlAffinity: ListTileControlAffinity.leading,
                title: Text(
                  _ck('confirmPaid'),
                  style: TextStyle(
                    color: AppColors.softGold,
                    fontSize: R.f(context, 12.5),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStep2(BuildContext context) {
    return GlassCard(
      ornament: false,
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.person_outline_rounded,
                    color: AppColors.gold, size: R.s(context, 20)),
                SizedBox(width: R.s(context, 8)),
                Text(
                  _ck('step2'),
                  style: TextStyle(
                    color: AppColors.softGold,
                    fontSize: R.f(context, 14),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            SizedBox(height: R.s(context, 8)),
            Text(
              _ck('step2Desc'),
              style: TextStyle(
                color: AppColors.cream.withValues(alpha: 0.7),
                fontSize: R.f(context, 12),
              ),
            ),
            SizedBox(height: R.s(context, 14)),
            _buildField(
              context,
              controller: _nameCtrl,
              label: _ck('name'),
              icon: Icons.person_rounded,
              validator: (v) {
                if (v == null || v.trim().isEmpty) return _ck('errName');
                return null;
              },
            ),
            SizedBox(height: R.s(context, 12)),
            _buildField(
              context,
              controller: _emailCtrl,
              label: _ck('email'),
              icon: Icons.mail_outline_rounded,
              keyboardType: TextInputType.emailAddress,
              validator: (v) {
                if (v == null || v.trim().isEmpty) return _ck('errEmail');
                return null;
              },
            ),
            SizedBox(height: R.s(context, 12)),
            _buildField(
              context,
              controller: _paypalCtrl,
              label: _ck('paypal'),
              icon: Icons.account_balance_wallet_outlined,
              validator: (v) {
                if (v == null || v.trim().isEmpty) return _ck('errPaypal');
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildField(
    BuildContext context, {
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      style: const TextStyle(color: AppColors.cream),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          color: AppColors.cream.withValues(alpha: 0.7),
          fontSize: R.f(context, 12.5),
        ),
        floatingLabelStyle: const TextStyle(color: AppColors.softGold),
        prefixIcon: Icon(icon, color: AppColors.gold, size: R.s(context, 20)),
        filled: true,
        fillColor: Colors.black.withValues(alpha: 0.25),
        contentPadding: EdgeInsets.symmetric(
          horizontal: R.s(context, 14),
          vertical: R.s(context, 14),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(R.s(context, 12)),
          borderSide:
              BorderSide(color: AppColors.gold.withValues(alpha: 0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(R.s(context, 12)),
          borderSide: const BorderSide(color: AppColors.gold, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(R.s(context, 12)),
          borderSide: const BorderSide(color: Colors.redAccent),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(R.s(context, 12)),
          borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
        ),
        errorStyle: TextStyle(fontSize: R.f(context, 11)),
      ),
    );
  }

  Widget _buildNote(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(R.s(context, 12)),
      decoration: BoxDecoration(
        color: AppColors.gold.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(R.s(context, 14)),
        border: Border.all(color: AppColors.gold.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline_rounded,
              color: AppColors.gold, size: R.s(context, 18)),
          SizedBox(width: R.s(context, 8)),
          Expanded(
            child: Text(
              _ck('note'),
              style: TextStyle(
                color: AppColors.softGold.withValues(alpha: 0.9),
                fontSize: R.f(context, 11.5),
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton(BuildContext context) {
    final enabled = _confirmedPaid && !_sending;
    return SizedBox(
      height: R.s(context, 54),
      child: ElevatedButton.icon(
        onPressed: enabled ? _submit : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.gold,
          foregroundColor: AppColors.deepGreen,
          disabledBackgroundColor: AppColors.gold.withValues(alpha: 0.3),
          disabledForegroundColor: AppColors.deepGreen.withValues(alpha: 0.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(R.s(context, 18)),
          ),
          elevation: enabled ? 6 : 0,
        ),
        icon: _sending
            ? SizedBox(
                width: R.s(context, 18),
                height: R.s(context, 18),
                child: const CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.deepGreen,
                ),
              )
            : Icon(Icons.send_rounded, size: R.s(context, 20)),
        label: Text(
          _sending ? _ck('sending') : _ck('confirm'),
          style: TextStyle(
            fontSize: R.f(context, 15),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
