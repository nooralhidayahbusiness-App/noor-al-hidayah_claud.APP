import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';

import '../core/app_state.dart';
import '../core/prayer_state.dart';
import '../core/responsive.dart';
import '../core/theme.dart';
import '../models/mosque.dart';
import '../services/mosques_service.dart';
import '../widgets/auth_widgets.dart';
import '../widgets/themed_background.dart';

class MosquesScreen extends StatefulWidget {
  const MosquesScreen({super.key});

  @override
  State<MosquesScreen> createState() => _MosquesScreenState();
}

class _MosquesScreenState extends State<MosquesScreen> {
  final MapController _mapController = MapController();

  bool _loading = true;
  String? _error;
  List<Mosque> _mosques = [];
  Mosque? _selected;
  int _radiusKm = 10;

  late LatLng _userLatLng;

  @override
  void initState() {
    super.initState();
    final loc = prayerState.location;
    _userLatLng = LatLng(
      loc?.latitude ?? 24.4539, // أبو ظبي افتراضياً
      loc?.longitude ?? 54.3773,
    );
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      debugPrint(
          '🔍 Search: ${_userLatLng.latitude}, ${_userLatLng.longitude} (${_radiusKm}km)');
      final list = await mosquesService.findNearby(
        latitude: _userLatLng.latitude,
        longitude: _userLatLng.longitude,
        radiusMeters: _radiusKm * 1000,
      );
      debugPrint('✅ Found: ${list.length}');
      if (!mounted) return;
      setState(() {
        _mosques = list;
        _loading = false;
      });
    } catch (e) {
      debugPrint('❌ Error: $e');
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  void _onMosqueTap(Mosque m) {
    setState(() => _selected = m);
    _mapController.move(
      LatLng(m.latitude, m.longitude),
      _mapController.camera.zoom,
    );
  }

  Future<void> _openInMaps(Mosque m) async {
    final googleUrl = Uri.parse(
      'https://www.google.com/maps/dir/?api=1'
      '&destination=${m.latitude},${m.longitude}',
    );
    final appleUrl = Uri.parse(
      'https://maps.apple.com/?daddr=${m.latitude},${m.longitude}',
    );

    try {
      if (await canLaunchUrl(googleUrl)) {
        await launchUrl(googleUrl, mode: LaunchMode.externalApplication);
      } else if (await canLaunchUrl(appleUrl)) {
        await launchUrl(appleUrl, mode: LaunchMode.externalApplication);
      } else {
        throw 'no_app';
      }
    } catch (_) {
      if (mounted) {
        showAuthMessage(context, appState.tr('mosquesNoMapsApp'),
            error: true);
      }
    }
  }

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
                      appState.tr('nearbyMosques'),
                      style: TextStyle(
                        fontSize: R.f(context, 15),
                        fontWeight: FontWeight.w700,
                        color: AppColors.softGold,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const AuthLanguageButton(),
                  ],
                ),
              ),

              SizedBox(height: R.s(context, 6)),

              // ===== الخريطة (60%) =====
              Expanded(
                flex: 6,
                child: Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: R.s(context, 12)),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Stack(
                      children: [
                        _buildMap(),
                        Positioned(
                          top: 8,
                          right: 8,
                          child: _CircleButton(
                            icon: Icons.refresh_rounded,
                            onTap: _load,
                          ),
                        ),
                        Positioned(
                          top: 8,
                          left: 8,
                          child: _RadiusChip(
                            km: _radiusKm,
                            onTap: _openRadiusPicker,
                          ),
                        ),
                        if (_loading)
                          const Center(
                            child: CircularProgressIndicator(
                                color: AppColors.gold),
                          ),
                        if (_error != null && !_loading)
                          Center(
                            child: Container(
                              padding: EdgeInsets.all(R.s(context, 12)),
                              decoration: BoxDecoration(
                                color: AppColors.deepGreen
                                    .withValues(alpha: 0.95),
                                borderRadius: BorderRadius.circular(12),
                                border:
                                    Border.all(color: AppColors.gold),
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.error_outline_rounded,
                                      color: AppColors.gold,
                                      size: R.s(context, 30)),
                                  SizedBox(height: R.s(context, 8)),
                                  Text(
                                    appState.tr('mosquesError'),
                                    style: TextStyle(
                                      color: AppColors.cream,
                                      fontSize: R.f(context, 12),
                                    ),
                                  ),
                                  SizedBox(height: R.s(context, 8)),
                                  TextButton(
                                    onPressed: _load,
                                    child: Text(
                                      appState.tr('retry'),
                                      style: const TextStyle(
                                          color: AppColors.gold),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),

              SizedBox(height: R.s(context, 8)),

              // ===== القائمة (40%) =====
              Expanded(
                flex: 4,
                child: _buildList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMap() {
    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(
        initialCenter: _userLatLng,
        initialZoom: 14,
        minZoom: 5,
        maxZoom: 19,
        backgroundColor: AppColors.deepGreen,
      ),
      children: [
        TileLayer(
          urlTemplate:
              'https://server.arcgisonline.com/ArcGIS/rest/services/Canvas/World_Dark_Gray_Base/MapServer/tile/{z}/{y}/{x}',
          userAgentPackageName: 'noor.al.hidayah.app',
        ),
        MarkerLayer(
          markers: [
            Marker(
              point: _userLatLng,
              width: 40,
              height: 40,
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color:
                      const Color(0xFF2196F3).withValues(alpha: 0.3),
                  border: Border.all(
                    color: const Color(0xFF2196F3),
                    width: 2,
                  ),
                ),
                child: const Icon(
                  Icons.my_location_rounded,
                  color: Color(0xFF2196F3),
                  size: 18,
                ),
              ),
            ),
          ],
        ),
        MarkerLayer(
          markers: _mosques.map((m) {
            final selected = _selected?.id == m.id;
            return Marker(
              point: LatLng(m.latitude, m.longitude),
              width: selected ? 48 : 36,
              height: selected ? 48 : 36,
              child: GestureDetector(
                onTap: () => _onMosqueTap(m),
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color:
                        AppColors.deepGreen.withValues(alpha: 0.95),
                    border: Border.all(
                      color: AppColors.gold,
                      width: selected ? 3 : 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.gold.withValues(
                            alpha: selected ? 0.7 : 0.4),
                        blurRadius: selected ? 14 : 8,
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.mosque_rounded,
                    color: AppColors.gold,
                    size: selected ? 24 : 18,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildList() {
    if (_loading) {
      return const SizedBox.shrink();
    }
    if (_mosques.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(R.s(context, 20)),
          child: Text(
            appState.tr('mosquesNone'),
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.cream.withValues(alpha: 0.7),
              fontSize: R.f(context, 13),
            ),
          ),
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.fromLTRB(
        R.s(context, 12),
        0,
        R.s(context, 12),
        R.s(context, 12),
      ),
      itemCount: _mosques.length,
      itemBuilder: (context, i) {
        final m = _mosques[i];
        final selected = _selected?.id == m.id;
        return Padding(
          padding: EdgeInsets.only(bottom: R.s(context, 6)),
          child: _MosqueTile(
            mosque: m,
            selected: selected,
            onTap: () => _onMosqueTap(m),
            onNavigate: () => _openInMaps(m),
          ),
        );
      },
    );
  }

  void _openRadiusPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        padding: EdgeInsets.all(R.s(context, 16)),
        decoration: const BoxDecoration(
          color: AppColors.deepGreen,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
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
            SizedBox(height: R.s(context, 12)),
            Text(
              appState.tr('mosquesRadius'),
              style: TextStyle(
                fontSize: R.f(context, 14),
                fontWeight: FontWeight.w700,
                color: AppColors.softGold,
              ),
            ),
            SizedBox(height: R.s(context, 10)),
            for (final km in [1, 3, 5, 10])
              Padding(
                padding: EdgeInsets.only(bottom: R.s(context, 6)),
                child: GestureDetector(
                  onTap: () {
                    setState(() => _radiusKm = km);
                    Navigator.pop(context);
                    _load();
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(
                        vertical: R.s(context, 10)),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: _radiusKm == km
                          ? AppColors.gold.withValues(alpha: 0.2)
                          : Colors.black.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _radiusKm == km
                            ? AppColors.gold
                            : AppColors.gold.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Text(
                      '$km ${appState.tr('km')}',
                      style: TextStyle(
                        fontSize: R.f(context, 13),
                        fontWeight: FontWeight.w700,
                        color: _radiusKm == km
                            ? AppColors.gold
                            : AppColors.cream,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _MosqueTile extends StatelessWidget {
  const _MosqueTile({
    required this.mosque,
    required this.selected,
    required this.onTap,
    required this.onNavigate,
  });

  final Mosque mosque;
  final bool selected;
  final VoidCallback onTap;
  final VoidCallback onNavigate;

  @override
  Widget build(BuildContext context) {
    final dir =
        appState.isArabic ? mosque.cardinalAr() : mosque.cardinalEn();

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: EdgeInsets.all(R.s(context, 10)),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.gold.withValues(alpha: 0.18)
              : Colors.black.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected
                ? AppColors.gold
                : AppColors.gold.withValues(alpha: 0.3),
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: R.s(context, 42),
              height: R.s(context, 42),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.gold.withValues(alpha: 0.15),
                border: Border.all(
                    color: AppColors.gold.withValues(alpha: 0.6)),
              ),
              child: Icon(
                Icons.mosque_rounded,
                color: AppColors.gold,
                size: R.s(context, 20),
              ),
            ),
            SizedBox(width: R.s(context, 10)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    mosque.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: R.f(context, 13),
                      fontWeight: FontWeight.w700,
                      color: AppColors.softGold,
                    ),
                  ),
                  SizedBox(height: R.s(context, 3)),
                  Row(
                    children: [
                      Icon(Icons.straighten_rounded,
                          color: AppColors.gold.withValues(alpha: 0.8),
                          size: R.s(context, 11)),
                      SizedBox(width: R.s(context, 3)),
                      Text(
                        mosque.distanceText(),
                        style: TextStyle(
                          fontSize: R.f(context, 10.5),
                          color:
                              AppColors.cream.withValues(alpha: 0.8),
                        ),
                      ),
                      SizedBox(width: R.s(context, 8)),
                      Icon(Icons.explore_rounded,
                          color: AppColors.gold.withValues(alpha: 0.8),
                          size: R.s(context, 11)),
                      SizedBox(width: R.s(context, 3)),
                      Text(
                        dir,
                        style: TextStyle(
                          fontSize: R.f(context, 10.5),
                          color:
                              AppColors.cream.withValues(alpha: 0.8),
                        ),
                      ),
                    ],
                  ),
                  if (mosque.address != null &&
                      mosque.address!.isNotEmpty) ...[
                    SizedBox(height: R.s(context, 2)),
                    Text(
                      mosque.address!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: R.f(context, 10),
                        color: AppColors.cream.withValues(alpha: 0.55),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            IconButton(
              tooltip: appState.tr('mosquesNavigate'),
              onPressed: onNavigate,
              icon: Icon(
                Icons.directions_rounded,
                color: AppColors.gold,
                size: R.s(context, 20),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CircleButton extends StatelessWidget {
  const _CircleButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(R.s(context, 8)),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.deepGreen.withValues(alpha: 0.9),
          border: Border.all(color: AppColors.gold),
        ),
        child:
            Icon(icon, color: AppColors.gold, size: R.s(context, 18)),
      ),
    );
  }
}

class _RadiusChip extends StatelessWidget {
  const _RadiusChip({required this.km, required this.onTap});

  final int km;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: R.s(context, 10),
          vertical: R.s(context, 6),
        ),
        decoration: BoxDecoration(
          color: AppColors.deepGreen.withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.gold),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.radar_rounded,
                color: AppColors.gold, size: R.s(context, 12)),
            SizedBox(width: R.s(context, 4)),
            Text(
              '$km ${appState.tr('km')}',
              style: TextStyle(
                color: AppColors.gold,
                fontSize: R.f(context, 11),
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
