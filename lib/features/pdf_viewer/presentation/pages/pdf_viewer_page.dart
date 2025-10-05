import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import '../../../../core/models/standard.dart';
import '../../../../core/providers/standards_provider.dart';
import '../widgets/pdf_search_bar.dart';
import '../widgets/pdf_navigation_drawer.dart';
import '../widgets/platform_pdf_viewer.dart';

class PdfViewerPage extends ConsumerStatefulWidget {
  final String standardType;
  final int initialPage;

  const PdfViewerPage({
    super.key,
    required this.standardType,
    this.initialPage = 1,
  });

  @override
  ConsumerState<PdfViewerPage> createState() => _PdfViewerPageState();
}

class _PdfViewerPageState extends ConsumerState<PdfViewerPage> {
  PdfViewerController? _pdfViewerController;
  bool _isSearchVisible = false;
  bool _isPdfLoaded = false;
  double _zoomLevel = 1.0;
  Timer? _zoomSyncTimer;

  @override
  void initState() {
    super.initState();
    // Only initialize controller for non-web platforms
    if (!kIsWeb) {
      _pdfViewerController = PdfViewerController();

      // Jump to initial page after a short delay
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (widget.initialPage > 1) {
          Future.delayed(const Duration(milliseconds: 500), () {
            _pdfViewerController?.jumpToPage(widget.initialPage);
          });
        }
      });
    }
  }

  void _syncZoomLevel() {
    if (_pdfViewerController != null && _isPdfLoaded) {
      final actualZoom = _pdfViewerController!.zoomLevel;
      if ((actualZoom - _zoomLevel).abs() > 0.01) {
        setState(() {
          _zoomLevel = actualZoom;
        });
        debugPrint('Synced zoom level to actual controller value: $actualZoom');
      }
    }
  }

  @override
  void dispose() {
    _zoomSyncTimer?.cancel();
    _pdfViewerController?.dispose();
    super.dispose();
  }

  StandardType? _getStandardType() {
    try {
      return StandardType.values.firstWhere(
        (e) => e.toString().split('.').last == widget.standardType,
      );
    } catch (e) {
      return null;
    }
  }

  void _showKeyboardShortcuts(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Keyboard Shortcuts'),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Navigation:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text('← / Page Up: Previous page'),
              Text('→ / Page Down: Next page'),
              Text('Home: First page'),
              Text('End: Last page'),
              SizedBox(height: 16),
              Text('Zoom:', style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Text('Ctrl + +: Zoom in'),
              Text('Ctrl + -: Zoom out'),
              Text('Ctrl + 0: Reset zoom'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _updateZoom(double newZoomLevel) {
    final clampedZoom = newZoomLevel.clamp(0.5, 3.0);

    debugPrint('Attempting to zoom to: $clampedZoom');

    if (_pdfViewerController != null && _isPdfLoaded) {
      try {
        // Force the zoom level change
        _pdfViewerController!.zoomLevel = clampedZoom;

        // Update the UI state
        setState(() {
          _zoomLevel = clampedZoom;
        });

        debugPrint('Zoom level set to: $clampedZoom');

        // Show a snackbar to confirm the zoom change
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Zoom: ${(clampedZoom * 100).round()}%'),
            duration: const Duration(milliseconds: 800),
          ),
        );
      } catch (e) {
        debugPrint('Error setting zoom level: $e');
        // Still update the UI even if controller fails
        setState(() {
          _zoomLevel = clampedZoom;
        });
      }
    } else {
      setState(() {
        _zoomLevel = clampedZoom;
      });
      debugPrint('Controller not ready, only updated UI zoom level');
    }
  }

  void _handleKeyEvent(KeyEvent event) {
    if (event is KeyDownEvent && _pdfViewerController != null) {
      if (HardwareKeyboard.instance.isControlPressed) {
        switch (event.logicalKey) {
          case LogicalKeyboardKey.equal:
          case LogicalKeyboardKey.numpadAdd:
            // Zoom in (Ctrl + +)
            if (_zoomLevel < 3.0) {
              _updateZoom(_zoomLevel + 0.25);
            }
            break;
          case LogicalKeyboardKey.minus:
          case LogicalKeyboardKey.numpadSubtract:
            // Zoom out (Ctrl + -)
            if (_zoomLevel > 0.5) {
              _updateZoom(_zoomLevel - 0.25);
            }
            break;
          case LogicalKeyboardKey.digit0:
          case LogicalKeyboardKey.numpad0:
            // Reset zoom (Ctrl + 0)
            _updateZoom(1.0);
            break;
        }
      } else {
        switch (event.logicalKey) {
          case LogicalKeyboardKey.arrowLeft:
          case LogicalKeyboardKey.pageUp:
            _pdfViewerController?.previousPage();
            break;
          case LogicalKeyboardKey.arrowRight:
          case LogicalKeyboardKey.pageDown:
            _pdfViewerController?.nextPage();
            break;
          case LogicalKeyboardKey.home:
            _pdfViewerController?.firstPage();
            break;
          case LogicalKeyboardKey.end:
            _pdfViewerController?.lastPage();
            break;
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final standardsAsync = ref.watch(standardsProvider);
    final standardType = _getStandardType();

    return KeyboardListener(
      focusNode: FocusNode(),
      autofocus: true,
      onKeyEvent: _handleKeyEvent,
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: standardsAsync.when(
            data: (standards) {
              final standard = standards.cast<Standard?>().firstWhere(
                (s) => s?.type == standardType,
                orElse: () => null,
              );
              return Text(standard?.name ?? 'PDF Viewer');
            },
            loading: () => const Text('PDF Viewer'),
            error: (_, __) => const Text('PDF Viewer'),
          ),
          actions: [
            // Zoom controls
            if (!kIsWeb) ...[
              IconButton(
                icon: const Icon(Icons.zoom_out),
                onPressed: _zoomLevel > 0.5
                    ? () => _updateZoom(_zoomLevel - 0.25)
                    : null,
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${(_zoomLevel * 100).round()}%',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.zoom_in),
                onPressed: _zoomLevel < 3.0
                    ? () => _updateZoom(_zoomLevel + 0.25)
                    : null,
              ),
            ],
            // Only show search for non-web platforms (Syncfusion limitation)
            if (!kIsWeb)
              IconButton(
                icon: Icon(_isSearchVisible ? Icons.search_off : Icons.search),
                onPressed: () {
                  setState(() {
                    _isSearchVisible = !_isSearchVisible;
                    if (!_isSearchVisible) {
                      _pdfViewerController?.clearSelection();
                    }
                  });
                },
              ),
            IconButton(
              icon: const Icon(Icons.bookmark_add),
              onPressed: () {
                // Add current page to bookmarks
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Page bookmarked'),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.help_outline),
              onPressed: () => _showKeyboardShortcuts(context),
            ),
          ],
        ),
        drawer: PdfNavigationDrawer(
          standardType: standardType,
          onPageSelected: (page) {
            _pdfViewerController?.jumpToPage(page);
            Navigator.of(context).pop();
          },
        ),
        body: Column(
          children: [
            if (_isSearchVisible && !kIsWeb)
              PdfSearchBar(
                onSearch: (query) {
                  if (query.isNotEmpty) {
                    _pdfViewerController?.searchText(query);
                  }
                },
                onClear: () {
                  _pdfViewerController?.clearSelection();
                },
              ),
            Expanded(
              child: standardsAsync.when(
                data: (standards) {
                  final standard = standards.cast<Standard?>().firstWhere(
                    (s) => s?.type == standardType,
                    orElse: () => null,
                  );

                  if (standard == null) {
                    return const Center(child: Text('Standard not found'));
                  }

                  return PlatformPdfViewer(
                    standard: standard,
                    controller: _pdfViewerController,
                    onDocumentLoaded: () {
                      setState(() {
                        _isPdfLoaded = true;
                      });
                      // Initialize zoom level after PDF loads with a longer delay
                      Future.delayed(const Duration(milliseconds: 500), () {
                        if (_pdfViewerController != null) {
                          final currentZoom = _pdfViewerController!.zoomLevel;
                          debugPrint(
                            'PDF loaded. Controller zoom: $currentZoom, UI zoom: $_zoomLevel',
                          );

                          // Sync the UI zoom level with the actual controller zoom level
                          setState(() {
                            _zoomLevel = currentZoom;
                          });

                          // Set up periodic sync to catch manual zoom changes
                          _zoomSyncTimer = Timer.periodic(
                            const Duration(seconds: 1),
                            (timer) {
                              if (!mounted) {
                                timer.cancel();
                                return;
                              }
                              _syncZoomLevel();
                            },
                          );
                        }
                      });
                      debugPrint(
                        'PDF loaded successfully: ${standard.pdfPath}',
                      );
                    },
                    onDocumentLoadFailed: (error) {
                      debugPrint('PDF load failed: $error');
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Failed to load PDF: $error'),
                          backgroundColor: Theme.of(context).colorScheme.error,
                          duration: const Duration(seconds: 5),
                        ),
                      );
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stack) => Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, size: 64),
                      const SizedBox(height: 16),
                      Text('Error loading PDF: $error'),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => ref.invalidate(standardsProvider),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        bottomNavigationBar: !kIsWeb && _isPdfLoaded
            ? Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  border: Border(
                    top: BorderSide(
                      color: Theme.of(
                        context,
                      ).colorScheme.outline.withValues(alpha: 0.2),
                    ),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Navigation controls
                    IconButton(
                      icon: const Icon(Icons.first_page),
                      onPressed: () => _pdfViewerController?.firstPage(),
                      tooltip: 'First Page',
                    ),
                    IconButton(
                      icon: const Icon(Icons.navigate_before),
                      onPressed: () => _pdfViewerController?.previousPage(),
                      tooltip: 'Previous Page',
                    ),
                    IconButton(
                      icon: const Icon(Icons.navigate_next),
                      onPressed: () => _pdfViewerController?.nextPage(),
                      tooltip: 'Next Page',
                    ),
                    IconButton(
                      icon: const Icon(Icons.last_page),
                      onPressed: () => _pdfViewerController?.lastPage(),
                      tooltip: 'Last Page',
                    ),

                    // Divider
                    Container(
                      height: 24,
                      width: 1,
                      color: Theme.of(
                        context,
                      ).colorScheme.outline.withValues(alpha: 0.3),
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                    ),

                    // Zoom controls
                    IconButton(
                      icon: const Icon(Icons.zoom_out),
                      onPressed: _zoomLevel > 0.5
                          ? () => _updateZoom(_zoomLevel - 0.25)
                          : null,
                      tooltip: 'Zoom Out',
                    ),
                    IconButton(
                      icon: const Icon(Icons.fit_screen),
                      onPressed: () => _updateZoom(1.0),
                      tooltip: 'Fit to Screen',
                    ),
                    IconButton(
                      icon: const Icon(Icons.zoom_in),
                      onPressed: _zoomLevel < 3.0
                          ? () => _updateZoom(_zoomLevel + 0.25)
                          : null,
                      tooltip: 'Zoom In',
                    ),
                  ],
                ),
              )
            : null,
        floatingActionButton: kIsWeb || !_isPdfLoaded
            ? null
            : Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Back to comparison button
                  FloatingActionButton.small(
                    heroTag: "back_fab",
                    onPressed: () => Navigator.of(context).pop(),
                    tooltip: 'Back',
                    child: const Icon(Icons.arrow_back),
                  ),
                  const SizedBox(height: 8),
                  // Zoom controls for mobile
                  if (MediaQuery.of(context).size.width < 600) ...[
                    FloatingActionButton.small(
                      heroTag: "zoom_in_fab",
                      onPressed: _zoomLevel < 3.0
                          ? () => _updateZoom(_zoomLevel + 0.25)
                          : null,
                      tooltip: 'Zoom In',
                      child: const Icon(Icons.zoom_in),
                    ),
                    const SizedBox(height: 8),
                    FloatingActionButton.small(
                      heroTag: "zoom_out_fab",
                      onPressed: _zoomLevel > 0.5
                          ? () => _updateZoom(_zoomLevel - 0.25)
                          : null,
                      tooltip: 'Zoom Out',
                      child: const Icon(Icons.zoom_out),
                    ),
                  ],
                ],
              ),
      ),
    );
  }
}
