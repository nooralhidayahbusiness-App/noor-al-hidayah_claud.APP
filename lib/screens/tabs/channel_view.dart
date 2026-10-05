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
        return Directionality(
          textDirection: appState.direction,
          child: NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) => [
              SliverToBoxAdapter(
                child: _ChannelHeader(
                  onSubscribe: () => _open(
                    context,
                    kChannelUrl.isEmpty ? '' : subscribeUrl(kChannelUrl),
                  ),
                  onOpenChannel: () => _open(context, kChannelUrl),
                ),
              ),
              SliverPersistentHeader(
                pinned: true,
                delegate: _TabsDelegate(
                  tabBar: _buildTabBar(context),
                ),
              ),
            ],
            body: TabBarView(
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
        );
      },
    );
  }

  Widget _buildTabBar(BuildContext context) {
    return Container(
      color: AppColors.deepGreen,
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 8),
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
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
          unselectedLabelStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
          tabs: [
            Tab(
              height: 40,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.smart_display_rounded, size: 17),
                  const SizedBox(width: 6),
                  Text(appState.tr('cVideos')),
                ],
              ),
            ),
            Tab(
              height: 40,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.movie_filter_rounded, size: 17),
                  const SizedBox(width: 6),
                  Text(appState.tr('cReels')),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TabsDelegate extends SliverPersistentHeaderDelegate {
  final Widget tabBar;

  _TabsDelegate({required this.tabBar});

  @override
  double get minExtent => 58;
  @override
  double get maxExtent => 58;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Material(
      color: AppColors.deepGreen,
      elevation: overlapsContent ? 4 : 0,
      shadowColor: Colors.black.withValues(alpha: 0.4),
      child: tabBar,
    );
  }

  @override
  bool shouldRebuild(covariant _TabsDelegate oldDelegate) => false;
}

class _ChannelHeader extends StatelessWidget {
  final VoidCallback onSubscribe;
  final VoidCallback onOpenChannel;

  const _ChannelHeader({
    required this.onSubscribe,
    required this.onOpenChannel,
  });

  @override
  Widget build(BuildContext context) {
    final name = appState.tr('appName');

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: GlassCard(
        ornament: false,
        child: Column(
          children: [
            Row(
              children: [
                _ChannelLogo(size: R.s(context, 72)),
                SizedBox(width: R.s(context, 12)),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: brandStyle(
                          name,
                          fontSize: R.f(context, 20),
                          color: AppColors.softGold,
                        ),
                      ),
                      SizedBox(height: R.s(context, 3)),
                      Row(
                        children: [
                          Icon(
                            Icons.verified,
                            color: AppColors.gold,
                            size: R.s(context, 12),
                          ),
                          SizedBox(width: R.s(context, 3)),
                          Flexible(
                            child: Text(
                              kChannelHandle,
                              textDirection: TextDirection.ltr,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: R.f(context, 12),
                                color: AppColors.cream.withValues(alpha: 0.7),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: R.s(context, 12)),
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: R.s(context, 44),
                    child: ElevatedButton.icon(
                      onPressed: onSubscribe,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.gold,
                        foregroundColor: AppColors.deepGreen,
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(R.s(context, 22)),
                        ),
                        elevation: 4,
                      ),
                      icon: Icon(
                        Icons.notifications_active_rounded,
                        size: R.s(context, 18),
                      ),
                      label: Text(
                        appState.tr('subscribe'),
                        style: TextStyle(
                          fontSize: R.f(context, 13.5),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: R.s(context, 8)),
                GestureDetector(
                  onTap: onOpenChannel,
                  child: Container(
                    width: R.s(context, 44),
                    height: R.s(context, 44),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(R.s(context, 14)),
                      border: Border.all(
                        color: AppColors.gold.withValues(alpha: 0.6),
                      ),
                    ),
                    child: Icon(
                      Icons.open_in_new_rounded,
                      color: AppColors.softGold,
                      size: R.s(context, 18),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

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
        final firestoreVideos = (snap.data ?? [])
            .where((v) => v.isReel == isReel)
            .toList();

        final oldVideos =
            !isReel ? kChannelVideos.reversed.toList() : <ChannelVideo>[];

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
                    ? appState.tr('cNoReelsYet')
                    : appState.tr('cVideosSoon'),
                textAlign: TextAlign.center,
                style: TextStyle(
                  height: 1.6,
                  color: AppColors.cream.withValues(alpha: 0.7),
                ),
              ),
            ),
          );
        }

        if (isReel && firestoreVideos.isNotEmpty) {
          return GridView.builder(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 12,
              childAspectRatio: 0.62,
            ),
            itemCount: firestoreVideos.length,
            itemBuilder: (context, i) {
              final v = firestoreVideos[i];
              return _VideoCard(
                title: v.title,
                thumbnailUrl: v.thumbnailUrl.isNotEmpty
                    ? v.thumbnailUrl
                    : YouTubeService.thumbnailFor(v.videoId),
                isReel: true,
                onTap: () => onOpen(v.url),
              );
            },
          );
        }

        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          children: [
            for (final v in firestoreVideos)
              Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: _VideoCard(
                  title: v.title,
                  thumbnailUrl: v.thumbnailUrl.isNotEmpty
                      ? v.thumbnailUrl
                      : YouTubeService.thumbnailFor(v.videoId),
                  isReel: false,
                  onTap: () => onOpen(v.url),
                ),
              ),
            if (hasFirestore && hasOld)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
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
                        appState.tr('cPreviousVideos'),
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
        width: isReel ? 44 : 56,
        height: isReel ? 44 : 56,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.black.withValues(alpha: 0.55),
          border: Border.all(color: AppColors.gold),
        ),
        child: Icon(
          Icons.play_arrow_rounded,
          color: AppColors.gold,
          size: isReel ? 28 : 34,
        ),
      ),
    );

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
                Expanded(
                  child: ClipRRect(
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(15)),
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
                  padding: const EdgeInsets.all(8),
                  child: Text(
                    title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      height: 1.3,
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

class _ChannelLogo extends StatelessWidget {
  final double size;

  const _ChannelLogo({required this.size});

  @override
  Widget build(BuildContext context) {
    return GlowSparks(
      spread: size * 0.35,
      sparks: 10,
      intensity: 1.0,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.gold, width: 1.8),
          boxShadow: [
            BoxShadow(
              color: AppColors.gold.withValues(alpha: 0.4),
              blurRadius: size * 0.2,
            ),
          ],
        ),
        child: ClipOval(
          child: Image.asset(
            'assets/images/logo.png',
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Icon(
              Icons.play_circle_fill_rounded,
              size: size * 0.5,
              color: AppColors.gold,
            ),
          ),
        ),
      ),
    );
  }
}
