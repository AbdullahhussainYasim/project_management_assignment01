import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ContentSearchResult {
  final String standardName;
  final String heading;
  final int page;
  final String contentPreview;
  final double relevanceScore;
  final List<String> matchedKeywords;

  const ContentSearchResult({
    required this.standardName,
    required this.heading,
    required this.page,
    required this.contentPreview,
    required this.relevanceScore,
    required this.matchedKeywords,
  });
}

class ExtractedContent {
  final String fileName;
  final int totalPages;
  final List<ContentSection> sections;
  final Map<int, String> fullTextByPage;
  final List<ContentHeading> headings;

  const ExtractedContent({
    required this.fileName,
    required this.totalPages,
    required this.sections,
    required this.fullTextByPage,
    required this.headings,
  });

  factory ExtractedContent.fromJson(Map<String, dynamic> json) {
    return ExtractedContent(
      fileName: json['file_name'] ?? '',
      totalPages: json['total_pages'] ?? 0,
      sections:
      (json['sections'] as List?)
          ?.map((s) => ContentSection.fromJson(s))
          .toList() ??
          [],
      fullTextByPage: Map<int, String>.from(
        (json['full_text_by_page'] as Map?)?.map(
              (k, v) => MapEntry(int.parse(k.toString()), v.toString()),
        ) ??
            {},
      ),
      headings:
      (json['headings'] as List?)
          ?.map((h) => ContentHeading.fromJson(h))
          .toList() ??
          [],
    );
  }
}

class ContentSection {
  final String heading;
  final int level;
  final int pageStart;
  final int pageEnd;
  final String content;
  final List<String> keywords;

  const ContentSection({
    required this.heading,
    required this.level,
    required this.pageStart,
    required this.pageEnd,
    required this.content,
    required this.keywords,
  });

  factory ContentSection.fromJson(Map<String, dynamic> json) {
    return ContentSection(
      heading: json['heading'] ?? '',
      level: json['level'] ?? 1,
      pageStart: json['page_start'] ?? 1,
      pageEnd: json['page_end'] ?? 1,
      content: json['content'] ?? '',
      keywords: List<String>.from(json['keywords'] ?? []),
    );
  }
}

class ContentHeading {
  final String text;
  final int page;
  final int level;

  const ContentHeading({
    required this.text,
    required this.page,
    required this.level,
  });

  factory ContentHeading.fromJson(Map<String, dynamic> json) {
    return ContentHeading(
      text: json['text'] ?? '',
      page: json['page'] ?? 1,
      level: json['level'] ?? 1,
    );
  }
}

class ContentSearchNotifier
    extends StateNotifier<AsyncValue<List<ExtractedContent>>> {
  ContentSearchNotifier() : super(const AsyncValue.loading()) {
    _loadExtractedContent();
  }

  Future<void> _loadExtractedContent() async {
    try {
      final List<ExtractedContent> allContent = [];

      // List of content files to load
      final contentFiles = [
        'assets/extracted_content/standard1_content.json',
        'assets/extracted_content/standard2_content.json',
        // Add more as needed
      ];

      for (final filePath in contentFiles) {
        try {
          final jsonString = await rootBundle.loadString(filePath);
          final jsonData = json.decode(jsonString);
          final content = ExtractedContent.fromJson(jsonData);
          allContent.add(content);
        } catch (e) {
          // File might not exist, continue with others
          debugPrint('Could not load $filePath: $e');
        }
      }

      state = AsyncValue.data(allContent);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  List<ContentSearchResult> searchContent(String query) {
    return state.when(
      data: (content) => _performSearch(query, content),
      loading: () => [],
      error: (_, __) => [],
    );
  }

  List<ContentSearchResult> _performSearch(
      String query,
      List<ExtractedContent> allContent,
      ) {
    if (query.trim().isEmpty) return [];

    final results = <ContentSearchResult>[];
    final queryWords = query
        .toLowerCase()
        .split(' ')
        .where((w) => w.isNotEmpty)
        .toList();

    for (final content in allContent) {
      final standardName = content.fileName
          .replaceAll('.pdf', '')
          .replaceAll('_', ' ');

      // Search in sections
      for (final section in content.sections) {
        final relevanceScore = _calculateRelevance(queryWords, section);

        if (relevanceScore > 0) {
          final matchedKeywords = _findMatchedKeywords(queryWords, section);

          results.add(
            ContentSearchResult(
              standardName: standardName,
              heading: section.heading,
              page: section.pageStart,
              contentPreview: _generatePreview(section.content, queryWords),
              relevanceScore: relevanceScore,
              matchedKeywords: matchedKeywords,
            ),
          );
        }
      }

      // Search in full page text for more comprehensive results
      content.fullTextByPage.forEach((page, text) {
        final textRelevance = _calculateTextRelevance(queryWords, text);

        if (textRelevance > 0.5) {
          // Find the most relevant heading for this page
          final pageHeading = content.headings
              .where((h) => h.page <= page)
              .fold<ContentHeading?>(
            null,
                (prev, current) =>
            prev == null || current.page > prev.page ? current : prev,
          );

          if (pageHeading != null) {
            results.add(
              ContentSearchResult(
                standardName: standardName,
                heading: pageHeading.text,
                page: page,
                contentPreview: _generatePreview(text, queryWords),
                relevanceScore: textRelevance,
                matchedKeywords: queryWords
                    .where((w) => text.toLowerCase().contains(w))
                    .toList(),
              ),
            );
          }
        }
      });
    }

    // Sort by relevance score and remove duplicates
    results.sort((a, b) => b.relevanceScore.compareTo(a.relevanceScore));

    // Remove duplicates based on standard + page
    final uniqueResults = <ContentSearchResult>[];
    final seen = <String>{};

    for (final result in results) {
      final key = '${result.standardName}_${result.page}';
      if (!seen.contains(key)) {
        seen.add(key);
        uniqueResults.add(result);
      }
    }

    return uniqueResults.take(20).toList(); // Limit to top 20 results
  }

  double _calculateRelevance(List<String> queryWords, ContentSection section) {
    double score = 0;

    // Check heading matches (higher weight)
    final headingLower = section.heading.toLowerCase();
    for (final word in queryWords) {
      if (headingLower.contains(word)) {
        score += 3.0;
      }
    }

    // Check keyword matches
    final sectionKeywords = section.keywords
        .map((k) => k.toLowerCase())
        .toSet();
    for (final word in queryWords) {
      if (sectionKeywords.contains(word)) {
        score += 2.0;
      }
    }

    // Check content matches
    final contentLower = section.content.toLowerCase();
    for (final word in queryWords) {
      final matches = word.allMatches(contentLower).length;
      score += matches * 0.5;
    }

    return score;
  }

  double _calculateTextRelevance(List<String> queryWords, String text) {
    final textLower = text.toLowerCase();
    double score = 0;

    for (final word in queryWords) {
      final matches = word.allMatches(textLower).length;
      score += matches;
    }

    // Normalize by text length
    return score / (text.length / 1000);
  }

  List<String> _findMatchedKeywords(
      List<String> queryWords,
      ContentSection section,
      ) {
    final matched = <String>[];
    final headingLower = section.heading.toLowerCase();
    final contentLower = section.content.toLowerCase();
    final keywords = section.keywords.map((k) => k.toLowerCase()).toSet();

    for (final word in queryWords) {
      if (headingLower.contains(word) ||
          contentLower.contains(word) ||
          keywords.contains(word)) {
        matched.add(word);
      }
    }

    return matched;
  }

  String _generatePreview(String content, List<String> queryWords) {
    // Find the first occurrence of any query word
    final contentLower = content.toLowerCase();
    int bestIndex = -1;

    for (final word in queryWords) {
      final index = contentLower.indexOf(word);
      if (index != -1 && (bestIndex == -1 || index < bestIndex)) {
        bestIndex = index;
      }
    }

    if (bestIndex == -1) {
      return content.length > 200 ? '${content.substring(0, 200)}...' : content;
    }

    // Extract context around the match
    final start = (bestIndex - 100).clamp(0, content.length);
    final end = (bestIndex + 200).clamp(0, content.length);

    String preview = content.substring(start, end);
    if (start > 0) preview = '...$preview';
    if (end < content.length) preview = '$preview...';

    return preview;
  }
}

final contentSearchProvider =
StateNotifierProvider<
    ContentSearchNotifier,
    AsyncValue<List<ExtractedContent>>
>((ref) => ContentSearchNotifier());

final searchResultsProvider =
Provider.family<List<ContentSearchResult>, String>((ref, query) {
  final notifier = ref.read(contentSearchProvider.notifier);
  return notifier.searchContent(query);
});
