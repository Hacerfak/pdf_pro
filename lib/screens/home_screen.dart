import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

import '/l10n/app_localizations.dart';

import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';

import '../services/pdf_service.dart';
import 'pdf_viewer_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  StreamSubscription? _intentDataStreamSubscription;
  List<String> _recentPdfs = [];

  BannerAd? _mediumRectangleAd;
  bool _isAdLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadMediumRectangleAd();
    _loadRecentPdfs();
    _listenToIncomingFiles();
  }

  void _loadMediumRectangleAd() {
    _mediumRectangleAd = BannerAd(
      adUnitId: 'ca-app-pub-4241608895500197/1706043844',
      request: const AdRequest(),
      size: AdSize.mediumRectangle,
      listener: BannerAdListener(
        onAdLoaded: (_) => setState(() => _isAdLoaded = true),
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
        },
      ),
    )..load();
  }

  Future<void> _loadRecentPdfs() async {
    final list = await PdfService.getRecentPdfs();
    if (mounted) {
      setState(() {
        _recentPdfs = list;
      });
    }
  }

  void _openPdf(String rawPath) async {
    final resolvedPath = await PdfService.resolvePdfPath(rawPath);
    if (mounted && resolvedPath.isNotEmpty) {
      await PdfService.saveRecentPdf(resolvedPath);
      _loadRecentPdfs();

      if (!mounted) return;

      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PdfViewerScreen(
              pdfPath: resolvedPath,
              onClose: () => Navigator.pop(context),
            ),
          ),
        ).then((_) => _loadRecentPdfs());
      });
    }
  }

  void _listenToIncomingFiles() {
    _intentDataStreamSubscription = ReceiveSharingIntent.instance
        .getMediaStream()
        .listen((List<SharedMediaFile> value) {
          if (value.isNotEmpty) {
            _openPdf(value.first.path);
          }
        });

    ReceiveSharingIntent.instance.getInitialMedia().then((
      List<SharedMediaFile> value,
    ) {
      if (value.isNotEmpty) {
        _openPdf(value.first.path);
      }
    });
  }

  Future<void> _pickLocalPdf() async {
    List<PlatformFile> result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result.single.path != null) {
      _openPdf(result.single.path!);
    }
  }

  @override
  void dispose() {
    _intentDataStreamSubscription?.cancel();
    _mediumRectangleAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.appTitle)),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          Center(
            child: Card(
              child: SizedBox(
                width: 300,
                height: 250,
                child: _isAdLoaded
                    ? AdWidget(ad: _mediumRectangleAd!)
                    : Center(
                        child: Text(
                          l10n.adSpace,
                          style: TextStyle(color: theme.colorScheme.outline),
                        ),
                      ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Text(
              l10n.recentPdfs,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: _recentPdfs.isEmpty
                ? Center(
                    child: Text(
                      l10n.noRecentPdfs,
                      style: TextStyle(color: theme.colorScheme.outline),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    itemCount: _recentPdfs.length,
                    itemBuilder: (context, index) {
                      final pdfPath = _recentPdfs[index];
                      final fileName = pdfPath.split('/').last;

                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Container(
                              width: 44,
                              height: 56,
                              color: theme.colorScheme.surfaceContainerHigh,
                              child: FutureBuilder<Uint8List?>(
                                future: PdfService.generateThumbnail(pdfPath),
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState ==
                                          ConnectionState.done &&
                                      snapshot.data != null) {
                                    return Image.memory(
                                      snapshot.data!,
                                      fit: BoxFit.cover,
                                    );
                                  }
                                  return Icon(
                                    Icons.picture_as_pdf,
                                    color: theme.colorScheme.primary,
                                  );
                                },
                              ),
                            ),
                          ),
                          title: Text(
                            fileName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                          subtitle: Text(
                            pdfPath,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 11,
                              color: theme.colorScheme.outline,
                            ),
                          ),
                          onTap: () => _openPdf(pdfPath),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _pickLocalPdf,
        icon: const Icon(Icons.folder_open),
        label: Text(l10n.openPdf),
      ),
    );
  }
}
