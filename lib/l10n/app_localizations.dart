import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_pt.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
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
    Locale('es'),
    Locale('pt'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'PDF Pro Reader'**
  String get appTitle;

  /// No description provided for @recentPdfs.
  ///
  /// In en, this message translates to:
  /// **'Recently Opened'**
  String get recentPdfs;

  /// No description provided for @noRecentPdfs.
  ///
  /// In en, this message translates to:
  /// **'No recent documents.'**
  String get noRecentPdfs;

  /// No description provided for @openPdf.
  ///
  /// In en, this message translates to:
  /// **'Open PDF'**
  String get openPdf;

  /// No description provided for @adSpace.
  ///
  /// In en, this message translates to:
  /// **'AdMob Ad'**
  String get adSpace;

  /// No description provided for @share.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get share;

  /// No description provided for @print.
  ///
  /// In en, this message translates to:
  /// **'Print'**
  String get print;

  /// No description provided for @exportPng.
  ///
  /// In en, this message translates to:
  /// **'Export PNG'**
  String get exportPng;

  /// No description provided for @signWithCert.
  ///
  /// In en, this message translates to:
  /// **'Sign with Certificate'**
  String get signWithCert;

  /// No description provided for @saveToDevice.
  ///
  /// In en, this message translates to:
  /// **'Save to Device'**
  String get saveToDevice;

  /// No description provided for @pdfSavedSuccess.
  ///
  /// In en, this message translates to:
  /// **'PDF saved to device successfully!'**
  String get pdfSavedSuccess;

  /// No description provided for @saveError.
  ///
  /// In en, this message translates to:
  /// **'Error saving file'**
  String get saveError;

  /// No description provided for @positionSignature.
  ///
  /// In en, this message translates to:
  /// **'Position Signature'**
  String get positionSignature;

  /// No description provided for @zoomHint.
  ///
  /// In en, this message translates to:
  /// **'Pinch with two fingers to zoom. Drag the box to position.'**
  String get zoomHint;

  /// No description provided for @loadingPdfScale.
  ///
  /// In en, this message translates to:
  /// **'Loading document in 1:1 scale...'**
  String get loadingPdfScale;

  /// No description provided for @noCertSelected.
  ///
  /// In en, this message translates to:
  /// **'No certificate selected'**
  String get noCertSelected;

  /// No description provided for @certificate.
  ///
  /// In en, this message translates to:
  /// **'Certificate'**
  String get certificate;

  /// No description provided for @certPassword.
  ///
  /// In en, this message translates to:
  /// **'Certificate Password'**
  String get certPassword;

  /// No description provided for @watchAdAndSign.
  ///
  /// In en, this message translates to:
  /// **'Watch Ad & Sign'**
  String get watchAdAndSign;

  /// No description provided for @signing.
  ///
  /// In en, this message translates to:
  /// **'Signing...'**
  String get signing;

  /// No description provided for @selectCertAndPass.
  ///
  /// In en, this message translates to:
  /// **'Select a certificate and enter the password!'**
  String get selectCertAndPass;

  /// No description provided for @signSuccess.
  ///
  /// In en, this message translates to:
  /// **'Document signed successfully!'**
  String get signSuccess;

  /// No description provided for @signError.
  ///
  /// In en, this message translates to:
  /// **'Error signing: Incorrect password or invalid file.'**
  String get signError;

  /// No description provided for @digitallySigned.
  ///
  /// In en, this message translates to:
  /// **'DIGITALLY SIGNED'**
  String get digitallySigned;

  /// No description provided for @dragHere.
  ///
  /// In en, this message translates to:
  /// **'(Drag here)'**
  String get dragHere;

  /// No description provided for @unknownHolder.
  ///
  /// In en, this message translates to:
  /// **'UNKNOWN HOLDER'**
  String get unknownHolder;

  /// No description provided for @date.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get date;

  /// No description provided for @page.
  ///
  /// In en, this message translates to:
  /// **'Page'**
  String get page;
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
      <String>['en', 'es', 'pt'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'pt':
      return AppLocalizationsPt();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
