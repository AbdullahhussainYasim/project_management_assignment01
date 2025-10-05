import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/models/comparison.dart';
import 'insight_card.dart';

class InsightsDashboard extends StatelessWidget {
  final List<ComparisonInsight> insights;

  const InsightsDashboard({super.key, required this.insights});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Summary Cards
          _buildSummarySection(context),

          const SizedBox(height: 24),

          // Insights List
          Text(
            'Detailed Analysis',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: insights.length,
            separatorBuilder: (context, index) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              final insight = insights[index];
              return InsightCard(
                insight: insight,
                onViewComparison: () {
                  context.push('/comparison/${insight.topicId}');
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSummarySection(BuildContext context) {
    final totalSimilarities = insights
        .expand((insight) => insight.similarities)
        .length;

    final totalDifferences = insights
        .expand((insight) => insight.differences)
        .length;

    final totalUniquePoints = insights
        .expand((insight) => insight.uniquePoints.values)
        .expand((points) => points)
        .length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Overview',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _SummaryCard(
                icon: Icons.check_circle_outline,
                title: 'Similarities',
                count: totalSimilarities,
                color: Colors.green,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _SummaryCard(
                icon: Icons.compare_arrows,
                title: 'Differences',
                count: totalDifferences,
                color: Colors.orange,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _SummaryCard(
                icon: Icons.star_outline,
                title: 'Unique Points',
                count: totalUniquePoints,
                color: Colors.blue,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final int count;
  final Color color;

  const _SummaryCard({
    required this.icon,
    required this.title,
    required this.count,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              count.toString(),
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
