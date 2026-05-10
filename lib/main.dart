import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Prefer local .env if the developer set one up, otherwise fall back to the
  // bundled .env.example so a fresh clone always boots.
  try {
    await dotenv.load(fileName: '.env');
  } catch (_) {
    try {
      await dotenv.load(fileName: '.env.example');
    } catch (_) {
      // last-resort defaults are baked into ApiClient
    }
  }
  runApp(const ProviderScope(child: IpotApp()));
}
