import 'dart:io';

import 'package:path_provider/path_provider.dart';

/// Stores raw menu JSON on local disk so the menu can be shown again when the
/// network is unavailable. Keyed by table id.
class MenuCache {
  Future<File> _file(String tableId) async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/ipot_menu_${tableId.toUpperCase()}.json');
  }

  Future<void> save(String tableId, String json) async {
    try {
      final file = await _file(tableId);
      await file.writeAsString(json);
    } catch (_) {
      // Best-effort. Cache failures should never surface to the user.
    }
  }

  Future<String?> load(String tableId) async {
    try {
      final file = await _file(tableId);
      if (!await file.exists()) return null;
      return await file.readAsString();
    } catch (_) {
      return null;
    }
  }
}
