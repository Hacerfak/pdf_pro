// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get appTitle => 'Leitor PDF Pro';

  @override
  String get recentPdfs => 'Abertos Recentemente';

  @override
  String get noRecentPdfs => 'Nenhum documento recente.';

  @override
  String get openPdf => 'Abrir PDF';

  @override
  String get adSpace => 'Anúncio AdMob';

  @override
  String get share => 'Compartilhar';

  @override
  String get print => 'Imprimir';

  @override
  String get exportPng => 'Exportar PNG';

  @override
  String get signWithCert => 'Assinar com Certificado';

  @override
  String get saveToDevice => 'Salvar no Dispositivo';

  @override
  String get pdfSavedSuccess => 'PDF salvo no dispositivo com sucesso!';

  @override
  String get saveError => 'Erro ao salvar arquivo';

  @override
  String get positionSignature => 'Posicionar Assinatura';

  @override
  String get zoomHint =>
      'Pince com dois dedos para dar zoom. Arraste a caixa para posicionar.';

  @override
  String get loadingPdfScale => 'Carregando documento em escala 1:1...';

  @override
  String get noCertSelected => 'Nenhum certificado selecionado';

  @override
  String get certificate => 'Certificado';

  @override
  String get certPassword => 'Senha do Certificado';

  @override
  String get watchAdAndSign => 'Assistir Anúncio e Assinar';

  @override
  String get signing => 'Assinando...';

  @override
  String get selectCertAndPass => 'Selecione o certificado e digite a senha!';

  @override
  String get signSuccess => 'Documento assinado com sucesso!';

  @override
  String get signError =>
      'Erro ao assinar: Senha incorreta ou arquivo inválido.';

  @override
  String get digitallySigned => 'Assinado Digitalmente';

  @override
  String get dragHere => '(Arraste aqui)';

  @override
  String get unknownHolder => 'Titular Desconhecido';

  @override
  String get date => 'Data';

  @override
  String get page => 'Página';
}
