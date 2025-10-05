import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/models/topic.dart';
import '../../../../core/models/standard.dart';
import '../../../../core/providers/standards_provider.dart';
import '../../../../core/theme/app_theme.dart';

class SearchResults extends ConsumerWidget {
  final List<Topic> results;
  final String query;
  final Function(Topic) onTopicSelected;

  const SearchResults({
    super.key,
    required this.results,
    required this.query,
    required this.onTopicSelected,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookmarks = ref.watch(bookmarksProvider);

    if (results.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.search_off, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              'No results found for "$query"',
              style: const TextStyle(fontSize: 18, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            const Text(
              'Try different keywords or check spelling',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Results Header
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            '${results.length} result${results.length == 1 ? '' : 's'} for "$query"',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
        ),

        // Results List
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: results.length,
            itemBuilder: (context, index) {
              final topic = results[index];
              final isBookmarked = bookmarks.contains(topic.id);

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: InkWell(
                  onTap: () => onTopicSelected(topic),
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: RichText(
                                text: _highlightSearchTerm(
                                  topic.title,
                                  query,
                                  Theme.of(context).textTheme.titleMedium!
                                      .copyWith(fontWeight: FontWeight.bold),
                                  Theme.of(context).colorScheme.primary,
                                ),
                              ),
                            ),
                            IconButton(
                              icon: Icon(
                                isBookmarked
                                    ? Icons.bookmark
                                    : Icons.bookmark_border,
                                color: isBookmarked
                                    ? Theme.of(context).colorScheme.primary
                                    : null,
                              ),
                              onPressed: () {
                                ref
                                    .read(bookmarksProvider.notifier)
                                    .toggleBookmark(topic.id);
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        RichText(
                          text: _highlightSearchTerm(
                            topic.description,
                            query,
                            Theme.of(context).textTheme.bodyMedium!.copyWith(
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurfaceVariant,
                            ),
                            Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Standards indicators
                        Row(
                          children: [
                            Text(
                              'Available in:',
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(width: 8),
                            ...topic.references.keys.map((standardType) {
                              final color = AppTheme.getStandardColor(
                                standardType,
                              );
                              return Container(
                                margin: const EdgeInsets.only(right: 8),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: color.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: color.withValues(alpha: 0.3),
                                  ),
                                ),
                                child: Text(
                                  _getStandardShortName(standardType),
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: color,
                                  ),
                                ),
                              );
                            }),
                          ],
                        ),

                        // Matching keywords
                        if (_getMatchingKeywords(
                          topic.keywords,
                          query,
                        ).isNotEmpty) ...[
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 6,
                            runSpacing: 6,
                            children:
                            _getMatchingKeywords(topic.keywords, query).map(
                                  (keyword) {
                                return Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.primaryContainer,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    keyword,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall
                                        ?.copyWith(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onPrimaryContainer,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                );
                              },
                            ).toList(),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  TextSpan _highlightSearchTerm(
      String text,
      String query,
      TextStyle baseStyle,
      Color highlightColor,
      ) {
    if (query.isEmpty) {
      return TextSpan(text: text, style: baseStyle);
    }

    final lowercaseText = text.toLowerCase();
    final lowercaseQuery = query.toLowerCase();
    final spans = <TextSpan>[];

    int start = 0;
    int index = lowercaseText.indexOf(lowercaseQuery);

    while (index != -1) {
      // Add text before match
      if (index > start) {
        spans.add(
          TextSpan(text: text.substring(start, index), style: baseStyle),
        );
      }

      // Add highlighted match
      spans.add(
        TextSpan(
          text: text.substring(index, index + query.length),
          style: baseStyle.copyWith(
            backgroundColor: highlightColor.withValues(alpha: 0.2),
            fontWeight: FontWeight.bold,
          ),
        ),
      );

      start = index + query.length;
      index = lowercaseText.indexOf(lowercaseQuery, start);
    }

    // Add remaining text
    if (start < text.length) {
      spans.add(TextSpan(text: text.substring(start), style: baseStyle));
    }

    return TextSpan(children: spans);
  }

  List<String> _getMatchingKeywords(List<String> keywords, String query) {
    final lowercaseQuery = query.toLowerCase();
    return keywords
        .where((keyword) => keyword.toLowerCase().contains(lowercaseQuery))
        .toList();
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
