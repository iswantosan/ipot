/// Parses a QR payload of the form `ipot://table/{tableId}` and returns
/// the table id, or null when the payload doesn't match.
String? parseTableQr(String? raw) {
  if (raw == null) return null;
  final value = raw.trim();
  if (value.isEmpty) return null;

  // Tolerate either ipot://table/T001 or http(s)://.../table/T001
  final uri = Uri.tryParse(value);
  if (uri == null) return null;

  if (uri.scheme == 'ipot' && uri.host == 'table') {
    final id = uri.pathSegments.isNotEmpty ? uri.pathSegments.first : '';
    return id.isEmpty ? null : id;
  }

  // Fallback: anything that ends with /table/{id}
  final segs = uri.pathSegments;
  for (var i = 0; i < segs.length - 1; i++) {
    if (segs[i] == 'table' && segs[i + 1].isNotEmpty) {
      return segs[i + 1];
    }
  }
  return null;
}
