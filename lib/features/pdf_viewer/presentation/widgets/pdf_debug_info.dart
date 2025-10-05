import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/models/standard.dart';

class PdfDebugInfo extends StatefulWidget {
  final Standard standard;

  const PdfDebugInfo({super.key, required this.standard});

  @override
  State<PdfDebugInfo> createState() => _PdfDebugInfoState();
}

class _PdfDebugInfoState extends State<PdfDebugInfo> {
  bool _isChecking = false;
  String _result = '';

  @override
  void initState() {
    super.initState();
    _checkAsset();
  }

  Future<void> _checkAsset() async {
    setState(() {
      _isChecking = true;
      _result = 'Checking asset...';
    });

    try {
      final data = await rootBundle.load(widget.standard.pdfPath);
      setState(() {
        _result = 'Asset found! Size: ${data.lengthInBytes} bytes';
        _isChecking = false;
      });
    } catch (e) {
      setState(() {
        _result = 'Asset not found: $e';
        _isChecking = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Debug: ${widget.standard.name}')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Standard Information',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text('Name: ${widget.standard.name}'),
                    Text('Version: ${widget.standard.version}'),
                    Text('Type: ${widget.standard.type}'),
                    Text('PDF Path: ${widget.standard.pdfPath}'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Asset Check',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const Spacer(),
                        if (_isChecking)
                          const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(_result),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _isChecking ? null : _checkAsset,
                      child: const Text('Recheck Asset'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Troubleshooting Steps',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text('1. Ensure PDF file exists in assets/pdfs/'),
                    const Text('2. Check file name matches exactly'),
                    const Text('3. Run "flutter pub get"'),
                    const Text('4. Restart the app'),
                    const Text('5. Check console for error messages'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
