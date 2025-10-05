import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/providers/standards_provider.dart';
import 'standard_comparison_card.dart';

class ComparisonView extends ConsumerWidget {
  final String topicId;

  const ComparisonView({super.key, required this.topicId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final topicAsync = ref.watch(topicByIdProvider(topicId));
    final standardsAsync = ref.watch(standardsProvider);

    return topicAsync.when(
      data: (topic) {
        if (topic == null) {
          return const Center(child: Text('Topic not found'));
        }

        return standardsAsync.when(
          data: (standards) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Topic Header
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            topic.title,
                            style: Theme.of(context).textTheme.headlineSmall
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            topic.description,
                            style: Theme.of(context).textTheme.bodyLarge
                                ?.copyWith(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurfaceVariant,
                                ),
                          ),
                          if (topic.keywords.isNotEmpty) ...[
                            const SizedBox(height: 16),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: topic.keywords.map((keyword) {
                                return Chip(
                                  label: Text(keyword),
                                  backgroundColor: Theme.of(
                                    context,
                                  ).colorScheme.primaryContainer,
                                  labelStyle: TextStyle(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onPrimaryContainer,
                                  ),
                                );
                              }).toList(),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Comparison Cards
                  Text(
                    'Standards Comparison',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Desktop/Tablet: Side by side layout
                  if (MediaQuery.of(context).size.width > 800)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: standards
                          .where(
                            (standard) =>
                                topic.references.containsKey(standard.type),
                          )
                          .map((standard) {
                            final reference = topic.references[standard.type]!;
                            return Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(right: 16),
                                child: StandardComparisonCard(
                                  standard: standard,
                                  reference: reference,
                                  onViewPdf: () {
                                    context.push(
                                      '/pdf/${standard.type.toString().split('.').last}?page=${reference.page}',
                                    );
                                  },
                                ),
                              ),
                            );
                          })
                          .toList(),
                    )
                  // Mobile: Stacked layout
                  else
                    Column(
                      children: standards
                          .where(
                            (standard) =>
                                topic.references.containsKey(standard.type),
                          )
                          .map((standard) {
                            final reference = topic.references[standard.type]!;
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: StandardComparisonCard(
                                standard: standard,
                                reference: reference,
                                onViewPdf: () {
                                  context.push(
                                    '/pdf/${standard.type.toString().split('.').last}?page=${reference.page}',
                                  );
                                },
                              ),
                            );
                          })
                          .toList(),
                    ),

                  // Missing Standards Notice
                  if (topic.references.length < standards.length) ...[
                    const SizedBox(height: 16),
                    Card(
                      color: Theme.of(
                        context,
                      ).colorScheme.surfaceContainerHighest,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurfaceVariant,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'This topic is not covered in all standards or references are not yet available.',
                                style: TextStyle(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) =>
              Center(child: Text('Error loading standards: $error')),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) =>
          Center(child: Text('Error loading topic: $error')),
    );
  }
}
