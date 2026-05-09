# IPOT Order

Customer-side QR ordering app for IPOT. Scan the QR on a table → browse the menu → build a cart with customizations → submit the order → track its status until served.

Built with Flutter (Dart) for Android & iOS.

## Features

- **QR scanner** with manual table-id fallback (for emulators or damaged codes)
- **Menu browser** with category tabs + cross-category search
- **Item detail** with required & multi-select customization picker, quantity stepper, kitchen note
- **Cart** with line dedup logic (same selections merge, different selections stay separate)
- **Order submission** wired to `POST /api/v1/orders` (mock or live)
- **Order status tracking** with live polling — `pending → confirmed → preparing → ready → served`
- **i18n** with English + Indonesian (Bahasa) via Flutter `gen-l10n` + ARB files
- **Mock-first API layer** so the whole flow runs without a live backend
- Plus Jakarta Sans typography (Google Fonts), responsive sizing (flutter_screenutil), branded launcher icon + native splash

## Getting started

```bash
# 1. Install deps
flutter pub get

# 2. Set up env (defaults to mock API)
cp .env.example .env

# 3. Run on a connected device / emulator
flutter run
```

To build a release APK:

```bash
flutter build apk --release
# Output: build/app/outputs/flutter-apk/app-release.apk
```

### QR sample

The mock data ships with one table `T001`. Generate a QR pointing to:

```
ipot://table/T001
```

Or tap **Enter table ID manually** on the scan screen (useful on emulators with no camera).

### Env vars

| Key | Default | What it does |
| --- | --- | --- |
| `API_BASE_URL` | `https://api.ipot.example.com` | Base URL when `USE_MOCK=false` |
| `USE_MOCK` | `true` | Use bundled mock services instead of live API |

### Locale

The app respects the device locale. `en` and `id` are bundled. Test the Indonesian copy by setting your device language to **Bahasa Indonesia**.

## Project layout

```
lib/
├── api/         # ApiClient + Menu/Order APIs (live + mock impls)
├── models/      # Menu, MenuItem, Customization, Cart, Order, ...
├── state/       # Riverpod providers (cart, menu, session, order tracking)
├── navigation/  # go_router config & route names
├── screens/     # Screen widgets (scan, menu, item, cart, order status)
├── widgets/     # Reusable widgets (cards, stepper, summary bar)
├── utils/       # formatters, qr parser
└── l10n/
    ├── app_en.arb           # English source
    ├── app_id.arb           # Indonesian translation
    └── generated/           # Generated AppLocalizations classes
assets/
├── mock/        # Bundled menu JSON used by MockMenuApi
└── branding/    # Source PNGs for launcher icon & splash
test/            # Unit tests (cart math, qr parsing, customization)
```

## Architecture notes

- **Mock vs live API** is a single env-driven switch (`USE_MOCK`). The app picks `MockMenuApi` / `MockOrderApi` or the dio-backed implementations at provider construction. No code change needed to flip.
- **Cart line de-dup**: items added with the same customization set merge into one line and bump quantity; different selections stay as separate lines (e.g. one Mild Ramen + one Extra Spicy Ramen). See `CartController._lineKey`.
- **Order tracking** uses an `autoDispose` `StreamProvider.family` that polls the order endpoint every 4 s until the status reaches `served`, then closes itself.
- **QR payload** format: `ipot://table/{tableId}`. The parser is tolerant of `https://.../table/{id}` form too (see `lib/utils/qr.dart`).
- **Mock order progression**: `MockOrderApi` advances the status one step every ~6 s of wall time so the tracking UI can be demoed end-to-end without a backend.

## Tests

```bash
flutter test
```

Covers cart math (subtotal, line dedup, quantity adjustments, table reset), QR payload parsing across valid and malformed inputs, and customization model invariants.

## Build

- Android: `flutter build apk --release` (debug APK works fine for review too)
- iOS: `flutter build ios --release` (Xcode signing required for device install)

Both icons & splash screen are generated via `flutter_launcher_icons` and `flutter_native_splash`. To regenerate after editing source assets in `assets/branding/`:

```bash
dart run flutter_launcher_icons
dart run flutter_native_splash:create
```
