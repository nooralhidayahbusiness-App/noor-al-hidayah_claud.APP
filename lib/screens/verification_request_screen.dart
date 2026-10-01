import 'dart:convert';

import 'package:flutter/material.dart';

import '../../core/app_state.dart';
import '../../core/responsive.dart';
import '../../core/theme.dart';
import '../../services/verification_service.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/themed_background.dart';

class VerificationRequestsScreen extends StatefulWidget {
  const VerificationRequestsScreen({super.key});

  @override
  State<VerificationRequestsScreen> createState() =>
      _VerificationRequestsScreenState();
}

class _VerificationRequestsScreenState
    extends State<VerificationRequestsScreen> {
  bool _loading = true;
  List<VerificationRequest> _requests = [];
  String? _busyUid;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final list = await verificationService.loadPendingRequests();
    if (mounted) {
      setState(() {
        _requests = list;
        _loading = false;
      });
    }
  }

  Future<void> _approve(VerificationRequest req, String type) async {
    setState(() => _busyUid = req.uid);
    try {
      await verificationService.approve(
        targetUid: req.uid,
        type: type,
      );
      if (mounted) {
        _showSnack(
          type == 'me'
              ? appState.tr('adminApprovedMe')
              : appState.tr('adminApprovedUser'),
        );
      }
      await _load();
    } catch (e) {
      if (mounted) _showSnack('Error: $e', error: true);
    } finally {
      if (mounted) setState(() => _busyUid = null);
    }
  }

  Future<void> _reject(VerificationRequest req) async {
    setState(() => _busyUid = req.uid);
    try {
      await verificationService.reject(targetUid: req.uid);
      if (mounted) _showSnack(appState.tr('adminRejected'));
      await _load();
    } catch (e) {
      if (mounted) _showSnack('Error: $e', error: true);
    } finally {
      if (mounted) setState(() => _busyUid = null);
    }
  }

  void _showSnack(String msg, {bool error = false}) {
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
                      appState.tr('adminVerificationRequests'),
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
                child: _loading
                    ? const Center(
                        child: CircularProgressIndicator(
                            color: AppColors.gold))
                    : _requests.isEmpty
                        ? Center(
                            child: Padding(
                              padding:
                                  EdgeInsets.all(R.s(context, 20)),
                              child: Text(
                                appState.tr('adminNoRequests'),
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: R.f(context, 14),
                                  color: AppColors.cream
                                      .withValues(alpha: 0.7),
                                ),
                              ),
                            ),
                          )
                        : ListView.builder(
                            padding: EdgeInsets.all(R.s(context, 14)),
                            itemCount: _requests.length,
                            itemBuilder: (context, i) => Padding(
                              padding: EdgeInsets.only(
                                  bottom: R.s(context, 10)),
                              child: _RequestCard(
                                request: _requests[i],
                                busy: _busyUid == _requests[i].uid,
                                onApproveUser: () => _approve(
                                    _requests[i], 'user'),
                                onApproveMe: () =>
                                    _approve(_requests[i], 'me'),
                                onReject: () =>
                                    _reject(_requests[i]),
                              ),
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

class _RequestCard extends StatelessWidget {
  const _RequestCard({
    required this.request,
    required this.busy,
    required this.onApproveUser,
    required this.onApproveMe,
    required this.onReject,
  });

  final VerificationRequest request;
  final bool busy;
  final VoidCallback onApproveUser;
  final VoidCallback onApproveMe;
  final VoidCallback onReject;

  @override
  Widget build(BuildContext context) {
    final genderAr = request.gender == 'woman' ? 'امرأة' : 'رجل';
    final date = request.requestedDate;

    return GlassCard(
      ornament: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              // الصورة
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  width: R.s(context, 70),
                  height: R.s(context, 70),
                  color: Colors.black.withValues(alpha: 0.3),
                  child: request.photoBase64.isEmpty
                      ? Icon(Icons.person, color: AppColors.gold)
                      : Image.memory(
                          base64Decode(request.photoBase64),
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) => Icon(
                            Icons.person,
                            color: AppColors.gold,
                          ),
                        ),
                ),
              ),
              SizedBox(width: R.s(context, 12)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      request.name.isEmpty ? 'User' : request.name,
                      style: TextStyle(
                        fontSize: R.f(context, 14),
                        fontWeight: FontWeight.w700,
                        color: AppColors.softGold,
                      ),
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
                      '$genderAr • ${date.day}/${date.month}/${date.year}',
                      style: TextStyle(
                        fontSize: R.f(context, 10.5),
                        color: AppColors.gold.withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: R.s(context, 12)),

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
                    icon: Icons.verified_rounded,
                    label: appState.tr('adminApproveUser'),
                    color: AppColors.gold,
                    onTap: onApproveUser,
                  ),
                ),
                SizedBox(width: R.s(context, 6)),
                Expanded(
                  child: _ActionBtn(
                    icon: Icons.workspace_premium_rounded,
                    label: appState.tr('adminApproveMe'),
                    color: const Color(0xFFFFA000),
                    onTap: onApproveMe,
                  ),
                ),
                SizedBox(width: R.s(context, 6)),
                _ActionBtn(
                  icon: Icons.close_rounded,
                  label: appState.tr('adminReject'),
                  color: const Color(0xFFD32F2F),
                  iconOnly: true,
                  onTap: onReject,
                ),
              ],
            ),
        ],
      ),
    );
  }
}

class _ActionBtn extends StatelessWidget {
  const _ActionBtn({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
    this.iconOnly = false,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  final bool iconOnly;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: R.s(context, 8),
          vertical: R.s(context, 10),
        ),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color, width: 1.2),
        ),
        child: iconOnly
            ? Icon(icon, color: color, size: R.s(context, 20))
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, color: color, size: R.s(context, 16)),
                  SizedBox(width: R.s(context, 4)),
                  Flexible(
                    child: Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: R.f(context, 10.5),
                        fontWeight: FontWeight.w700,
                        color: color,
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
