import 'package:flutter/material.dart';

import '../../core/app_state.dart';
import '../../core/responsive.dart';
import '../../core/theme.dart';
import '../../services/youtube_service.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/themed_background.dart';

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
      _snack('العنوان مطلوب', error: true);
      return;
    }
    if (u.isEmpty) {
      _snack('رابط YouTube مطلوب', error: true);
      return;
    }
    if (_previewId == null) {
      _snack('رابط YouTube غير صالح', error: true);
      return;
    }

    setState(() => _saving = true);
    try {
      await youtubeService.addVideo(
        title: t,
        url: u,
        thumbnailUrl: _thumb.text.trim(),
      );
      if (mounted) {
        _snack('تم النشر بنجاح ✅');
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

    return Scaffold(
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
                      onPressed: () => Navigator.of(context).maybePop(),
                      color: AppColors.softGold,
                      iconSize: R.s(context, 22),
                      icon: const Icon(Icons.arrow_back_rounded),
                    ),
                    const Spacer(),
                    Text(
                      'إضافة فيديو',
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
                    // ===== عنوان =====
                    _Field(
                      controller: _title,
                      label: 'عنوان الفيديو',
                      icon: Icons.title_rounded,
                    ),
                    SizedBox(height: R.s(context, 14)),

                    // ===== رابط =====
                    _Field(
                      controller: _url,
                      label: 'رابط YouTube',
                      icon: Icons.link_rounded,
                      keyboardType: TextInputType.url,
                      hint: 'https://youtube.com/watch?v=...',
                    ),
                    SizedBox(height: R.s(context, 14)),

                    // ===== صورة مصغرة (اختياري) =====
                    _Field(
                      controller: _thumb,
                      label: 'رابط الصورة المصغّرة (اختياري)',
                      icon: Icons.image_rounded,
                      keyboardType: TextInputType.url,
                      hint: 'تلقائي من YouTube إذا فاضي',
                    ),

                    // ===== معاينة =====
                    if (preview != null) ...[
                      SizedBox(height: R.s(context, 18)),
                      GlassCard(
                        ornament: false,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
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
                                  'معاينة',
                                  style: TextStyle(
                                    color: AppColors.softGold,
                                    fontSize: R.f(context, 12),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: R.s(context, 10)),
                            ClipRRect(
                              borderRadius:
                                  BorderRadius.circular(R.s(context, 12)),
                              child: AspectRatio(
                                aspectRatio: 16 / 9,
                                child: Stack(
                                  fit: StackFit.expand,
                                  children: [
                                    Image.network(
                                      _thumb.text.trim().isNotEmpty
                                          ? _thumb.text.trim()
                                          : preview,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, _, _) => Container(
                                        color: AppColors.green,
                                        child: const Icon(
                                          Icons.play_circle_fill_rounded,
                                          color: AppColors.gold,
                                          size: 56,
                                        ),
                                      ),
                                    ),
                                    const Center(
                                      child: Icon(
                                        Icons.play_circle_outline_rounded,
                                        color: AppColors.gold,
                                        size: 44,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    SizedBox(height: R.s(context, 24)),

                    // ===== زر النشر =====
                    SizedBox(
                      height: R.s(context, 54),
                      child: ElevatedButton.icon(
                        onPressed: _saving ? null : _publish,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.gold,
                          foregroundColor: AppColors.deepGreen,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(R.s(context, 18)),
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
                          _saving ? 'جارٍ النشر...' : 'نشر الفيديو',
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
