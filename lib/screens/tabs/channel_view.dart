import 'package:flutter/material.dart';

import '../../core/app_state.dart';
import '../../core/channel_config.dart';
import '../../core/fonts.dart';
import '../../core/theme.dart';
import '../../services/link_service.dart';
import '../../widgets/auth_widgets.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/ornament_medallion.dart';

/// "قناتي": channel card with a subscribe button and the list of videos.
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
            GlassCard(
              child: Column(
                children: [
                  const OrnamentMedallion(
                    size: 96,
                    child: Padding(
                      padding: EdgeInsets.all(2),
                      child: SymbolImage(
                        'assets/images/logo.png',
                        fallback: Icons.play_circle_fill_rounded,
                      ),
                    ),
                  ),
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
            if (kChannelVideos.isEmpty)
              Text(
                appState.tr('videosSoon'),
                textAlign: TextAlign.center,
                style: TextStyle(
                  height: 1.6,
                  color: AppColors.cream.withValues(alpha: 0.7),
                ),
              )
            else
              for (final video in kChannelVideos)
                Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: _VideoCard(
                    video: video,
                    onTap: () => _open(context, video.url),
                  ),
                ),
          ],
        );
      },
    );
  }
}

class _VideoCard extends StatelessWidget {
  const _VideoCard({required this.video, required this.onTap});

  final ChannelVideo video;
  final VoidCallback onTap;

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
                          errorBuilder: (context, error, stackTrace) =>
                              placeholder,
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
