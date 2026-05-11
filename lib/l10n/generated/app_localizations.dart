import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_id.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('id'),
    Locale('zh'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'IPOT Order'**
  String get appTitle;

  /// No description provided for @scanTitle.
  ///
  /// In en, this message translates to:
  /// **'Scan to order'**
  String get scanTitle;

  /// No description provided for @scanHint.
  ///
  /// In en, this message translates to:
  /// **'Point your camera at the QR on the table'**
  String get scanHint;

  /// No description provided for @scanInvalid.
  ///
  /// In en, this message translates to:
  /// **'QR not recognized — make sure it\'s from an IPOT table'**
  String get scanInvalid;

  /// No description provided for @scanManualEntry.
  ///
  /// In en, this message translates to:
  /// **'Enter table ID manually'**
  String get scanManualEntry;

  /// No description provided for @scanEnterTableId.
  ///
  /// In en, this message translates to:
  /// **'Enter table ID'**
  String get scanEnterTableId;

  /// No description provided for @scanTableHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. T001'**
  String get scanTableHint;

  /// No description provided for @scanCameraUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Camera unavailable'**
  String get scanCameraUnavailable;

  /// No description provided for @scanTagline.
  ///
  /// In en, this message translates to:
  /// **'Order from your table, in seconds'**
  String get scanTagline;

  /// No description provided for @permissionCameraTitle.
  ///
  /// In en, this message translates to:
  /// **'Camera access needed'**
  String get permissionCameraTitle;

  /// No description provided for @permissionCameraBody.
  ///
  /// In en, this message translates to:
  /// **'We use the camera to scan the QR code on your table. Your camera feed stays on this device.'**
  String get permissionCameraBody;

  /// No description provided for @permissionAllow.
  ///
  /// In en, this message translates to:
  /// **'Allow camera'**
  String get permissionAllow;

  /// No description provided for @permissionNotNow.
  ///
  /// In en, this message translates to:
  /// **'Not now'**
  String get permissionNotNow;

  /// No description provided for @permissionDeniedTitle.
  ///
  /// In en, this message translates to:
  /// **'Camera permission denied'**
  String get permissionDeniedTitle;

  /// No description provided for @permissionDeniedBody.
  ///
  /// In en, this message translates to:
  /// **'You can grant camera access in system settings, or enter your table ID manually.'**
  String get permissionDeniedBody;

  /// No description provided for @permissionOpenSettings.
  ///
  /// In en, this message translates to:
  /// **'Open settings'**
  String get permissionOpenSettings;

  /// No description provided for @actionCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get actionCancel;

  /// No description provided for @actionOpenMenu.
  ///
  /// In en, this message translates to:
  /// **'Open menu'**
  String get actionOpenMenu;

  /// No description provided for @actionRetry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get actionRetry;

  /// No description provided for @actionAddToCart.
  ///
  /// In en, this message translates to:
  /// **'Add to cart'**
  String get actionAddToCart;

  /// No description provided for @actionPlaceOrder.
  ///
  /// In en, this message translates to:
  /// **'Place order'**
  String get actionPlaceOrder;

  /// No description provided for @actionClear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get actionClear;

  /// No description provided for @actionBackToMenu.
  ///
  /// In en, this message translates to:
  /// **'Back to menu'**
  String get actionBackToMenu;

  /// No description provided for @menuTable.
  ///
  /// In en, this message translates to:
  /// **'Table {id}'**
  String menuTable(String id);

  /// No description provided for @menuFailedLoad.
  ///
  /// In en, this message translates to:
  /// **'Failed to load menu'**
  String get menuFailedLoad;

  /// No description provided for @menuSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search menu...'**
  String get menuSearchHint;

  /// No description provided for @menuEmptyCategory.
  ///
  /// In en, this message translates to:
  /// **'No items in this category'**
  String get menuEmptyCategory;

  /// No description provided for @menuNoMatches.
  ///
  /// In en, this message translates to:
  /// **'No matches'**
  String get menuNoMatches;

  /// No description provided for @itemNotes.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get itemNotes;

  /// No description provided for @itemNotesHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. less spicy, no onion'**
  String get itemNotesHint;

  /// No description provided for @itemQuantity.
  ///
  /// In en, this message translates to:
  /// **'Quantity'**
  String get itemQuantity;

  /// No description provided for @itemRequired.
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get itemRequired;

  /// No description provided for @itemMaxSelections.
  ///
  /// In en, this message translates to:
  /// **'Max {n}'**
  String itemMaxSelections(int n);

  /// No description provided for @itemFree.
  ///
  /// In en, this message translates to:
  /// **'Free'**
  String get itemFree;

  /// No description provided for @itemPickRequired.
  ///
  /// In en, this message translates to:
  /// **'Please pick required options first'**
  String get itemPickRequired;

  /// No description provided for @cartTitle.
  ///
  /// In en, this message translates to:
  /// **'Your cart'**
  String get cartTitle;

  /// No description provided for @cartClearTitle.
  ///
  /// In en, this message translates to:
  /// **'Clear cart?'**
  String get cartClearTitle;

  /// No description provided for @cartClearBody.
  ///
  /// In en, this message translates to:
  /// **'Remove all items from your cart.'**
  String get cartClearBody;

  /// No description provided for @cartNoteHint.
  ///
  /// In en, this message translates to:
  /// **'Note for the kitchen (optional)'**
  String get cartNoteHint;

  /// No description provided for @cartSubtotal.
  ///
  /// In en, this message translates to:
  /// **'Subtotal ({count} items)'**
  String cartSubtotal(int count);

  /// No description provided for @cartEmpty.
  ///
  /// In en, this message translates to:
  /// **'Your cart is empty'**
  String get cartEmpty;

  /// No description provided for @cartEmptyHint.
  ///
  /// In en, this message translates to:
  /// **'Add some items from the menu'**
  String get cartEmptyHint;

  /// No description provided for @cartLineNote.
  ///
  /// In en, this message translates to:
  /// **'Note: {note}'**
  String cartLineNote(String note);

  /// No description provided for @orderSubmitting.
  ///
  /// In en, this message translates to:
  /// **'Placing your order...'**
  String get orderSubmitting;

  /// No description provided for @orderSubmitFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to place order'**
  String get orderSubmitFailed;

  /// No description provided for @orderConfirmedTitle.
  ///
  /// In en, this message translates to:
  /// **'Order placed!'**
  String get orderConfirmedTitle;

  /// No description provided for @orderConfirmedSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Order #{id}'**
  String orderConfirmedSubtitle(String id);

  /// No description provided for @orderTrackTitle.
  ///
  /// In en, this message translates to:
  /// **'Track order'**
  String get orderTrackTitle;

  /// No description provided for @orderStatusPending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get orderStatusPending;

  /// No description provided for @orderStatusConfirmed.
  ///
  /// In en, this message translates to:
  /// **'Confirmed'**
  String get orderStatusConfirmed;

  /// No description provided for @orderStatusPreparing.
  ///
  /// In en, this message translates to:
  /// **'Preparing'**
  String get orderStatusPreparing;

  /// No description provided for @orderStatusReady.
  ///
  /// In en, this message translates to:
  /// **'Ready'**
  String get orderStatusReady;

  /// No description provided for @orderStatusServed.
  ///
  /// In en, this message translates to:
  /// **'Served'**
  String get orderStatusServed;

  /// No description provided for @orderEta.
  ///
  /// In en, this message translates to:
  /// **'Ready in about {minutes} min'**
  String orderEta(int minutes);

  /// No description provided for @orderBackToScan.
  ///
  /// In en, this message translates to:
  /// **'Back to scan'**
  String get orderBackToScan;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'id', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'id':
      return AppLocalizationsId();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
