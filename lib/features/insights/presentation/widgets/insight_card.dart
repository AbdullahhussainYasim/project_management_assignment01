import 'package:flutter/material.dart';
import '../../../../core/models/comparison.dart';
import '../../../../core/models/standard.dart';
import '../../../../core/theme/app_theme.dart';

class InsightCard extends StatefulWidget {
  final ComparisonInsight insight;
  final VoidCallback onViewComparison;

  const InsightCard({
    super.key,
    required this.insight,
    required this.onViewComparison,
  });

  @override
  State<InsightCard> createState() => _InsightCardState();
}

class _InsightCardState extends State<InsightCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          InkWell(
            onTap: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.insight.title,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            _buildBadge(
                              context,
                              Icons.check_circle_outline,
                              '${widget.insight.similarities.length}',
                              Colors.green,
                            ),
                            const SizedBox(width: 8),
                            _buildBadge(
                              context,
                              Icons.compare_arrows,
                              '${widget.insight.differences.length}',
                              Colors.orange,
                            ),
                            const SizedBox(width: 8),
                            _buildBadge(
                              context,
                              Icons.star_outline,
                              '${widget.insight.uniquePoints.values.expand((e) => e).length}',
                              Colors.blue,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    _isExpanded ? Icons.expand_less : Icons.expand_more,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ],
              ),
            ),
          ),

          // Expanded Content
          if (_isExpanded) ...[
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Similarities
                  if (widget.insight.similarities.isNotEmpty) ...[
                    _buildSectionHeader(
                      context,
                      Icons.check_circle_outline,
                      'Similarities',
                      Colors.green,
                    ),
                    const SizedBox(height: 8),
                    ...widget.insight.similarities.map((similarity) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              margin: const EdgeInsets.only(top: 6, right: 8),
                              width: 4,
                              height: 4,
                              decoration: const BoxDecoration(
                                color: Colors.green,
                                shape: BoxShape.circle,
                              ),
                            ),
                            Expanded(
                              child: Text(
                                similarity,
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                    const SizedBox(height: 16),
                  ],

                  // Differences
                  if (widget.insight.differences.isNotEmpty) ...[
                    _buildSectionHeader(
                      context,
                      Icons.compare_arrows,
                      'Key Differences',
                      Colors.orange,
                    ),
                    const SizedBox(height: 8),
                    ...widget.insight.differences.map((difference) {
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Theme.of(context)
                              .colorScheme
                              .surfaceContainerHighest
                              .withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              difference.aspect,
                              style: Theme.of(context).textTheme.titleSmall
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            ...difference.descriptions.entries.map((entry) {
                              final color = AppTheme.getStandardColor(
                                entry.key,
                              );
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 4),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      margin: const EdgeInsets.only(
                                        top: 2,
                                        right: 8,
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 6,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: color,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        _getStandardShortName(entry.key),
                                        style: const TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Text(
                                        entry.value,
                                        style: Theme.of(
                                          context,
                                        ).textTheme.bodySmall,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }),
                          ],
                        ),
                      );
                    }),
                    const SizedBox(height: 16),
                  ],

                  // Unique Points
                  if (widget.insight.uniquePoints.isNotEmpty) ...[
                    _buildSectionHeader(
                      context,
                      Icons.star_outline,
                      'Unique Points',
                      Colors.blue,
                    ),
                    const SizedBox(height: 8),
                    ...widget.insight.uniquePoints.entries.map((entry) {
                      final color = AppTheme.getStandardColor(entry.key);
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: color.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: color.withValues(alpha: 0.3),
                                    ),
                                  ),
                                  child: Text(
                                    _getStandardShortName(entry.key),
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: color,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            ...entry.value.map((point) {
                              return Padding(
                                padding: const EdgeInsets.only(
                                  left: 16,
                                  bottom: 2,
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      margin: const EdgeInsets.only(
                                        top: 6,
                                        right: 8,
                                      ),
                                      width: 4,
                                      height: 4,
                                      decoration: BoxDecoration(
                                        color: color,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    Expanded(
                                      child: Text(
                                        point,
                                        style: Theme.of(
                                          context,
                                        ).textTheme.bodySmall,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }),
                          ],
                        ),
                      );
                    }),
                  ],

                  // Action Button
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: widget.onViewComparison,
                      icon: const Icon(Icons.compare_arrows),
                      label: const Text('View Detailed Comparison'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBadge(
    BuildContext context,
    IconData icon,
    String count,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            count,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(
    BuildContext context,
    IconData icon,
    String title,
    Color color,
  ) {
    return Row(
      children: [
        Icon(icon, size: 20, color: color),
        const SizedBox(width: 8),
        Text(
          title,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  String _getStandardShortName(StandardType standardType) {
    switch (standardType) {
      case StandardType.pmbok:
        return 'PMBOK';
      case StandardType.prince2:
        return 'PRINCE2';
      case StandardType.iso21500:
        return 'ISO 21500';
      case StandardType.iso21502:
        return 'ISO 21502';
    }
  }
}
