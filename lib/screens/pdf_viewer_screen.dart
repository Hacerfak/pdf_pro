import 'dart:io';

import 'package:flutter/material.dart';

import '/l10n/app_localizations.dart';

import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:pdfrx/pdfrx.dart';
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';

import '../services/ad_service.dart';
import '../services/pdf_service.dart';
import 'signature_position_screen.dart';

class PdfViewerScreen extends StatefulWidget {
  final String pdfPath;
  final VoidCallback onClose;

  const PdfViewerScreen({
    super.key,
    required this.pdfPath,
    required this.onClose,
  });

  @override
  State<PdfViewerScreen> createState() => _PdfViewerScreenState();
}

class _PdfViewerScreenState extends State<PdfViewerScreen> {
  final AdService _adService = AdService();
  final PdfViewerController _pdfController = PdfViewerController();

  BannerAd? _bannerAd;
  bool _isBannerLoaded = false;
  late String _currentPdfPath;

  int _currentPage = 1;
  int _totalPages = 1;

  @override
  void initState() {
    super.initState();
    _currentPdfPath = widget.pdfPath;
    _adService.loadRewardedAd();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isBannerLoaded && _bannerAd == null) {
      _loadAdaptiveBannerAd();
    }
  }

  Future<void> _loadAdaptiveBannerAd() async {
    final int width = MediaQuery.of(context).size.width.truncate();
    final AnchoredAdaptiveBannerAdSize? size =
        await AdSize.getLargeAnchoredAdaptiveBannerAdSize(width);

    if (size == null) return;

    _bannerAd = BannerAd(
      adUnitId: 'ca-app-pub-4241608895500197/4924952757',
      request: const AdRequest(),
      size: size,
      listener: BannerAdListener(
        onAdLoaded: (_) {
          if (mounted) setState(() => _isBannerLoaded = true);
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
        },
      ),
    );

    await _bannerAd!.load();
  }

  void _openSignatureScreen() async {
    final newPath = await Navigator.push<String>(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            SignaturePositionScreen(
              pdfPath: _currentPdfPath,
              adService: _adService,
            ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );

    if (newPath != null && mounted) {
      setState(() {
        _currentPdfPath = newPath;
      });
    }
  }

  void _exportPngWithAd(String pageLabel) async {
    final theme = Theme.of(context);

    // 1. Inicia o processamento da imagem em segundo plano
    final Future<String?> imageFuture = PdfService.preparePageImageFile(
      _currentPdfPath,
      _currentPage - 1,
      pageLabel,
    );

    // 2. Tenta exibir o anúncio premiado
    final bool adDisplayed = await _adService.showRewardedAd(
      onRewardEarned: () async {
        final imgPath = await imageFuture;
        if (imgPath != null && mounted) {
          final params = ShareParams(
            text: '$pageLabel $_currentPage',
            files: [XFile(imgPath)],
          );
          await SharePlus.instance.share(params);
        }
      },
    );

    // 3. Se não houver anúncio disponível, exibe o Loader até finalizar a imagem
    if (!adDisplayed && mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) => Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(color: theme.colorScheme.primary),
                const SizedBox(width: 20),
                Expanded(
                  child: Text(
                    'Exportando página...',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );

      final imgPath = await imageFuture;

      if (mounted) {
        Navigator.of(context, rootNavigator: true).pop(); // Fecha o diálogo
      }

      if (imgPath != null && mounted) {
        final params = ShareParams(
          text: '$pageLabel $_currentPage',
          files: [XFile(imgPath)],
        );
        await SharePlus.instance.share(params);
      }
    }
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    _adService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: widget.onClose,
        ),
        title: Text(
          _currentPdfPath.split('/').last,
          style: const TextStyle(fontSize: 14),
        ),
        actions: [
          PopupMenuButton<String>(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            onSelected: (value) async {
              switch (value) {
                case 'save':
                  await PdfService.savePdfToDevice(
                    sourcePath: _currentPdfPath,
                    context: context,
                    dialogTitle: l10n.saveToDevice,
                    successMessage: l10n.pdfSavedSuccess,
                    errorMessage: l10n.saveError,
                  );
                  break;
                case 'share':
                  final params = ShareParams(files: [XFile(_currentPdfPath)]);
                  await SharePlus.instance.share(params);
                  break;
                case 'print':
                  final bytes = await File(_currentPdfPath).readAsBytes();
                  await Printing.layoutPdf(onLayout: (_) => bytes);
                  break;
                case 'export_img':
                  _exportPngWithAd(l10n.page);
                  break;
                case 'sign':
                  _openSignatureScreen();
                  break;
              }
            },
            itemBuilder: (BuildContext context) => [
              PopupMenuItem(
                value: 'save',
                child: Row(
                  children: [
                    Icon(
                      Icons.download_outlined,
                      size: 20,
                      color: theme.colorScheme.onSurface,
                    ),
                    const SizedBox(width: 12),
                    Text(l10n.saveToDevice),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'share',
                child: Row(
                  children: [
                    Icon(
                      Icons.share_outlined,
                      size: 20,
                      color: theme.colorScheme.onSurface,
                    ),
                    const SizedBox(width: 12),
                    Text(l10n.share),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'print',
                child: Row(
                  children: [
                    Icon(
                      Icons.print_outlined,
                      size: 20,
                      color: theme.colorScheme.onSurface,
                    ),
                    const SizedBox(width: 12),
                    Text(l10n.print),
                  ],
                ),
              ),
              const PopupMenuDivider(),
              PopupMenuItem(
                value: 'export_img',
                child: Row(
                  children: [
                    Icon(
                      Icons.image_outlined,
                      size: 20,
                      color: theme.colorScheme.onSurface,
                    ),
                    const SizedBox(width: 12),
                    Text(l10n.exportPng),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'sign',
                child: Row(
                  children: [
                    Icon(
                      Icons.verified_user_outlined,
                      size: 20,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      l10n.signWithCert,
                      style: TextStyle(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                PdfViewer.file(
                  _currentPdfPath,
                  controller: _pdfController,
                  params: PdfViewerParams(
                    onViewerReady: (document, controller) {
                      setState(() {
                        _totalPages = document.pages.length;
                      });
                    },
                    onPageChanged: (pageNumber) {
                      if (pageNumber != null) {
                        setState(() {
                          _currentPage = pageNumber;
                        });
                      }
                    },
                  ),
                ),
                Positioned(
                  bottom: 16,
                  right: 16,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest
                          .withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 6,
                        ),
                      ],
                    ),
                    child: Text(
                      '$_currentPage / $_totalPages',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (_isBannerLoaded && _bannerAd != null)
            SizedBox(
              width: _bannerAd!.size.width.toDouble(),
              height: _bannerAd!.size.height.toDouble(),
              child: AdWidget(ad: _bannerAd!),
            ),
        ],
      ),
    );
  }
}
