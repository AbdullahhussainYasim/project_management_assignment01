import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import '../../../../core/models/standard.dart';
import 'enhanced_web_pdf_viewer.dart';
import 'pdf_placeholder.dart';

class PlatformPdfViewer extends StatefulWidget {
  final Standard standard;
  final PdfViewerController? controller;
  final VoidCallback? onDocumentLoaded;
  final Function(String)? onDocumentLoadFailed;

  const PlatformPdfViewer({
    super.key,
    required this.standard,
    this.controller,
    this.onDocumentLoaded,
    this.onDocumentLoadFailed,
  });

  @override
  State<PlatformPdfViewer> createState() => _PlatformPdfViewerState();
}

class _PlatformPdfViewerState extends State<PlatformPdfViewer> {
  @override
  Widget build(BuildContext context) {
    // Use web-compatible viewer for web platform
    if (kIsWeb) {
      return EnhancedWebPdfViewer(
        assetPath: widget.standard.pdfPath,
        onDocumentLoaded: widget.onDocumentLoaded,
        onDocumentLoadFailed: widget.onDocumentLoadFailed,
      );
    }

    // Use Syncfusion for native platforms
    try {
      return SfPdfViewer.asset(
        widget.standard.pdfPath,
        controller: widget.controller,
        enableDoubleTapZooming: true,
        enableTextSelection: true,
        canShowScrollHead: true,
        canShowScrollStatus: true,
        onDocumentLoaded: (PdfDocumentLoadedDetails details) {
          debugPrint('PDF loaded successfully: ${widget.standard.pdfPath}');
          widget.onDocumentLoaded?.call();
        },
        onDocumentLoadFailed: (PdfDocumentLoadFailedDetails details) {
          debugPrint('PDF load failed: ${details.error}');
          widget.onDocumentLoadFailed?.call(details.error);
        },
      );
    } catch (e) {
      debugPrint('Exception loading PDF: $e');
      return PdfPlaceholder(standard: widget.standard);
    }
  }
}
