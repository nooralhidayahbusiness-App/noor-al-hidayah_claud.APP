import 'package:flutter/material.dart';

import '../../core/app_state.dart';
import '../../core/channel_config.dart';
import '../../core/fonts.dart';
import '../../core/responsive.dart';
import '../../core/theme.dart';
import '../../models/channel_video_data.dart';
import '../../services/link_service.dart';
import '../../services/youtube_service.dart';
import '../../widgets/auth_widgets.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/glow_sparks.dart';

class ChannelView extends StatelessWidget {
  const ChannelView({super.key});

  Future<void> _open(BuildContext context, String url) async {
    if (url.isEmpty) {
      showAuthMessage(context, appState.tr('channelNotSet'), error: true);
      return;
    }
    final ok = await openExternalLink(url);
    if (!ok && context.mounted) {
      showAuthMessage(context, appState.tr('linkFailed'), error: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: appState,
      builder: (context, _) {
        final name = appState.tr('appName');
        return ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          children: [
            // ===== بطاقة القناة =====
            GlassCard(
              child: Column(
                children: [
                  const _ChannelLogo(),
                  const SizedBox(height: 12),
                  Text(
                    name,
                    textAlign: TextAlign.center,
                    style: brandStyle(
                      name,
                      fontSize: 30,
                      color: AppColors.softGold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    kChannelHandle,
                    textDirection: TextDirection.ltr,
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.cream.withValues(alpha: 0.7),
                    ),
                  ),
                  const SizedBox(height: 18),
                  GoldButton(
                    label: appState.tr('subscribe'),
                    onPressed: () => _open(
                      context,
                      kChannelUrl.isEmpty ? '' : subscribeUrl(kChannelUrl),
                    ),
                  ),
                  const SizedBox(height: 10),
                  OutlinedButton.icon(
                    onPressed: () => _open(context, kChannelUrl),
                    icon: const Icon(Icons.open_in_new_rounded, size: 18),
                    label: Text(appState.tr('openChannel')),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.softGold,
                      minimumSize: const Size.fromHeight(50),
                      side: BorderSide(
                        color: AppColors.gold.withValues(alpha: 0.6),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 22),
            Text(
              appState.tr('latestVideos'),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.softGold,
              ),
            ),
            const SizedBox(height: 12),

            // ===== قائمة الفيديوهات (من Firestore) =====
            StreamBuilder<List<ChannelVideoData>>(
              stream: youtubeService.stream(),
              builder: (context, snap) {
                if (snap.connectionState == ConnectionState.waiting &&
                    !snap.hasData) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 30),
                    child: const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.gold,
                        strokeWidth: 2,
                      ),
                    ),
                  );
                }

                if (snap.hasError) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: Center(
                      child: Text(
                        appState.tr('videosSoon'),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          height: 1.6,
                          color: AppColors.cream.withValues(alpha: 0.7),
                        ),
                      ),
                    ),
                  );
                }

                final videos = snap.data ?? [];

                // لو ما فيه فيديوهات في Firestore، نستخدم القائمة المحلية
                if (videos.isEmpty) {
                  if (kChannelVideos.isEmpty) {
                    return Text(
                      appState.tr('videosSoon'),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        height: 1.6,
                        color: AppColors.cream.withValues(alpha: 0.7),
                      ),
                    );
                  }
                  // fallback للقائمة الثابتة
                  return Column(
                    children: [
                      for (final video in kChannelVideos.reversed)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 14),
                          child: _LocalVideoCard(
                            video: video,
                            onTap: () => _open(context, video.url),
                          ),
                        ),
                    ],
                  );
                }

                return Column(
                  children: [
                    for (final video in videos)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 14),
                        child: _FirestoreVideoCard(
                          video: video,
                          onTap: () => _open(context, video.url),
                        ),
                      ),
                  ],
                );
              },
            ),
          ],
        );
      },
    );
  }
}

// ============================================================
// _FirestoreVideoCard — فيديو من Firestore
// ============================================================
class _FirestoreVideoCard extends StatelessWidget {
  final ChannelVideoData video;
  final VoidCallback onTap;

  const _FirestoreVideoCard({
    required this.video,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final thumbnail = video.thumbnailUrl.isNotEmpty
        ? video.thumbnailUrl
        : YouTubeService.thumbnailFor(video.videoId);

    final placeholder = Container(
      color: AppColors.green,
      child: const Center(
        child: Icon(
          Icons.play_circle_fill_rounded,
          size: 56,
          color: AppColors.gold,
        ),
      ),
    );

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: AppColors.deepGreen.withValues(alpha: 0.65),
            border: Border.all(color: AppColors.gold.withValues(alpha: 0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(19)),
                child: AspectRatio(
                  aspectRatio: 16 / 9,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.network(
                        thumbnail,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => placeholder,
                      ),
                      Center(
                        child: Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.black.withValues(alpha: 0.55),
                            border: Border.all(color: AppColors.gold),
                          ),
                          child: const Icon(
                            Icons.play_arrow_rounded,
                            color: AppColors.gold,
                            size: 34,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(14),
                child: Text(
                  video.title,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    height: 1.5,
                    color: AppColors.cream,
                  ),
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
// _LocalVideoCard — فيديو من القائمة الثابتة (fallback)
// ============================================================
class _LocalVideoCard extends StatelessWidget {
  final ChannelVideo video;
  final VoidCallback onTap;

  const _LocalVideoCard({
    required this.video,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final thumbnail = video.thumbnailUrl;
    final placeholder = Container(
      color: AppColors.green,
      child: const Center(
        child: Icon(
          Icons.play_circle_fill_rounded,
          size: 56,
          color: AppColors.gold,
        ),
      ),
    );
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: AppColors.deepGreen.withValues(alpha: 0.65),
            border: Border.all(color: AppColors.gold.withValues(alpha: 0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(19)),
                child: AspectRatio(
                  aspectRatio: 16 / 9,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      if (thumbnail != null)
                        Image.network(
                          thumbnail,
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) => placeholder,
                        )
                      else
                        placeholder,
                      Center(
                        child: Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.black.withValues(alpha: 0.55),
                            border: Border.all(color: AppColors.gold),
                          ),
                          child: const Icon(
                            Icons.play_arrow_rounded,
                            color: AppColors.gold,
                            size: 34,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(14),
                child: Text(
                  video.title,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    height: 1.5,
                    color: AppColors.cream,
                  ),
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
// _ChannelLogo
// ============================================================
class _ChannelLogo extends StatelessWidget {
  const _ChannelLogo();

  @override
  Widget build(BuildContext context) {
    return GlowSparks(
      spread: 40,
      sparks: 14,
      intensity: 1.25,
      child: Container(
        width: 132,
        height: 132,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.gold, width: 2),
          boxShadow: [
            BoxShadow(
              color: AppColors.gold.withValues(alpha: 0.45),
              blurRadius: 28,
            ),
          ],
        ),
        child: ClipOval(
          child: Image.asset(
            'assets/images/logo.png',
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => const Icon(
              Icons.play_circle_fill_rounded,
              size: 64,
              color: AppColors.gold,
            ),
          ),
        ),
      ),
    );
  }
}
