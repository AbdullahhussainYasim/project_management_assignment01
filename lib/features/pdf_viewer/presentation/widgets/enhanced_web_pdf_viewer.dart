import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';

class EnhancedWebPdfViewer extends StatefulWidget {
  final String assetPath;
  final VoidCallback? onDocumentLoaded;
  final Function(String)? onDocumentLoadFailed;

  const EnhancedWebPdfViewer({
    super.key,
    required this.assetPath,
    this.onDocumentLoaded,
    this.onDocumentLoadFailed,
  });

  @override
  State<EnhancedWebPdfViewer> createState() => _EnhancedWebPdfViewerState();
}

class _EnhancedWebPdfViewerState extends State<EnhancedWebPdfViewer> {
  bool _isLoading = true;
  String? _error;
  String? _pdfDataUrl;

  @override
  void initState() {
    super.initState();
    _loadPdf();
  }

  Future<void> _loadPdf() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      // Load PDF from assets
      final ByteData data = await rootBundle.load(widget.assetPath);
      final Uint8List bytes = data.buffer.asUint8List();

      // Convert to base64 data URL
      final base64String = base64Encode(bytes);
      _pdfDataUrl = 'data:application/pdf;base64,$base64String';

      setState(() {
        _isLoading = false;
      });

      widget.onDocumentLoaded?.call();
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = 'Error loading PDF: $e';
      });
      widget.onDocumentLoadFailed?.call(e.toString());
    }
  }

  void _downloadPdf() {
    if (_pdfDataUrl != null && kIsWeb) {
      // Create download link
      final fileName = widget.assetPath.split('/').last;

      // In a real implementation, you would use dart:html
      // For now, show a message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Download $fileName'),
          action: SnackBarAction(label: 'OK', onPressed: () {}),
        ),
      );
    }
  }

  void _openInNewTab() {
    if (_pdfDataUrl != null && kIsWeb) {
      // In a real implementation, you would use dart:html to open window
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('PDF would open in new tab')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Loading PDF...'),
          ],
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              _error!,
              style: const TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: _loadPdf, child: const Text('Retry')),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.picture_as_pdf,
                  size: 80,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(height: 16),
                Text(
                  'PDF Document Ready',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  widget.assetPath.split('/').last,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          Text(
            'Web PDF Viewer Options',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          Text(
            'Due to browser security limitations, PDFs cannot be displayed inline.\nChoose an option below to view the document.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 32),
          Wrap(
            spacing: 16,
            runSpacing: 16,
            alignment: WrapAlignment.center,
            children: [
              ElevatedButton.icon(
                onPressed: _downloadPdf,
                icon: const Icon(Icons.download),
                label: const Text('Download PDF'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
              ),
              OutlinedButton.icon(
                onPressed: _openInNewTab,
                icon: const Icon(Icons.open_in_new),
                label: const Text('Open in New Tab'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'For the best PDF viewing experience, use the desktop version of this app.',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
