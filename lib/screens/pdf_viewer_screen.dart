import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:pdfrx/pdfrx.dart';
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';

import '/l10n/app_localizations.dart';
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

    final Future<String?> imageFuture = PdfService.preparePageImageFile(
      _currentPdfPath,
      _currentPage - 1,
      pageLabel,
    );

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
        Navigator.of(context, rootNavigator: true).pop();
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
      ),
      body: Column(
        children: [
          // 1. Banner de Anúncio no topo (Abaixo da AppBar)
          if (_isBannerLoaded && _bannerAd != null)
            SizedBox(
              width: _bannerAd!.size.width.toDouble(),
              height: _bannerAd!.size.height.toDouble(),
              child: AdWidget(ad: _bannerAd!),
            ),

          // 2. Leitor de PDF com indicador de página flutuante
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
        ],
      ),

      // 3. Barra de Ações no Rodapé
      bottomNavigationBar: BottomAppBar(
        height: 68,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
              tooltip: l10n.saveToDevice,
              icon: const Icon(Icons.download_outlined),
              onPressed: () async {
                await PdfService.savePdfToDevice(
                  sourcePath: _currentPdfPath,
                  context: context,
                  dialogTitle: l10n.saveToDevice,
                  successMessage: l10n.pdfSavedSuccess,
                  errorMessage: l10n.saveError,
                );
              },
            ),
            IconButton(
              tooltip: l10n.share,
              icon: const Icon(Icons.share_outlined),
              onPressed: () async {
                final params = ShareParams(files: [XFile(_currentPdfPath)]);
                await SharePlus.instance.share(params);
              },
            ),
            IconButton(
              tooltip: l10n.print,
              icon: const Icon(Icons.print_outlined),
              onPressed: () async {
                final bytes = await File(_currentPdfPath).readAsBytes();
                await Printing.layoutPdf(onLayout: (_) => bytes);
              },
            ),
            IconButton(
              tooltip: l10n.exportPng,
              icon: const Icon(Icons.image_outlined),
              onPressed: () => _exportPngWithAd(l10n.page),
            ),
            IconButton(
              tooltip: l10n.signWithCert,
              icon: Icon(
                Icons.verified_user_outlined,
                color: theme.colorScheme.primary,
              ),
              onPressed: _openSignatureScreen,
            ),
          ],
        ),
      ),
    );
  }
}
