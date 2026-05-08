import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Currently active table id (set after a successful QR scan or manual entry).
final activeTableProvider = StateProvider<String?>((ref) => null);
