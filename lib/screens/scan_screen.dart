import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';

import '../l10n/generated/app_localizations.dart';
import '../navigation/routes.dart';
import '../state/cart_state.dart';
import '../state/session_state.dart';
import '../utils/qr.dart';

class ScanScreen extends ConsumerStatefulWidget {
  const ScanScreen({super.key});

  @override
  ConsumerState<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends ConsumerState<ScanScreen> {
  MobileScannerController? _controller;
  bool _scanning = false;
  bool _handled = false;
  String? _bannerError;

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _startScan() async {
    final status = await Permission.camera.status;
    if (status.isGranted) {
      _enterScanner();
      return;
    }
    if (!mounted) return;
    final granted = await _showPermissionSheet();
    if (granted == true && mounted) _enterScanner();
  }

  void _enterScanner() {
    _controller ??= MobileScannerController(
      detectionSpeed: DetectionSpeed.noDuplicates,
      facing: CameraFacing.back,
    );
    setState(() => _scanning = true);
  }

  Future<bool?> _showPermissionSheet() {
    final l = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(24, 16, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              SizedBox(height: 24.h),
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(Icons.qr_code_scanner_rounded,
                    color: theme.colorScheme.primary, size: 32),
              ),
              SizedBox(height: 16.h),
              Text(
                l.permissionCameraTitle,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                l.permissionCameraBody,
                style: theme.textTheme.bodyMedium?.copyWith(color: Colors.black54),
              ),
              SizedBox(height: 24.h),
              SizedBox(
                height: 52.h,
                child: FilledButton.icon(
                  onPressed: () async {
                    final res = await Permission.camera.request();
                    if (!ctx.mounted) return;
                    if (res.isGranted) {
                      Navigator.pop(ctx, true);
                    } else if (res.isPermanentlyDenied) {
                      Navigator.pop(ctx, false);
                      if (mounted) _showDeniedDialog();
                    } else {
                      Navigator.pop(ctx, false);
                    }
                  },
                  icon: const Icon(Icons.camera_alt_rounded),
                  label: Text(l.permissionAllow),
                ),
              ),
              SizedBox(height: 8.h),
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: Text(l.permissionNotNow),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showDeniedDialog() async {
    final l = AppLocalizations.of(context)!;
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l.permissionDeniedTitle),
        content: Text(l.permissionDeniedBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l.actionCancel),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              openAppSettings();
            },
            child: Text(l.permissionOpenSettings),
          ),
        ],
      ),
    );
  }

  void _onDetect(BarcodeCapture capture) {
    if (_handled) return;
    for (final b in capture.barcodes) {
      final tableId = parseTableQr(b.rawValue);
      if (tableId != null) {
        _accept(tableId);
        return;
      }
    }
    setState(() {
      _bannerError = AppLocalizations.of(context)!.scanInvalid;
    });
  }

  void _accept(String tableId) {
    _handled = true;
    ref.read(activeTableProvider.notifier).state = tableId;
    ref.read(cartProvider.notifier).setTable(tableId);
    _controller?.stop();
    if (mounted) context.go(AppRoutes.menu);
  }

  Future<void> _manualEntry() async {
    final l = AppLocalizations.of(context)!;
    final controller = TextEditingController(text: 'T001');
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l.scanEnterTableId),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(hintText: l.scanTableHint),
          textCapitalization: TextCapitalization.characters,
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(l.actionCancel)),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, controller.text.trim()),
            child: Text(l.actionOpenMenu),
          ),
        ],
      ),
    );
    if (result != null && result.isNotEmpty) _accept(result.toUpperCase());
  }

  @override
  Widget build(BuildContext context) {
    return _scanning ? _buildScannerView() : _buildIntroView();
  }

  Widget _buildIntroView() {
    final l = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              theme.colorScheme.primary,
              const Color(0xFFB1352C),
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                SizedBox(height: 24.h),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'IPOT',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 13.sp,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                Container(
                  width: 160,
                  height: 160,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(36),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.25), width: 1.5),
                  ),
                  child: const Icon(Icons.qr_code_scanner_rounded,
                      size: 96, color: Colors.white),
                ),
                SizedBox(height: 24.h),
                Text(
                  l.scanTitle,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28.sp,
                    fontWeight: FontWeight.w800,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 8.h),
                Text(
                  l.scanTagline,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.85),
                    fontSize: 15.sp,
                  ),
                  textAlign: TextAlign.center,
                ),
                const Spacer(),
                SizedBox(
                  width: double.infinity,
                  height: 56.h,
                  child: FilledButton.icon(
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: theme.colorScheme.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    onPressed: _startScan,
                    icon: const Icon(Icons.qr_code_scanner_rounded),
                    label: Text(
                      l.scanTitle,
                      style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16.sp),
                    ),
                  ),
                ),
                SizedBox(height: 12.h),
                TextButton.icon(
                  onPressed: _manualEntry,
                  icon: const Icon(Icons.keyboard, color: Colors.white),
                  label: Text(
                    l.scanManualEntry,
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                SizedBox(height: 16.h),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildScannerView() {
    final l = AppLocalizations.of(context)!;
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
        title: Text(l.scanTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.flash_on),
            onPressed: () => _controller?.toggleTorch(),
          ),
          IconButton(
            icon: const Icon(Icons.cameraswitch),
            onPressed: () => _controller?.switchCamera(),
          ),
        ],
      ),
      body: Stack(
        children: [
          MobileScanner(
            controller: _controller!,
            onDetect: _onDetect,
            errorBuilder: (ctx, err, child) => _PermissionFallback(
              error: err.errorDetails?.message ?? err.toString(),
              onManual: _manualEntry,
            ),
          ),
          Center(
            child: Container(
              width: 240,
              height: 240,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white, width: 2),
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 32,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  if (_bannerError != null)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.7),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        _bannerError!,
                        style: const TextStyle(color: Colors.white),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      l.scanHint,
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextButton.icon(
                    onPressed: _manualEntry,
                    icon: const Icon(Icons.keyboard, color: Colors.white),
                    label: Text(
                      l.scanManualEntry,
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PermissionFallback extends StatelessWidget {
  const _PermissionFallback({required this.error, required this.onManual});
  final String error;
  final VoidCallback onManual;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.camera_alt_outlined, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          Text(l.scanCameraUnavailable, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Text(error, textAlign: TextAlign.center, style: const TextStyle(color: Colors.grey)),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: onManual,
            icon: const Icon(Icons.keyboard),
            label: Text(l.scanEnterTableId),
          ),
        ],
      ),
    );
  }
}
