import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

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
  final _controller = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
    facing: CameraFacing.back,
  );
  bool _handled = false;
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (_handled) return;
    for (final b in capture.barcodes) {
      final raw = b.rawValue;
      final tableId = parseTableQr(raw);
      if (tableId != null) {
        _accept(tableId);
        return;
      }
    }
    setState(() {
      _error = AppLocalizations.of(context)!.scanInvalid;
    });
  }

  void _accept(String tableId) {
    _handled = true;
    ref.read(activeTableProvider.notifier).state = tableId;
    ref.read(cartProvider.notifier).setTable(tableId);
    _controller.stop();
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
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(l.actionCancel)),
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
    final l = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l.scanTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.flash_on),
            onPressed: () => _controller.toggleTorch(),
          ),
          IconButton(
            icon: const Icon(Icons.cameraswitch),
            onPressed: () => _controller.switchCamera(),
          ),
        ],
      ),
      body: Stack(
        children: [
          MobileScanner(
            controller: _controller,
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
                  if (_error != null)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.7),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        _error!,
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
