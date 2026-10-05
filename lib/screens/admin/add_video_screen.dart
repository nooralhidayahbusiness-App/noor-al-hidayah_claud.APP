import 'package:flutter/material.dart';

import '../../core/app_state.dart';
import '../../core/responsive.dart';
import '../../core/theme.dart';
import '../../services/youtube_service.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/themed_background.dart';

// ============ ترجمات ============
const Map<String, Map<String, String>> _avTr = {
  'ar': {
    'title': 'إضافة فيديو',
    'titleReel': 'إضافة ريل',
    'typeNormal': 'فيديو عادي (16:9)',
    'typeReel': 'ريلز (9:16)',
    'fieldTitle': 'عنوان الفيديو',
    'fieldUrl': 'رابط YouTube',
    'fieldThumb': 'رابط الصورة المصغّرة (اختياري)',
    'hintUrl': 'https://youtube.com/watch?v=...',
    'hintThumb': 'تلقائي من YouTube إذا فاضي',
    'preview': 'معاينة',
    'preview169': 'معاينة (16:9)',
    'preview916': 'معاينة (9:16)',
    'publish': 'نشر الفيديو',
    'publishReel': 'نشر الريل',
    'publishing': 'جارٍ النشر...',
    'errTitle': 'العنوان مطلوب',
    'errUrl': 'رابط YouTube مطلوب',
    'errUrlInvalid': 'رابط YouTube غير صالح',
    'successVideo': 'تم نشر الفيديو بنجاح ✅',
    'successReel': 'تم نشر الريل بنجاح ✅',
  },
  'en': {
    'title': 'Add Video',
    'titleReel': 'Add Reel',
    'typeNormal': 'Video (16:9)',
    'typeReel': 'Reel (9:16)',
    'fieldTitle': 'Video title',
    'fieldUrl': 'YouTube URL',
    'fieldThumb': 'Thumbnail URL (optional)',
    'hintUrl': 'https://youtube.com/watch?v=...',
    'hintThumb': 'Auto from YouTube if empty',
    'preview': 'Preview',
    'preview169': 'Preview (16:9)',
    'preview916': 'Preview (9:16)',
    'publish': 'Publish Video',
    'publishReel': 'Publish Reel',
    'publishing': 'Publishing...',
    'errTitle': 'Title is required',
    'errUrl': 'YouTube URL is required',
    'errUrlInvalid': 'Invalid YouTube URL',
    'successVideo': 'Video published ✅',
    'successReel': 'Reel published ✅',
  },
  'fr': {
    'title': 'Ajouter une vidéo',
    'titleReel': 'Ajouter un Reel',
    'typeNormal': 'Vidéo (16:9)',
    'typeReel': 'Reel (9:16)',
    'fieldTitle': 'Titre de la vidéo',
    'fieldUrl': 'URL YouTube',
    'fieldThumb': 'URL de la miniature (optionnel)',
    'hintUrl': 'https://youtube.com/watch?v=...',
    'hintThumb': 'Auto de YouTube si vide',
    'preview': 'Aperçu',
    'preview169': 'Aperçu (16:9)',
    'preview916': 'Aperçu (9:16)',
    'publish': 'Publier la vidéo',
    'publishReel': 'Publier le Reel',
    'publishing': 'Publication...',
    'errTitle': 'Le titre est requis',
    'errUrl': "L'URL YouTube est requise",
    'errUrlInvalid': 'URL YouTube invalide',
    'successVideo': 'Vidéo publiée ✅',
    'successReel': 'Reel publié ✅',
  },
  'ur': {
    'title': 'ویڈیو شامل کریں',
    'titleReel': 'ریل شامل کریں',
    'typeNormal': 'ویڈیو (16:9)',
    'typeReel': 'ریل (9:16)',
    'fieldTitle': 'ویڈیو کا عنوان',
    'fieldUrl': 'YouTube URL',
    'fieldThumb': 'تھمب نیل URL (اختیاری)',
    'hintUrl': 'https://youtube.com/watch?v=...',
    'hintThumb': 'YouTube سے خودکار',
    'preview': 'پیش نظارہ',
    'preview169': 'پیش نظارہ (16:9)',
    'preview916': 'پیش نظارہ (9:16)',
    'publish': 'ویڈیو شائع کریں',
    'publishReel': 'ریل شائع کریں',
    'publishing': 'شائع ہو رہی ہے...',
    'errTitle': 'عنوان درکار ہے',
    'errUrl': 'YouTube URL درکار ہے',
    'errUrlInvalid': 'YouTube URL غلط',
    'successVideo': 'ویڈیو شائع ہو گئی ✅',
    'successReel': 'ریل شائع ہو گئی ✅',
  },
  'ne': {
    'title': 'भिडियो थप्नुहोस्',
    'titleReel': 'रील थप्नुहोस्',
    'typeNormal': 'भिडियो (16:9)',
    'typeReel': 'रील (9:16)',
    'fieldTitle': 'भिडियो शीर्षक',
    'fieldUrl': 'YouTube URL',
    'fieldThumb': 'थम्बनेल URL (वैकल्पिक)',
    'hintUrl': 'https://youtube.com/watch?v=...',
    'hintThumb': 'YouTube बाट स्वतः',
    'preview': 'पूर्वावलोकन',
    'preview169': 'पूर्वावलोकन (16:9)',
    'preview916': 'पूर्वावलोकन (9:16)',
    'publish': 'भिडियो प्रकाशित',
    'publishReel': 'रील प्रकाशित',
    'publishing': 'प्रकाशित हुँदै...',
    'errTitle': 'शीर्षक आवश्यक',
    'errUrl': 'YouTube URL आवश्यक',
    'errUrlInvalid': 'YouTube URL अवैध',
    'successVideo': 'भिडियो प्रकाशित ✅',
    'successReel': 'रील प्रकाशित ✅',
  },
  'id': {
    'title': 'Tambah Video',
    'titleReel': 'Tambah Reel',
    'typeNormal': 'Video (16:9)',
    'typeReel': 'Reel (9:16)',
    'fieldTitle': 'Judul video',
    'fieldUrl': 'URL YouTube',
    'fieldThumb': 'URL thumbnail (opsional)',
    'hintUrl': 'https://youtube.com/watch?v=...',
    'hintThumb': 'Otomatis dari YouTube jika kosong',
    'preview': 'Pratinjau',
    'preview169': 'Pratinjau (16:9)',
    'preview916': 'Pratinjau (9:16)',
    'publish': 'Publikasikan Video',
    'publishReel': 'Publikasikan Reel',
    'publishing': 'Mempublikasikan...',
    'errTitle': 'Judul wajib diisi',
    'errUrl': 'URL YouTube wajib diisi',
    'errUrlInvalid': 'URL YouTube tidak valid',
    'successVideo': 'Video dipublikasikan ✅',
    'successReel': 'Reel dipublikasikan ✅',
  },
  'ms': {
    'title': 'Tambah Video',
    'titleReel': 'Tambah Reel',
    'typeNormal': 'Video (16:9)',
    'typeReel': 'Reel (9:16)',
    'fieldTitle': 'Tajuk video',
    'fieldUrl': 'URL YouTube',
    'fieldThumb': 'URL thumbnail (pilihan)',
    'hintUrl': 'https://youtube.com/watch?v=...',
    'hintThumb': 'Auto dari YouTube jika kosong',
    'preview': 'Pratonton',
    'preview169': 'Pratonton (16:9)',
    'preview916': 'Pratonton (9:16)',
    'publish': 'Terbitkan Video',
    'publishReel': 'Terbitkan Reel',
    'publishing': 'Menerbitkan...',
    'errTitle': 'Tajuk diperlukan',
    'errUrl': 'URL YouTube diperlukan',
    'errUrlInvalid': 'URL YouTube tidak sah',
    'successVideo': 'Video diterbitkan ✅',
    'successReel': 'Reel diterbitkan ✅',
  },
};

String _av(String key) {
  final m = _avTr[appState.languageCode] ?? _avTr['ar']!;
  return m[key] ?? key;
}

class AddVideoScreen extends StatefulWidget {
  const AddVideoScreen({super.key});

  @override
  State<AddVideoScreen> createState() => _AddVideoScreenState();
}

class _AddVideoScreenState extends State<AddVideoScreen> {
  final _title = TextEditingController();
  final _url = TextEditingController();
  final _thumb = TextEditingController();
  bool _saving = false;
  bool _isReel = false;
  String? _previewId;

  @override
  void initState() {
    super.initState();
    _url.addListener(_onUrlChanged);
  }

  @override
  void dispose() {
    _url.removeListener(_onUrlChanged);
    _title.dispose();
    _url.dispose();
    _thumb.dispose();
    super.dispose();
  }

  void _onUrlChanged() {
    final id = YouTubeService.extractVideoId(_url.text.trim());
    if (id != _previewId) {
      setState(() => _previewId = id);
    }
  }

  Future<void> _publish() async {
    FocusScope.of(context).unfocus();
    final t = _title.text.trim();
    final u = _url.text.trim();

    if (t.isEmpty) {
      _snack(_av('errTitle'), error: true);
      return;
    }
    if (u.isEmpty) {
      _snack(_av('errUrl'), error: true);
      return;
    }
    if (_previewId == null) {
      _snack(_av('errUrlInvalid'), error: true);
      return;
    }

    setState(() => _saving = true);
try {
  final videoId = await youtubeService.addVideo(
    title: t,
    url: u,
    thumbnailUrl: _thumb.text.trim(),
    isReel: _isReel,
  );

  // ✅ إرسال إشعار لكل المتابعين
  try {
    await CommunityNotificationService().notifyNewVideo(
      videoId: videoId,
      videoTitle: t,
      isReel: _isReel,
    );
  } catch (_) {}

  if (mounted) {
    _snack(_isReel ? _av('successReel') : _av('successVideo'));
    await Future.delayed(const Duration(milliseconds: 700));
    if (mounted) Navigator.of(context).pop(true);
  }
} catch (e) {
      if (mounted) _snack('$e', error: true);
    } finally {
      if (mounted) setState(() => _saving = false);
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
    final preview = _previewId != null
        ? YouTubeService.thumbnailFor(_previewId!)
        : null;

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
                            _isReel ? _av('titleReel') : _av('title'),
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
                      child: ListView(
                        padding: EdgeInsets.all(R.s(context, 18)),
                        children: [
                          _TypeSelector(
                            isReel: _isReel,
                            onChanged: (v) =>
                                setState(() => _isReel = v),
                          ),
                          SizedBox(height: R.s(context, 18)),
                          _Field(
                            controller: _title,
                            label: _av('fieldTitle'),
                            icon: Icons.title_rounded,
                          ),
                          SizedBox(height: R.s(context, 14)),
                          _Field(
                            controller: _url,
                            label: _av('fieldUrl'),
                            icon: Icons.link_rounded,
                            keyboardType: TextInputType.url,
                            hint: _av('hintUrl'),
                          ),
                          SizedBox(height: R.s(context, 14)),
                          _Field(
                            controller: _thumb,
                            label: _av('fieldThumb'),
                            icon: Icons.image_rounded,
                            keyboardType: TextInputType.url,
                            hint: _av('hintThumb'),
                          ),
                          if (preview != null) ...[
                            SizedBox(height: R.s(context, 18)),
                            GlassCard(
                              ornament: false,
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.visibility_rounded,
                                        color: AppColors.gold,
                                        size: R.s(context, 16),
                                      ),
                                      SizedBox(width: R.s(context, 6)),
                                      Text(
                                        _isReel
                                            ? _av('preview916')
                                            : _av('preview169'),
                                        style: TextStyle(
                                          color: AppColors.softGold,
                                          fontSize: R.f(context, 12),
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: R.s(context, 10)),
                                  Center(
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(
                                          R.s(context, 12)),
                                      child: SizedBox(
                                        width: _isReel
                                            ? R.s(context, 180)
                                            : double.infinity,
                                        child: AspectRatio(
                                          aspectRatio:
                                              _isReel ? 9 / 16 : 16 / 9,
                                          child: Stack(
                                            fit: StackFit.expand,
                                            children: [
                                              Image.network(
                                                _thumb.text.trim().isNotEmpty
                                                    ? _thumb.text.trim()
                                                    : preview,
                                                fit: BoxFit.cover,
                                                errorBuilder:
                                                    (_, _, _) => Container(
                                                  color: AppColors.green,
                                                  child: const Icon(
                                                    Icons
                                                        .play_circle_fill_rounded,
                                                    color: AppColors.gold,
                                                    size: 56,
                                                  ),
                                                ),
                                              ),
                                              const Center(
                                                child: Icon(
                                                  Icons
                                                      .play_circle_outline_rounded,
                                                  color: AppColors.gold,
                                                  size: 44,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                          SizedBox(height: R.s(context, 24)),
                          SizedBox(
                            height: R.s(context, 54),
                            child: ElevatedButton.icon(
                              onPressed: _saving ? null : _publish,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.gold,
                                foregroundColor: AppColors.deepGreen,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                      R.s(context, 18)),
                                ),
                                elevation: 6,
                              ),
                              icon: _saving
                                  ? SizedBox(
                                      width: R.s(context, 18),
                                      height: R.s(context, 18),
                                      child: const CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: AppColors.deepGreen,
                                      ),
                                    )
                                  : Icon(
                                      Icons.publish_rounded,
                                      size: R.s(context, 20),
                                    ),
                              label: Text(
                                _saving
                                    ? _av('publishing')
                                    : (_isReel
                                        ? _av('publishReel')
                                        : _av('publish')),
                                style: TextStyle(
                                  fontSize: R.f(context, 15),
                                  fontWeight: FontWeight.bold,
                                ),
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
          ),
        );
      },
    );
  }
}

// ============================================================
// _TypeSelector
// ============================================================
class _TypeSelector extends StatelessWidget {
  final bool isReel;
  final ValueChanged<bool> onChanged;

  const _TypeSelector({
    required this.isReel,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(R.s(context, 4)),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(R.s(context, 16)),
        color: AppColors.deepGreen.withValues(alpha: 0.65),
        border: Border.all(color: AppColors.gold.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Expanded(
            child: _SelectorBtn(
              icon: Icons.smart_display_rounded,
              label: _av('typeNormal'),
              active: !isReel,
              onTap: () => onChanged(false),
            ),
          ),
          SizedBox(width: R.s(context, 4)),
          Expanded(
            child: _SelectorBtn(
              icon: Icons.movie_filter_rounded,
              label: _av('typeReel'),
              active: isReel,
              onTap: () => onChanged(true),
            ),
          ),
        ],
      ),
    );
  }
}

class _SelectorBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback onTap;

  const _SelectorBtn({
    required this.icon,
    required this.label,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        padding: EdgeInsets.symmetric(vertical: R.s(context, 12)),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(R.s(context, 14)),
          color: active ? AppColors.gold : Colors.transparent,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: R.s(context, 18),
              color: active ? AppColors.deepGreen : AppColors.softGold,
            ),
            SizedBox(width: R.s(context, 6)),
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: R.f(context, 11.5),
                  fontWeight: FontWeight.w700,
                  color: active ? AppColors.deepGreen : AppColors.softGold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// _Field
// ============================================================
class _Field extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final TextInputType? keyboardType;
  final String? hint;

  const _Field({
    required this.controller,
    required this.label,
    required this.icon,
    this.keyboardType,
    this.hint,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: AppColors.softGold,
            fontSize: R.f(context, 12),
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: R.s(context, 6)),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          textDirection:
              keyboardType == TextInputType.url ? TextDirection.ltr : null,
          style: const TextStyle(color: AppColors.cream),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: AppColors.cream.withValues(alpha: 0.35),
              fontSize: R.f(context, 12),
            ),
            prefixIcon: Icon(icon, color: AppColors.gold),
            filled: true,
            fillColor: Colors.black.withValues(alpha: 0.25),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(R.s(context, 14)),
              borderSide:
                  BorderSide(color: AppColors.gold.withValues(alpha: 0.3)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(R.s(context, 14)),
              borderSide: const BorderSide(color: AppColors.gold, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}
