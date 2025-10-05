import 'package:flutter/material.dart';

class WebPdfViewer extends StatefulWidget {
  final String assetPath;
  final VoidCallback? onDocumentLoaded;
  final Function(String)? onDocumentLoadFailed;

  const WebPdfViewer({
    super.key,
    required this.assetPath,
    this.onDocumentLoaded,
    this.onDocumentLoadFailed,
  });

  @override
  State<WebPdfViewer> createState() => _WebPdfViewerState();
}

class _WebPdfViewerState extends State<WebPdfViewer> {
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadPdf();
  }

  Future<void> _loadPdf() async {
    try {
      // Simulate loading for web
      await Future.delayed(const Duration(milliseconds: 500));

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
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _isLoading = true;
                  _error = null;
                });
                _loadPdf();
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    // For web, show a placeholder with download option
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.picture_as_pdf, size: 100, color: Colors.blue),
          const SizedBox(height: 24),
          Text('PDF Viewer', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 16),
          Text(
            'PDF viewing is limited on web browsers.\nFor the best experience, use the desktop app.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              // In a real app, this would trigger PDF download
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('PDF download would start here')),
              );
            },
            icon: const Icon(Icons.download),
            label: const Text('Download PDF'),
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: () {
              // Open PDF in new tab (would need actual URL)
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('PDF would open in new tab')),
              );
            },
            icon: const Icon(Icons.open_in_new),
            label: const Text('Open in New Tab'),
          ),
        ],
      ),
    );
  }
}
