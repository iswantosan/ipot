import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import 'l10n/generated/app_localizations.dart';
import 'navigation/router.dart';

final _router = buildRouter();

class IpotApp extends ConsumerWidget {
  const IpotApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      builder: (context, _) {
        final base = ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFE94B3C)),
          useMaterial3: true,
          scaffoldBackgroundColor: const Color(0xFFFAFAFA),
        );
        return MaterialApp.router(
          onGenerateTitle: (ctx) => AppLocalizations.of(ctx)!.appTitle,
          debugShowCheckedModeBanner: false,
          theme: base.copyWith(
            textTheme: GoogleFonts.plusJakartaSansTextTheme(base.textTheme),
            primaryTextTheme: GoogleFonts.plusJakartaSansTextTheme(base.primaryTextTheme),
          ),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          routerConfig: _router,
        );
      },
    );
  }
}
