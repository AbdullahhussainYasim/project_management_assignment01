import 'standard.dart';

class Topic {
  final String id;
  final String title;
  final String description;
  final Map<StandardType, TopicReference> references;
  final List<String> keywords;
  final AIComparison? aiComparison;

  const Topic({
    required this.id,
    required this.title,
    required this.description,
    required this.references,
    required this.keywords,
    this.aiComparison,
  });

  factory Topic.fromJson(Map<String, dynamic> json) {
    final referencesMap = <StandardType, TopicReference>{};

    if (json['references'] != null) {
      (json['references'] as Map<String, dynamic>).forEach((key, value) {
        final standardType = StandardType.values.firstWhere(
              (e) => e.toString().split('.').last == key,
        );
        referencesMap[standardType] = TopicReference.fromJson(value);
      });
    }

    return Topic(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      references: referencesMap,
      keywords: List<String>.from(json['keywords'] ?? []),
      aiComparison: json['ai_comparison'] != null
          ? AIComparison.fromJson(json['ai_comparison'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    final referencesJson = <String, dynamic>{};
    references.forEach((key, value) {
      referencesJson[key.toString().split('.').last] = value.toJson();
    });

    return {
      'id': id,
      'title': title,
      'description': description,
      'references': referencesJson,
      'keywords': keywords,
      'ai_comparison': aiComparison?.toJson(),
    };
  }
}

class TopicReference {
  final int page;
  final String section;
  final String? subsection;
  final String? excerpt;
  final List<TopicSection>? sections;

  const TopicReference({
    required this.page,
    required this.section,
    this.subsection,
    this.excerpt,
    this.sections,
  });

  factory TopicReference.fromJson(Map<String, dynamic> json) {
    return TopicReference(
      page: json['page'] ?? (json['pages'] as List?)?.first ?? 1,
      section: json['section'] ?? '',
      subsection: json['subsection'],
      excerpt: json['excerpt'],
      sections: json['sections'] != null
          ? (json['sections'] as List)
          .map((s) => TopicSection.fromJson(s))
          .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'page': page,
      'section': section,
      'subsection': subsection,
      'excerpt': excerpt,
      'sections': sections?.map((s) => s.toJson()).toList(),
    };
  }
}

class TopicSection {
  final String heading;
  final int page;
  final String contentPreview;
  final double relevanceScore;

  const TopicSection({
    required this.heading,
    required this.page,
    required this.contentPreview,
    required this.relevanceScore,
  });

  factory TopicSection.fromJson(Map<String, dynamic> json) {
    return TopicSection(
      heading: json['heading'] ?? '',
      page: json['page'] ?? 1,
      contentPreview: json['content_preview'] ?? '',
      relevanceScore: (json['relevance_score'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'heading': heading,
      'page': page,
      'content_preview': contentPreview,
      'relevance_score': relevanceScore,
    };
  }
}

class AIComparison {
  final String summary;
  final List<String> similarities;
  final List<ComparisonDifference> differences;
  final String recommendations;

  const AIComparison({
    required this.summary,
    required this.similarities,
    required this.differences,
    required this.recommendations,
  });

  factory AIComparison.fromJson(Map<String, dynamic> json) {
    return AIComparison(
      summary: json['summary'] ?? '',
      similarities: List<String>.from(json['similarities'] ?? []),
      differences:
      (json['differences'] as List?)
          ?.map((d) => ComparisonDifference.fromJson(d))
          .toList() ??
          [],
      recommendations: json['recommendations'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'summary': summary,
      'similarities': similarities,
      'differences': differences.map((d) => d.toJson()).toList(),
      'recommendations': recommendations,
    };
  }
}

class ComparisonDifference {
  final String aspect;
  final Map<String, String> standards;

  const ComparisonDifference({required this.aspect, required this.standards});

  factory ComparisonDifference.fromJson(Map<String, dynamic> json) {
    return ComparisonDifference(
      aspect: json['aspect'] ?? '',
      standards: Map<String, String>.from(json['standards'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {'aspect': aspect, 'standards': standards};
  }
}
