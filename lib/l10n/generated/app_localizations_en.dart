// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'IPOT Order';

  @override
  String get scanTitle => 'Scan to order';

  @override
  String get scanHint => 'Point your camera at the QR on the table';

  @override
  String get scanInvalid =>
      'QR not recognized — make sure it\'s from an IPOT table';

  @override
  String get scanManualEntry => 'Enter table ID manually';

  @override
  String get scanEnterTableId => 'Enter table ID';

  @override
  String get scanTableHint => 'e.g. T001';

  @override
  String get scanCameraUnavailable => 'Camera unavailable';

  @override
  String get scanTagline => 'Order from your table, in seconds';

  @override
  String get permissionCameraTitle => 'Camera access needed';

  @override
  String get permissionCameraBody =>
      'We use the camera to scan the QR code on your table. Your camera feed stays on this device.';

  @override
  String get permissionAllow => 'Allow camera';

  @override
  String get permissionNotNow => 'Not now';

  @override
  String get permissionDeniedTitle => 'Camera permission denied';

  @override
  String get permissionDeniedBody =>
      'You can grant camera access in system settings, or enter your table ID manually.';

  @override
  String get permissionOpenSettings => 'Open settings';

  @override
  String get actionCancel => 'Cancel';

  @override
  String get actionOpenMenu => 'Open menu';

  @override
  String get actionRetry => 'Retry';

  @override
  String get actionAddToCart => 'Add to cart';

  @override
  String get actionPlaceOrder => 'Place order';

  @override
  String get actionClear => 'Clear';

  @override
  String get actionBackToMenu => 'Back to menu';

  @override
  String menuTable(String id) {
    return 'Table $id';
  }

  @override
  String get menuFailedLoad => 'Failed to load menu';

  @override
  String get menuSearchHint => 'Search menu...';

  @override
  String get menuEmptyCategory => 'No items in this category';

  @override
  String get menuNoMatches => 'No matches';

  @override
  String get itemNotes => 'Notes';

  @override
  String get itemNotesHint => 'e.g. less spicy, no onion';

  @override
  String get itemQuantity => 'Quantity';

  @override
  String get itemRequired => 'Required';

  @override
  String itemMaxSelections(int n) {
    return 'Max $n';
  }

  @override
  String get itemFree => 'Free';

  @override
  String get itemPickRequired => 'Please pick required options first';

  @override
  String get cartTitle => 'Your cart';

  @override
  String get cartClearTitle => 'Clear cart?';

  @override
  String get cartClearBody => 'Remove all items from your cart.';

  @override
  String get cartNoteHint => 'Note for the kitchen (optional)';

  @override
  String cartSubtotal(int count) {
    return 'Subtotal ($count items)';
  }

  @override
  String get cartEmpty => 'Your cart is empty';

  @override
  String get cartEmptyHint => 'Add some items from the menu';

  @override
  String cartLineNote(String note) {
    return 'Note: $note';
  }

  @override
  String get orderSubmitting => 'Placing your order...';

  @override
  String get orderSubmitFailed => 'Failed to place order';

  @override
  String get orderConfirmedTitle => 'Order placed!';

  @override
  String orderConfirmedSubtitle(String id) {
    return 'Order #$id';
  }

  @override
  String get orderTrackTitle => 'Track order';

  @override
  String get orderStatusPending => 'Pending';

  @override
  String get orderStatusConfirmed => 'Confirmed';

  @override
  String get orderStatusPreparing => 'Preparing';

  @override
  String get orderStatusReady => 'Ready';

  @override
  String get orderStatusServed => 'Served';

  @override
  String orderEta(int minutes) {
    return 'Ready in about $minutes min';
  }

  @override
  String get orderBackToScan => 'Back to scan';
}
