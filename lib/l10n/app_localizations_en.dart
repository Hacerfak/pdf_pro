// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'PDF Pro Reader';

  @override
  String get recentPdfs => 'Recently Opened';

  @override
  String get noRecentPdfs => 'No recent documents.';

  @override
  String get openPdf => 'Open PDF';

  @override
  String get adSpace => 'AdMob Ad';

  @override
  String get share => 'Share';

  @override
  String get print => 'Print';

  @override
  String get exportPng => 'Export PNG';

  @override
  String get signWithCert => 'Sign with Certificate';

  @override
  String get saveToDevice => 'Save to Device';

  @override
  String get pdfSavedSuccess => 'PDF saved to device successfully!';

  @override
  String get saveError => 'Error saving file';

  @override
  String get positionSignature => 'Position Signature';

  @override
  String get zoomHint =>
      'Pinch with two fingers to zoom. Drag the box to position.';

  @override
  String get loadingPdfScale => 'Loading document in 1:1 scale...';

  @override
  String get noCertSelected => 'No certificate selected';

  @override
  String get certificate => 'Certificate';

  @override
  String get certPassword => 'Certificate Password';

  @override
  String get watchAdAndSign => 'Watch Ad & Sign';

  @override
  String get signing => 'Signing...';

  @override
  String get selectCertAndPass =>
      'Select a certificate and enter the password!';

  @override
  String get signSuccess => 'Document signed successfully!';

  @override
  String get signError => 'Error signing: Incorrect password or invalid file.';

  @override
  String get digitallySigned => 'DIGITALLY SIGNED';

  @override
  String get dragHere => '(Drag here)';

  @override
  String get unknownHolder => 'UNKNOWN HOLDER';

  @override
  String get date => 'Date';

  @override
  String get page => 'Page';
}
