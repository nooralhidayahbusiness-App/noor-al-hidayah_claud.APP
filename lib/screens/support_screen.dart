import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../core/app_state.dart';
import '../core/responsive.dart';
import '../core/theme.dart';
import '../widgets/animated_entry.dart';
import '../widgets/glass_card.dart';
import '../widgets/themed_background.dart';

// ============================================================
// ترجمات (7 لغات)
// ============================================================
const Map<String, Map<String, String>> _supTr = {
  'ar': {
    'title': 'الدعم والتواصل',
    'hero': 'نحن هنا لمساعدتك',
    'heroDesc': 'تواصل معنا في أي وقت عبر القنوات التالية',
    'emails': 'البريد الإلكتروني',
    'phones': 'أرقام الهاتف',
    'phonesOutside': 'من خارج الإمارات',
    'whatsapp': 'واتساب',
    'facebook': 'فيسبوك',
    'instagram': 'إنستغرام',
    'personalAccount': 'حساب شخصي',
    'officialPage': 'صفحة رسمية',
    'officialAccount': 'حساب رسمي',
    'teamAccount': 'حساب الفريق',
    'noAppFound': 'التطبيق غير مثبت على الجوال',
  },
  'en': {
    'title': 'Support & Contact',
    'hero': 'We are here to help',
    'heroDesc': 'Reach us anytime via the following channels',
    'emails': 'Email',
    'phones': 'Phone Numbers',
    'phonesOutside': 'From outside UAE',
    'whatsapp': 'WhatsApp',
    'facebook': 'Facebook',
    'instagram': 'Instagram',
    'personalAccount': 'Personal Account',
    'officialPage': 'Official Page',
    'officialAccount': 'Official Account',
    'teamAccount': 'Team Account',
    'noAppFound': 'App not installed',
  },
  'fr': {
    'title': 'Support & Contact',
    'hero': 'Nous sommes là pour vous aider',
    'heroDesc': 'Contactez-nous à tout moment',
    'emails': 'Email',
    'phones': 'Téléphones',
    'phonesOutside': "Depuis l'extérieur des EAU",
    'whatsapp': 'WhatsApp',
    'facebook': 'Facebook',
    'instagram': 'Instagram',
    'personalAccount': 'Compte personnel',
    'officialPage': 'Page officielle',
    'officialAccount': 'Compte officiel',
    'teamAccount': 'Compte équipe',
    'noAppFound': 'Application non installée',
  },
  'ur': {
    'title': 'سپورٹ اور رابطہ',
    'hero': 'ہم آپ کی مدد کے لیے حاضر ہیں',
    'heroDesc': 'کسی بھی وقت ہم سے رابطہ کریں',
    'emails': 'ای میل',
    'phones': 'فون نمبر',
    'phonesOutside': 'متحدہ عرب امارات سے باہر',
    'whatsapp': 'واٹس ایپ',
    'facebook': 'فیس بک',
    'instagram': 'انسٹاگرام',
    'personalAccount': 'ذاتی اکاؤنٹ',
    'officialPage': 'سرکاری صفحہ',
    'officialAccount': 'سرکاری اکاؤنٹ',
    'teamAccount': 'ٹیم اکاؤنٹ',
    'noAppFound': 'ایپ انسٹال نہیں',
  },
  'ne': {
    'title': 'सहयोग र सम्पर्क',
    'hero': 'हामी तपाईंको सहयोगको लागि यहाँ छौं',
    'heroDesc': 'जुनसुकै बेला हामीलाई सम्पर्क गर्नुहोस्',
    'emails': 'इमेल',
    'phones': 'फोन नम्बर',
    'phonesOutside': 'यूएई बाहिरबाट',
    'whatsapp': 'व्हाट्सएप',
    'facebook': 'फेसबुक',
    'instagram': 'इन्स्टाग्राम',
    'personalAccount': 'व्यक्तिगत खाता',
    'officialPage': 'आधिकारिक पृष्ठ',
    'officialAccount': 'आधिकारिक खाता',
    'teamAccount': 'टोली खाता',
    'noAppFound': 'एप इन्स्टल छैन',
  },
  'id': {
    'title': 'Dukungan & Kontak',
    'hero': 'Kami di sini untuk membantu',
    'heroDesc': 'Hubungi kami kapan saja',
    'emails': 'Email',
    'phones': 'Nomor Telepon',
    'phonesOutside': 'Dari luar UEA',
    'whatsapp': 'WhatsApp',
    'facebook': 'Facebook',
    'instagram': 'Instagram',
    'personalAccount': 'Akun Pribadi',
    'officialPage': 'Halaman Resmi',
    'officialAccount': 'Akun Resmi',
    'teamAccount': 'Akun Tim',
    'noAppFound': 'Aplikasi tidak terpasang',
  },
  'ms': {
    'title': 'Sokongan & Hubungan',
    'hero': 'Kami di sini untuk membantu',
    'heroDesc': 'Hubungi kami bila-bila masa',
    'emails': 'E-mel',
    'phones': 'Nombor Telefon',
    'phonesOutside': 'Dari luar UAE',
    'whatsapp': 'WhatsApp',
    'facebook': 'Facebook',
    'instagram': 'Instagram',
    'personalAccount': 'Akaun Peribadi',
    'officialPage': 'Halaman Rasmi',
    'officialAccount': 'Akaun Rasmi',
    'teamAccount': 'Akaun Pasukan',
    'noAppFound': 'Aplikasi tidak dipasang',
  },
};

String _st(String key) {
  final m = _supTr[appState.languageCode] ?? _supTr['ar']!;
  return m[key] ?? key;
}

// ============================================================
// SupportScreen
// ============================================================
class SupportScreen extends StatelessWidget {
  const SupportScreen({super.key});

  // الإيميلات
  static const List<String> _emails = [
    'abdelrahmenbenromdhan11@gmail.com',
    'vevocom888@gmail.com',
    'nooralimanechannel@gmail.com',
    'nooralhidayahbusiness@gmail.com',
  ];

  // أرقام داخل الإمارات
  static const List<String> _phonesUae = [
    '+971501159417',
    '+971552173597',
  ];

  // أرقام خارج الإمارات
  static const List<String> _phonesOutside = [
    '00971501159417',
    '00971552173597',
  ];

  // واتساب
  static const List<String> _whatsapp = [
    '+971501159417',
    '+971552173597',
  ];

  // فيسبوك
  static const Map<String, String> _facebookPersonal = {
    'label': 'Abd Rahmen',
    'url': 'https://www.facebook.com/share/1MASNva4Jc/',
  };

  static const Map<String, String> _facebookPage = {
    'label': 'Noor Al-Hidayah',
    'url': 'https://www.facebook.com/share/1d5Tvs5vup/',
  };

  // إنستغرام
  static const Map<String, String> _instagram = {
    'label': 'Noor Al Hidayah Team',
    'url':
        'https://www.instagram.com/nooralhidayahofficial/?utm_source=qr&r=nametag',
  };

  @override
  Widget build(BuildContext context) {
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
                    padding: EdgeInsets.all(R.s(context, 16)),
                    children: [
                      AnimatedEntry(child: _buildHero(context)),
                      SizedBox(height: R.s(context, 16)),

                      // البريد
                      AnimatedEntry(
                        delay: const Duration(milliseconds: 100),
                        child: _buildEmailsSection(context),
                      ),
                      SizedBox(height: R.s(context, 12)),

                      // الهاتف (داخل الإمارات)
                      AnimatedEntry(
                        delay: const Duration(milliseconds: 150),
                        child: _buildPhonesUaeSection(context),
                      ),
                      SizedBox(height: R.s(context, 12)),

                      // الهاتف (خارج الإمارات)
                      AnimatedEntry(
                        delay: const Duration(milliseconds: 200),
                        child: _buildPhonesOutsideSection(context),
                      ),
                      SizedBox(height: R.s(context, 12)),

                      // واتساب
                      AnimatedEntry(
                        delay: const Duration(milliseconds: 250),
                        child: _buildWhatsappSection(context),
                      ),
                      SizedBox(height: R.s(context, 12)),

                      // فيسبوك
                      AnimatedEntry(
                        delay: const Duration(milliseconds: 300),
                        child: _buildFacebookSection(context),
                      ),
                      SizedBox(height: R.s(context, 12)),

                      // إنستغرام
                      AnimatedEntry(
                        delay: const Duration(milliseconds: 350),
                        child: _buildInstagramSection(context),
                      ),
                      SizedBox(height: R.s(context, 24)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.green,
      elevation: 0,
      iconTheme: const IconThemeData(color: AppColors.cream),
      centerTitle: true,
      title: Text(
        _st('title'),
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

  Widget _buildHero(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(R.s(context, 20)),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(R.s(context, 24)),
        gradient: LinearGradient(
          colors: [
            AppColors.gold.withValues(alpha: 0.2),
            AppColors.deepGreen.withValues(alpha: 0.9),
          ],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        border: Border.all(
          color: AppColors.gold.withValues(alpha: 0.5),
          width: 1.5,
        ),
      ),
      child: Column(
        children: [
          // أيقونة support.png الذهبية
          Container(
            padding: EdgeInsets.all(R.s(context, 16)),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.gold.withValues(alpha: 0.15),
              border: Border.all(color: AppColors.gold, width: 2),
            ),
            child: ColorFiltered(
              colorFilter: const ColorFilter.mode(
                AppColors.gold,
                BlendMode.srcIn,
              ),
              child: Image.asset(
                'assets/icons/support.png',
                width: R.s(context, 42),
                height: R.s(context, 42),
                errorBuilder: (_, _, _) => Icon(
                  Icons.support_agent_rounded,
                  color: AppColors.gold,
                  size: R.s(context, 42),
                ),
              ),
            ),
          ),
          SizedBox(height: R.s(context, 14)),
          Text(
            _st('hero'),
            style: TextStyle(
              color: AppColors.softGold,
              fontSize: R.f(context, 20),
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: R.s(context, 6)),
          Text(
            _st('heroDesc'),
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.cream.withValues(alpha: 0.75),
              fontSize: R.f(context, 13),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  // ============ Email Section ============
  Widget _buildEmailsSection(BuildContext context) {
    return _buildSection(
      context,
      title: _st('emails'),
      icon: Icons.email_rounded,
      children: _emails.map((email) {
        return _ContactRow(
          iconAsset: 'assets/icons/gmail.png',
          fallbackIcon: Icons.mail_rounded,
          colorize: false,
          label: email,
          onTap: () => _openUrl(context, 'mailto:$email'),
        );
      }).toList(),
    );
  }

  // ============ Phone Section (UAE) ============
  Widget _buildPhonesUaeSection(BuildContext context) {
    return _buildSection(
      context,
      title: _st('phones'),
      icon: Icons.phone_rounded,
      children: _phonesUae.map((phone) {
        final clean = phone.replaceAll(' ', '');
        return _ContactRow(
          iconAsset: 'assets/icons/phone.png',
          fallbackIcon: Icons.call_rounded,
          colorize: true, // ✅ ذهبية
          label: phone,
          onTap: () => _openUrl(context, 'tel:$clean'),
        );
      }).toList(),
    );
  }

  // ============ Phone Section (Outside UAE) ============
  Widget _buildPhonesOutsideSection(BuildContext context) {
    return _buildSection(
      context,
      title: _st('phonesOutside'),
      icon: Icons.public_rounded,
      children: _phonesOutside.map((phone) {
        final clean = phone.replaceAll(' ', '');
        return _ContactRow(
          iconAsset: 'assets/icons/phone.png',
          fallbackIcon: Icons.call_rounded,
          colorize: true,
          label: phone,
          onTap: () => _openUrl(context, 'tel:$clean'),
        );
      }).toList(),
    );
  }

  // ============ WhatsApp Section ============
  Widget _buildWhatsappSection(BuildContext context) {
    return _buildSection(
      context,
      title: _st('whatsapp'),
      icon: Icons.chat_rounded,
      children: _whatsapp.map((phone) {
        final clean = phone.replaceAll('+', '').replaceAll(' ', '');
        return _ContactRow(
          iconAsset: 'assets/icons/whatsapp.png',
          fallbackIcon: Icons.chat_bubble_rounded,
          colorize: false,
          label: phone,
          onTap: () => _openUrl(context, 'https://wa.me/$clean'),
        );
      }).toList(),
    );
  }

  // ============ Facebook Section ============
  Widget _buildFacebookSection(BuildContext context) {
    return _buildSection(
      context,
      title: _st('facebook'),
      icon: Icons.facebook_rounded,
      children: [
        _ContactRow(
          iconAsset: 'assets/icons/facebook.png',
          fallbackIcon: Icons.facebook_rounded,
          colorize: false,
          label: _facebookPersonal['label']!,
          subtitle: _st('personalAccount'),
          onTap: () => _openUrl(context, _facebookPersonal['url']!),
        ),
        _ContactRow(
          iconAsset: 'assets/icons/facebook.png',
          fallbackIcon: Icons.facebook_rounded,
          colorize: false,
          label: _facebookPage['label']!,
          subtitle: _st('officialPage'),
          onTap: () => _openUrl(context, _facebookPage['url']!),
        ),
      ],
    );
  }

  // ============ Instagram Section ============
  Widget _buildInstagramSection(BuildContext context) {
    return _buildSection(
      context,
      title: _st('instagram'),
      icon: Icons.camera_alt_rounded,
      children: [
        _ContactRow(
          iconAsset: 'assets/icons/instagram.png',
          fallbackIcon: Icons.camera_alt_rounded,
          colorize: false,
          label: _instagram['label']!,
          subtitle: _st('teamAccount'),
          onTap: () => _openUrl(context, _instagram['url']!),
        ),
      ],
    );
  }

  // ============ Helper: Section Card ============
  Widget _buildSection(
    BuildContext context, {
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return GlassCard(
      ornament: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.gold, size: R.s(context, 20)),
              SizedBox(width: R.s(context, 10)),
              Text(
                title,
                style: TextStyle(
                  color: AppColors.softGold,
                  fontSize: R.f(context, 14),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: R.s(context, 10)),
          Divider(
            height: 1,
            color: AppColors.gold.withValues(alpha: 0.15),
          ),
          SizedBox(height: R.s(context, 6)),
          ...children,
        ],
      ),
    );
  }

  Future<void> _openUrl(BuildContext context, String url) async {
    try {
      final uri = Uri.parse(url);
      final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!ok) throw Exception('failed');
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_st('noAppFound')),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}

// ============================================================
// _ContactRow
// ============================================================
class _ContactRow extends StatelessWidget {
  final String? iconAsset;
  final IconData fallbackIcon;
  final bool colorize; // ✅ إن true → فلتر ذهبي
  final String label;
  final String? subtitle;
  final VoidCallback onTap;

  const _ContactRow({
    required this.iconAsset,
    required this.fallbackIcon,
    required this.colorize,
    required this.label,
    this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(R.s(context, 12)),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: R.s(context, 6),
          vertical: R.s(context, 10),
        ),
        child: Row(
          children: [
            Container(
              width: R.s(context, 40),
              height: R.s(context, 40),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.gold.withValues(alpha: 0.12),
                border: Border.all(
                  color: AppColors.gold.withValues(alpha: 0.4),
                  width: 1,
                ),
              ),
              child: Center(
                child: iconAsset != null
                    ? Padding(
                        padding: EdgeInsets.all(R.s(context, 8)),
                        child: colorize
                            ? ColorFiltered(
                                colorFilter: const ColorFilter.mode(
                                  AppColors.gold,
                                  BlendMode.srcIn,
                                ),
                                child: Image.asset(
                                  iconAsset!,
                                  fit: BoxFit.contain,
                                  errorBuilder: (_, _, _) => Icon(
                                    fallbackIcon,
                                    color: AppColors.gold,
                                    size: R.s(context, 20),
                                  ),
                                ),
                              )
                            : Image.asset(
                                iconAsset!,
                                fit: BoxFit.contain,
                                errorBuilder: (_, _, _) => Icon(
                                  fallbackIcon,
                                  color: AppColors.gold,
                                  size: R.s(context, 20),
                                ),
                              ),
                      )
                    : Icon(
                        fallbackIcon,
                        color: AppColors.gold,
                        size: R.s(context, 20),
                      ),
              ),
            ),
            SizedBox(width: R.s(context, 12)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      color: AppColors.cream,
                      fontSize: R.f(context, 12.5),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (subtitle != null) ...[
                    SizedBox(height: R.s(context, 2)),
                    Text(
                      subtitle!,
                      style: TextStyle(
                        color: AppColors.cream.withValues(alpha: 0.55),
                        fontSize: R.f(context, 11),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              color: AppColors.gold.withValues(alpha: 0.6),
              size: R.s(context, 14),
            ),
          ],
        ),
      ),
    );
  }
}
