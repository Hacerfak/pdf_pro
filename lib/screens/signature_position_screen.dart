import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:printing/printing.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

import '/l10n/app_localizations.dart';
import '../services/ad_service.dart';
import '../services/pdf_service.dart';

class SignaturePositionScreen extends StatefulWidget {
  final String pdfPath;
  final AdService adService;

  const SignaturePositionScreen({
    super.key,
    required this.pdfPath,
    required this.adService,
  });

  @override
  State<SignaturePositionScreen> createState() =>
      _SignaturePositionScreenState();
}

class _SignaturePositionScreenState extends State<SignaturePositionScreen> {
  String? _p12Path;
  String? _p12Name;
  final TextEditingController _passwordController = TextEditingController();

  bool _isRendering = true;
  bool _isSigning = false;
  Uint8List? _previewBytes;

  int _currentPage = 0;
  int _totalPages = 1;

  double _pdfVisualWidth = 595.0;
  double _pdfVisualHeight = 842.0;

  final ValueNotifier<Offset> _boxPositionNotifier = ValueNotifier(
    const Offset(20, 20),
  );

  static const double boxWidth = 130.0;
  static const double boxHeight = 38.0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadPdfPage(_currentPage);
    });
  }

  @override
  void dispose() {
    _boxPositionNotifier.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _loadPdfPage(int pageIndex) async {
    setState(() => _isRendering = true);

    try {
      final file = File(widget.pdfPath);
      final bytes = await file.readAsBytes();

      final doc = PdfDocument(inputBytes: bytes);
      _totalPages = doc.pages.count;
      final visualSize = PdfService.getVisualPdfSize(doc.pages[pageIndex]);
      _pdfVisualWidth = visualSize.width;
      _pdfVisualHeight = visualSize.height;
      doc.dispose();

      await for (final page in Printing.raster(
        bytes,
        pages: [pageIndex],
        dpi: 72,
      )) {
        final png = await page.toPng();
        if (mounted) {
          setState(() {
            _previewBytes = png;
            _isRendering = false;
          });
        }
        break;
      }
    } catch (e) {
      debugPrint('Erro ao carregar documento: $e');
      if (mounted) setState(() => _isRendering = false);
    }
  }

  void _changePage(int delta) {
    final newPage = _currentPage + delta;
    if (newPage >= 0 && newPage < _totalPages) {
      setState(() {
        _currentPage = newPage;
      });
      _loadPdfPage(_currentPage);
    }
  }

  Future<void> _pickCertificate() async {
    List<PlatformFile> result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['p12', 'pfx'],
    );

    if (result.single.path != null) {
      setState(() {
        _p12Path = result.single.path;
        _p12Name = result.single.name;
      });
    }
  }

  void _onSignPressed(AppLocalizations l10n) async {
    if (_p12Path == null || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(l10n.selectCertAndPass)));
      return;
    }

    // Tenta exibir o anúncio premiado
    final bool adDisplayed = await widget.adService.showRewardedAd(
      onRewardEarned: () => _executeSigning(l10n),
    );

    // Se o anúncio não estiver carregado/disponível, assina diretamente sem travar a experiência
    if (!adDisplayed && mounted) {
      _executeSigning(l10n);
    }
  }

  Future<void> _executeSigning(AppLocalizations l10n) async {
    setState(() => _isSigning = true);

    try {
      final currentPos = _boxPositionNotifier.value;
      final visualBounds = Rect.fromLTWH(
        currentPos.dx,
        currentPos.dy,
        boxWidth,
        boxHeight,
      );

      final dir = await getApplicationDocumentsDirectory();
      final fileName = widget.pdfPath
          .split('/')
          .last
          .replaceAll('.pdf', '_assinado.pdf');
      final outputPath = '${dir.path}/$fileName';

      await PdfService.signPdfWithP12(
        pdfPath: widget.pdfPath,
        p12Path: _p12Path!,
        password: _passwordController.text,
        outputPath: outputPath,
        visualBounds: visualBounds,
        pageIndex: _currentPage,
        labelDigitallySigned: l10n.digitallySigned,
        labelDate: l10n.date,
        labelUnknownHolder: l10n.unknownHolder,
      );

      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(l10n.signSuccess)));
        Navigator.pop(context, outputPath);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('${l10n.signError}\n($e)')));
      }
    } finally {
      if (mounted) setState(() => _isSigning = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.positionSignature),
        actions: [
          if (_totalPages > 1)
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left),
                  onPressed: _currentPage > 0 ? () => _changePage(-1) : null,
                ),
                Text(
                  '${_currentPage + 1} / $_totalPages',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right),
                  onPressed: _currentPage < _totalPages - 1
                      ? () => _changePage(1)
                      : null,
                ),
              ],
            ),
        ],
      ),
      body: _isRendering
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 48,
                    height: 48,
                    child: CircularProgressIndicator(
                      strokeWidth: 4,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    l10n.loadingPdfScale,
                    style: TextStyle(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            )
          : Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 8,
                    horizontal: 16,
                  ),
                  color: theme.colorScheme.surfaceContainerHighest,
                  child: Row(
                    children: [
                      Icon(
                        Icons.zoom_in,
                        size: 20,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          l10n.zoomHint,
                          style: TextStyle(
                            fontSize: 12,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Container(
                    color: theme.colorScheme.surfaceContainerLow,
                    child: InteractiveViewer(
                      minScale: 0.5,
                      maxScale: 4.0,
                      constrained: false,
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Container(
                          width: _pdfVisualWidth,
                          height: _pdfVisualHeight,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.15),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Stack(
                            children: [
                              Image.memory(
                                _previewBytes!,
                                width: _pdfVisualWidth,
                                height: _pdfVisualHeight,
                                fit: BoxFit.fill,
                              ),
                              ValueListenableBuilder<Offset>(
                                valueListenable: _boxPositionNotifier,
                                builder: (context, pos, child) {
                                  return Positioned(
                                    left: pos.dx,
                                    top: pos.dy,
                                    child: child!,
                                  );
                                },
                                child: GestureDetector(
                                  onPanUpdate: (details) {
                                    final current = _boxPositionNotifier.value;
                                    final newX = (current.dx + details.delta.dx)
                                        .clamp(0.0, _pdfVisualWidth - boxWidth);
                                    final newY = (current.dy + details.delta.dy)
                                        .clamp(
                                          0.0,
                                          _pdfVisualHeight - boxHeight,
                                        );
                                    _boxPositionNotifier.value = Offset(
                                      newX,
                                      newY,
                                    );
                                  },
                                  child: Container(
                                    width: boxWidth,
                                    height: boxHeight,
                                    decoration: BoxDecoration(
                                      color: theme.colorScheme.primary
                                          .withValues(alpha: 0.15),
                                      border: Border.all(
                                        color: theme.colorScheme.primary,
                                        width: 1.5,
                                      ),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(2.0),
                                      child: Text(
                                        '${l10n.digitallySigned}\n${l10n.dragHere}',
                                        style: TextStyle(
                                          fontSize: 6.5,
                                          color: theme.colorScheme.primary,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Card(
                  margin: EdgeInsets.zero,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(24),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                _p12Name ?? l10n.noCertSelected,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            FilledButton.tonalIcon(
                              onPressed: _isSigning ? null : _pickCertificate,
                              icon: const Icon(Icons.file_present, size: 18),
                              label: Text(l10n.certificate),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _passwordController,
                          obscureText: true,
                          decoration: InputDecoration(
                            labelText: l10n.certPassword,
                            border: const OutlineInputBorder(),
                            prefixIcon: const Icon(Icons.lock_outline),
                            isDense: true,
                          ),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: FilledButton.icon(
                            onPressed: _isSigning
                                ? null
                                : () => _onSignPressed(l10n),
                            icon: _isSigning
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Icon(Icons.ondemand_video),
                            label: Text(
                              _isSigning ? l10n.signing : l10n.watchAdAndSign,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
