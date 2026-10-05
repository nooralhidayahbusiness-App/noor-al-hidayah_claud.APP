import 'package:flutter/material.dart';

import '../../core/app_state.dart';
import '../../core/channel_config.dart';
import '../../core/fonts.dart';
import '../../core/theme.dart';
import '../../models/channel_video_data.dart';
import '../../services/link_service.dart';
import '../../services/youtube_service.dart';
import '../../widgets/auth_widgets.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/glow_sparks.dart';

class ChannelView extends StatefulWidget {
  const ChannelView({super.key});

  @override
  State<ChannelView> createState() => _ChannelViewState();
}

class _ChannelViewState extends State<ChannelView>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

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
        return Column(
          children: [
            // ===== بطاقة القناة =====
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
              child: GlassCard(
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
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: GoldButton(
                            label: appState.tr('subscribe'),
                            onPressed: () => _open(
                              context,
                              kChannelUrl.isEmpty
                                  ? ''
                                  : subscribeUrl(kChannelUrl),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        _IconBtn(
                          icon: Icons.open_in_new_rounded,
                          onTap: () => _open(context, kChannelUrl),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 14),

            // ===== التابات =====
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  color: AppColors.deepGreen.withValues(alpha: 0.65),
                  border: Border.all(
                    color: AppColors.gold.withValues(alpha: 0.3),
                  ),
                ),
                child: TabBar(
                  controller: _tabs,
                  indicator: BoxDecoration(
                    borderRadius: BorderRadius.circular(26),
                    color: AppColors.gold,
                  ),
                  indicatorSize: TabBarIndicatorSize.tab,
                  dividerColor: Colors.transparent,
                  labelColor: AppColors.deepGreen,
                  unselectedLabelColor: AppColors.softGold,
                  labelStyle: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                  unselectedLabelStyle: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                  tabs: const [
                    Tab(
                      height: 44,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.smart_display_rounded, size: 18),
                          SizedBox(width: 6),
                          Text('الفيديوهات'),
                        ],
                      ),
                    ),
                    Tab(
                      height: 44,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.movie_filter_rounded, size: 18),
                          SizedBox(width: 6),
                          Text('الريلز'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),

            // ===== المحتوى =====
            Expanded(
              child: TabBarView(
                controller: _tabs,
                children: [
                  _VideoList(
                    isReel: false,
                    onOpen: (url) => _open(context, url),
                  ),
                  _VideoList(
                    isReel: true,
                    onOpen: (url) => _open(context, url),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

// ============================================================
// _VideoList — يجلب من Firestore + يدمج مع القائمة القديمة
// ============================================================
class _VideoList extends StatelessWidget {
  final bool isReel;
  final void Function(String url) onOpen;

  const _VideoList({
    required this.isReel,
    required this.onOpen,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<ChannelVideoData>>(
      stream: youtubeService.stream(),
      builder: (context, snap) {
        // ===== اللي من Firestore (نفلتر حسب النوع) =====
        final firestoreVideos = (snap.data ?? [])
            .where((v) => v.isReel == isReel)
            .toList();

        // ===== اللي من القائمة القديمة (فقط في تاب الفيديوهات) =====
        final oldVideos = !isReel ? kChannelVideos.reversed.toList() : [];

        final hasFirestore = firestoreVideos.isNotEmpty;
        final hasOld = oldVideos.isNotEmpty;
        final loading =
            snap.connectionState == ConnectionState.waiting && !snap.hasData;

        if (loading) {
          return const Center(
            child: CircularProgressIndicator(
              color: AppColors.gold,
              strokeWidth: 2,
            ),
          );
        }

        if (!hasFirestore && !hasOld) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                isReel
                    ? 'لا توجد ريلز بعد'
                    : appState.tr('videosSoon'),
                textAlign: TextAlign.center,
                style: TextStyle(
                  height: 1.6,
                  color: AppColors.cream.withValues(alpha: 0.7),
                ),
              ),
            ),
          );
        }

        return ListView(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
          children: [
            // ===== Firestore Videos =====
            for (final v in firestoreVideos)
              Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: _VideoCard(
                  title: v.title,
                  thumbnailUrl: v.thumbnailUrl.isNotEmpty
                      ? v.thumbnailUrl
                      : YouTubeService.thumbnailFor(v.videoId),
                  isReel: v.isReel,
                  onTap: () => onOpen(v.url),
                ),
              ),

            // ===== فاصل إذا فيه قائمتين =====
            if (hasFirestore && hasOld)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: Divider(
                        color: AppColors.gold.withValues(alpha: 0.3),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Text(
                        'فيديوهات سابقة',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.cream.withValues(alpha: 0.5),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Divider(
                        color: AppColors.gold.withValues(alpha: 0.3),
                      ),
                    ),
                  ],
                ),
              ),

            // ===== Old Videos =====
            for (final v in oldVideos)
              Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: _VideoCard(
                  title: v.title,
                  thumbnailUrl: v.thumbnailUrl ?? '',
                  isReel: false,
                  onTap: () => onOpen(v.url),
                ),
              ),
          ],
        );
      },
    );
  }
}

// ============================================================
// _VideoCard — يعرض 16:9 أو 9:16
// ============================================================
class _VideoCard extends StatelessWidget {
  final String title;
  final String thumbnailUrl;
  final bool isReel;
  final VoidCallback onTap;

  const _VideoCard({
    required this.title,
    required this.thumbnailUrl,
    required this.isReel,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
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

    final thumbWidget = thumbnailUrl.isNotEmpty
        ? Image.network(
            thumbnailUrl,
            fit: BoxFit.cover,
            errorBuilder: (_, _, _) => placeholder,
          )
        : placeholder;

    final playBtn = Center(
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
    );

    // ===== ريلز: عمودي (شبكة 2) =====
    if (isReel) {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Ink(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: AppColors.deepGreen.withValues(alpha: 0.65),
              border:
                  Border.all(color: AppColors.gold.withValues(alpha: 0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(15)),
                  child: AspectRatio(
                    aspectRatio: 9 / 16,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        thumbWidget,
                        playBtn,
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: Text(
                    title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      height: 1.4,
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

    // ===== فيديو عادي: 16:9 =====
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
                      thumbWidget,
                      playBtn,
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(14),
                child: Text(
                  title,
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
// _IconBtn
// ============================================================
class _IconBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _IconBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.gold.withValues(alpha: 0.6)),
        ),
        child: Icon(icon, color: AppColors.softGold, size: 20),
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
