import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/providers/standards_provider.dart';
import '../widgets/topic_list.dart';
import '../widgets/comparison_view.dart';

class ComparisonPage extends ConsumerStatefulWidget {
  final String? selectedTopicId;

  const ComparisonPage({super.key, this.selectedTopicId});

  @override
  ConsumerState<ComparisonPage> createState() => _ComparisonPageState();
}

class _ComparisonPageState extends ConsumerState<ComparisonPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    // Set initial selected topic if provided
    if (widget.selectedTopicId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(selectedTopicProvider.notifier).state = widget.selectedTopicId;
        _tabController.animateTo(1); // Switch to comparison view
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final topicsAsync = ref.watch(topicsProvider);
    final selectedTopicId = ref.watch(selectedTopicProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Compare Standards'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.list), text: 'Topics'),
            Tab(icon: Icon(Icons.compare_arrows), text: 'Compare'),
          ],
        ),
        actions: [
          if (selectedTopicId != null)
            IconButton(
              icon: const Icon(Icons.insights),
              onPressed: () => context.push('/insights'),
              tooltip: 'View Insights',
            ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Topics List Tab
          topicsAsync.when(
            data: (topics) => TopicList(
              topics: topics,
              onTopicSelected: (topic) {
                ref.read(selectedTopicProvider.notifier).state = topic.id;
                _tabController.animateTo(1);
              },
            ),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stack) => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64),
                  const SizedBox(height: 16),
                  Text('Error loading topics: $error'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => ref.invalidate(topicsProvider),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          ),

          // Comparison View Tab
          selectedTopicId != null
              ? ComparisonView(topicId: selectedTopicId)
              : const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.compare_arrows, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text(
                        'Select a topic to compare',
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Choose a topic from the Topics tab to see\nside-by-side comparison across standards',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
        ],
      ),
    );
  }
}
