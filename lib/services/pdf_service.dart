import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdfrx/pdfrx.dart' as pdfrx;
import 'package:printing/printing.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

class PdfService {
  static const String _recentKey = 'recent_pdfs_list';
  static final Map<String, Uint8List> _thumbnailCache = {};

  static Future<void> saveRecentPdf(String path) async {
    if (path.isEmpty || !await File(path).exists()) return;

    final prefs = await SharedPreferences.getInstance();
    List<String> list = prefs.getStringList(_recentKey) ?? [];
    list.remove(path);
    list.insert(0, path);
    if (list.length > 5) {
      list = list.sublist(0, 5);
    }
    await prefs.setStringList(_recentKey, list);
  }

  static Future<List<String>> getRecentPdfs() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_recentKey) ?? [];
    final List<String> validList = [];

    for (final path in list) {
      if (await File(path).exists()) {
        validList.add(path);
      }
    }

    if (validList.length != list.length) {
      await prefs.setStringList(_recentKey, validList);
    }

    return validList;
  }

  static Future<void> removeRecentPdf(String path) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> list = prefs.getStringList(_recentKey) ?? [];
    list.remove(path);
    await prefs.setStringList(_recentKey, list);
    _thumbnailCache.remove(path);
  }

  static Future<Uint8List?> generateThumbnail(String pdfPath) async {
    if (_thumbnailCache.containsKey(pdfPath)) {
      return _thumbnailCache[pdfPath];
    }

    if (!await File(pdfPath).exists()) {
      _thumbnailCache.remove(pdfPath);
      return null;
    }

    if (_thumbnailCache.length >= 20) {
      _thumbnailCache.remove(_thumbnailCache.keys.first);
    }

    try {
      final doc = await pdfrx.PdfDocument.openFile(pdfPath);
      final page = doc.pages[0];

      final pageImage = await page.render(
        fullWidth: page.width,
        fullHeight: page.height,
        width: (page.width / 4).round(),
        height: (page.height / 4).round(),
      );

      if (pageImage != null) {
        final uiImage = await pageImage.createImage();

        final recorder = ui.PictureRecorder();
        final canvas = Canvas(recorder);
        final bgPaint = Paint()..color = Colors.white;

        canvas.drawRect(
          Rect.fromLTWH(
            0,
            0,
            uiImage.width.toDouble(),
            uiImage.height.toDouble(),
          ),
          bgPaint,
        );
        canvas.drawImage(uiImage, Offset.zero, Paint());

        final picture = recorder.endRecording();
        final finalImg = await picture.toImage(uiImage.width, uiImage.height);
        final byteData = await finalImg.toByteData(
          format: ui.ImageByteFormat.png,
        );

        await doc.dispose();

        if (byteData != null) {
          final resultBytes = byteData.buffer.asUint8List();
          _thumbnailCache[pdfPath] = resultBytes;
          return resultBytes;
        }
      }
      await doc.dispose();
    } catch (e) {
      debugPrint('Erro ao gerar miniatura com pdfrx: $e');
    }
    return null;
  }

  static Future<String> resolvePdfPath(String rawPath) async {
    if (rawPath.isEmpty) return rawPath;

    final file = File(rawPath);
    if (await file.exists()) return rawPath;

    try {
      final uri = Uri.parse(rawPath);
      if (uri.scheme == 'file') {
        final filePath = uri.toFilePath();
        if (await File(filePath).exists()) return filePath;
      }
    } catch (e) {
      debugPrint('Erro ao resolver caminho do PDF: $e');
    }
    return rawPath;
  }

  static Future<String?> preparePageImageFile(
    String pdfPath,
    int pageIndex,
    String pageLabel,
  ) async {
    try {
      final file = File(pdfPath);
      if (!await file.exists()) return null;

      final bytes = await file.readAsBytes();

      await for (final page in Printing.raster(
        bytes,
        pages: [pageIndex],
        dpi: 300,
      )) {
        final pngBytes = await page.toPng();
        final codec = await ui.instantiateImageCodec(pngBytes);
        final frame = await codec.getNextFrame();
        final ui.Image pdfImage = frame.image;

        final recorder = ui.PictureRecorder();
        final canvas = Canvas(
          recorder,
          Rect.fromLTWH(
            0,
            0,
            pdfImage.width.toDouble(),
            pdfImage.height.toDouble(),
          ),
        );

        final paintBg = Paint()..color = Colors.white;
        canvas.drawRect(
          Rect.fromLTWH(
            0,
            0,
            pdfImage.width.toDouble(),
            pdfImage.height.toDouble(),
          ),
          paintBg,
        );
        canvas.drawImage(pdfImage, Offset.zero, Paint());

        final picture = recorder.endRecording();
        final imgWithWhiteBg = await picture.toImage(
          pdfImage.width,
          pdfImage.height,
        );
        final byteData = await imgWithWhiteBg.toByteData(
          format: ui.ImageByteFormat.png,
        );

        if (byteData != null) {
          final tempDir = await getTemporaryDirectory();
          final imgFile = File('${tempDir.path}/pagina_${pageIndex + 1}.png');
          await imgFile.writeAsBytes(byteData.buffer.asUint8List());
          return imgFile.path;
        }
        break;
      }
    } catch (e) {
      debugPrint('Erro ao exportar imagem: $e');
    }
    return null;
  }

  static Future<void> savePdfToDevice({
    required String sourcePath,
    required BuildContext context,
    required String dialogTitle,
    required String successMessage,
    required String errorMessage,
  }) async {
    try {
      final file = File(sourcePath);
      if (!await file.exists()) return;

      final bytes = await file.readAsBytes();
      final fileName = sourcePath.split('/').last;

      final Uri? outputFile = await FilePicker.saveFile(
        dialogTitle: dialogTitle,
        fileName: fileName,
        type: FileType.custom,
        allowedExtensions: ['pdf'],
        bytes: bytes,
      );

      if (outputFile != null && context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(successMessage)));
      }
    } catch (e) {
      debugPrint('Erro ao salvar PDF: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('$errorMessage: $e')));
      }
    }
  }

  static String _removeAccents(String text) {
    const withAccents =
        'ÀÁÂÃÄÅàáâãäåÒÓÔÕÖØòóôõöøÈÉÊËèéêëÇçÌÍÎÏìíîïÙÚÛÜùúûüÝýÿÑñ';
    const withoutAccents =
        'AAAAAAaaaaaaOOOOOOooooooEEEEeeeeCcIIIIiiiiUUUUuuuuYyyNn';
    for (int i = 0; i < withAccents.length; i++) {
      text = text.replaceAll(withAccents[i], withoutAccents[i]);
    }
    return text;
  }

  static String extractHolderName(String subject, String fallbackHolder) {
    if (subject.isEmpty) return fallbackHolder;

    String holder = '';
    final parts = subject.split(',');
    for (var part in parts) {
      final trimmed = part.trim();
      if (trimmed.toUpperCase().startsWith('CN=')) {
        holder = trimmed.substring(3).trim();
        break;
      }
    }

    if (holder.isEmpty) holder = subject;
    holder = holder.replaceAll('"', '');

    if (holder.contains(':')) {
      final colonIndex = holder.indexOf(':');
      final namePart = holder.substring(0, colonIndex).trim();
      final docPart = holder.substring(colonIndex + 1).trim();
      return '${_removeAccents(namePart)}:\n$docPart';
    }

    return _removeAccents(holder);
  }

  static Size getVisualPdfSize(PdfPage page) {
    final clientSize = page.getClientSize();
    if (page.rotation == PdfPageRotateAngle.rotateAngle90 ||
        page.rotation == PdfPageRotateAngle.rotateAngle270) {
      return Size(clientSize.height, clientSize.width);
    }
    return Size(clientSize.width, clientSize.height);
  }

  static Future<void> signPdfWithP12({
    required String pdfPath,
    required String p12Path,
    required String password,
    required String outputPath,
    required Rect visualBounds,
    required int pageIndex,
    required String labelDigitallySigned,
    required String labelDate,
    required String labelUnknownHolder,
  }) async {
    final pdfBytes = await File(pdfPath).readAsBytes();
    final certBytes = await File(p12Path).readAsBytes();

    final PdfDocument document = PdfDocument(inputBytes: pdfBytes);
    final PdfPage page = document.pages[pageIndex];

    final clientSize = page.getClientSize();
    final double pageW = clientSize.width;
    final double pageH = clientSize.height;

    final double boxW = visualBounds.width;
    final double boxH = visualBounds.height;

    double pdfX = visualBounds.left;
    double pdfY = visualBounds.top;
    double finalBoxW = boxW;
    double finalBoxH = boxH;

    switch (page.rotation) {
      case PdfPageRotateAngle.rotateAngle90:
        pdfX = visualBounds.top;
        pdfY = pageH - visualBounds.left - boxW;
        finalBoxW = boxH;
        finalBoxH = boxW;
        break;
      case PdfPageRotateAngle.rotateAngle180:
        pdfX = pageW - visualBounds.left - boxW;
        pdfY = pageH - visualBounds.top - boxH;
        break;
      case PdfPageRotateAngle.rotateAngle270:
        pdfX = pageW - visualBounds.top - boxH;
        pdfY = visualBounds.left;
        finalBoxW = boxH;
        finalBoxH = boxW;
        break;
      case PdfPageRotateAngle.rotateAngle0:
        break;
    }

    pdfX = pdfX.clamp(0.0, (pageW - finalBoxW).clamp(0.0, pageW));
    pdfY = pdfY.clamp(0.0, (pageH - finalBoxH).clamp(0.0, pageH));

    final Rect bounds = Rect.fromLTWH(pdfX, pdfY, finalBoxW, finalBoxH);
    final String fieldName =
        'signature_${DateTime.now().millisecondsSinceEpoch}';

    final certificate = PdfCertificate(certBytes, password);

    final holderName = extractHolderName(
      certificate.subjectName,
      labelUnknownHolder,
    );
    final now = DateTime.now();
    final dateStr =
        '${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year} ${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';

    final signatureText =
        '$labelDigitallySigned\n'
        '$holderName\n'
        '$labelDate: $dateStr';

    page.graphics.drawRectangle(
      pen: PdfPen(PdfColor(0, 102, 204), width: 0.8),
      bounds: bounds,
    );

    page.graphics.drawString(
      signatureText,
      PdfStandardFont(PdfFontFamily.helvetica, 5.5, style: PdfFontStyle.bold),
      brush: PdfBrushes.black,
      bounds: Rect.fromLTWH(
        bounds.left + 3,
        bounds.top + 2,
        bounds.width - 6,
        bounds.height - 4,
      ),
      format: PdfStringFormat(
        alignment: PdfTextAlignment.left,
        lineAlignment: PdfVerticalAlignment.top,
      ),
    );

    final PdfSignatureField signatureField = PdfSignatureField(
      page,
      fieldName,
      bounds: bounds,
    );

    final appGraphics = signatureField.appearance.normal.graphics;
    appGraphics?.drawRectangle(
      pen: PdfPen(PdfColor(0, 102, 204), width: 0.8),
      bounds: Rect.fromLTWH(0, 0, bounds.width, bounds.height),
    );

    appGraphics?.drawString(
      signatureText,
      PdfStandardFont(PdfFontFamily.helvetica, 5.5, style: PdfFontStyle.bold),
      brush: PdfBrushes.black,
      bounds: Rect.fromLTWH(3, 2, bounds.width - 6, bounds.height - 4),
      format: PdfStringFormat(
        alignment: PdfTextAlignment.left,
        lineAlignment: PdfVerticalAlignment.top,
      ),
    );

    signatureField.signature = PdfSignature(
      certificate: certificate,
      digestAlgorithm: DigestAlgorithm.sha256,
      cryptographicStandard: CryptographicStandard.cms,
    );

    document.form.fields.add(signatureField);
    File(outputPath).writeAsBytesSync(await document.save());
    document.dispose();
  }
}
