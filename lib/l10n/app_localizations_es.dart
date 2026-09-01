// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'Lector PDF Pro';

  @override
  String get recentPdfs => 'Abiertos recientemente';

  @override
  String get noRecentPdfs => 'Ningún documento reciente.';

  @override
  String get openPdf => 'Abrir PDF';

  @override
  String get adSpace => 'Anuncio AdMob';

  @override
  String get share => 'Compartir';

  @override
  String get print => 'Imprimir';

  @override
  String get exportPng => 'Exportar PNG';

  @override
  String get signWithCert => 'Firmar con certificado';

  @override
  String get saveToDevice => 'Guardar en el dispositivo';

  @override
  String get pdfSavedSuccess => '¡PDF guardado en el dispositivo con éxito!';

  @override
  String get saveError => 'Error al guardar archivo';

  @override
  String get positionSignature => 'Posicionar firma';

  @override
  String get zoomHint =>
      'Pellizque con dos dedos para hacer zoom. Arraste la casilla para posicionarla.';

  @override
  String get loadingPdfScale => 'Cargando documento a escala 1:1...';

  @override
  String get noCertSelected => 'Ningún certificado seleccionado';

  @override
  String get certificate => 'Certificado';

  @override
  String get certPassword => 'Contraseña del certificado';

  @override
  String get watchAdAndSign => 'Ver anuncio y firmar';

  @override
  String get signing => 'Firmando...';

  @override
  String get selectCertAndPass =>
      '¡Seleccione el certificado e ingrese la contraseña!';

  @override
  String get signSuccess => '¡Documento firmado con éxito!';

  @override
  String get signError =>
      'Error al firmar: Contraseña incorrecta o archivo inválido.';

  @override
  String get digitallySigned => 'FIRMADO DIGITALMENTE';

  @override
  String get dragHere => '(Arrastre aquí)';

  @override
  String get unknownHolder => 'TITULAR DESCONOCIDO';

  @override
  String get date => 'Fecha';

  @override
  String get page => 'Página';
}
