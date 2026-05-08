# ipot

Customer-side QR ordering app. Scan the QR on a table → browse the menu → build a cart with customizations → submit the order → track its status.

Built with Flutter (Dart) for Android & iOS.

## Status

Work in progress. Currently scaffolded with models, API layer (mock + live switch), routing, and cart state. Screens are still being filled in.

## Tech

- **Flutter** 3.38.x / Dart 3.10.x
- **Riverpod** for state
- **go_router** for navigation
- **dio** for HTTP
- **mobile_scanner** for QR scanning
- **flutter_dotenv** for environment config

## Getting started

```bash
# 1. Install deps
flutter pub get

# 2. Set up env (copy & edit if needed)
cp .env.example .env

# 3. Run on a connected device / emulator
flutter run
```

By default the app runs against bundled mock data so it works without the live API.

### Env vars

| Key | Default | What it does |
| --- | --- | --- |
| `API_BASE_URL` | `https://api.ipot.example.com` | Base URL when `USE_MOCK=false` |
| `USE_MOCK` | `true` | Use bundled mock services instead of live API |

Toggle `USE_MOCK=false` once the live API is reachable.

## Project layout

```
lib/
├── api/         # ApiClient + Menu/Order APIs (live + mock impls)
├── models/      # Menu, MenuItem, Cart, Order, ...
├── state/       # Riverpod providers (cart, menu, order)
├── navigation/  # go_router config & route names
├── screens/     # Screen widgets
├── widgets/     # (added in next iteration) reusable widgets
└── utils/       # formatters, qr parser
assets/
└── mock/        # bundled menu JSON used by MockMenuApi
test/            # unit + widget tests
```

## Architecture notes

- **Mock vs live API** is a single env-driven switch (`USE_MOCK`). The app picks `MockMenuApi` / `MockOrderApi` or the http-backed implementations at provider construction. No code change needed to flip.
- **Cart line de-dup**: items added with the same customization set merge into one line and bump quantity; differing customizations stay as separate lines (e.g. one Mild Ramen + one Extra Spicy Ramen). See `CartController._lineKey`.
- **QR payload** format: `ipot://table/{tableId}`. Parsing is tolerant of `https://.../table/{id}` form too — see `lib/utils/qr.dart`.

## Tests

```bash
flutter test
```

## TODO

- [ ] QR scanner screen with camera
- [ ] Menu browser (categories + search)
- [ ] Item detail with customization picker
- [ ] Cart screen + order submit
- [ ] Order tracking (polling)
- [ ] More tests (cart math, qr parsing, customization validation)
