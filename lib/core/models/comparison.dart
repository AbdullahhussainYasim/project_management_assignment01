import 'standard.dart';

class ComparisonInsight {
  final String topicId;
  final String title;
  final List<String> similarities;
  final List<ComparisonDifference> differences;
  final Map<StandardType, List<String>> uniquePoints;

  const ComparisonInsight({
    required this.topicId,
    required this.title,
    required this.similarities,
    required this.differences,
    required this.uniquePoints,
  });

  factory ComparisonInsight.fromJson(Map<String, dynamic> json) {
    final uniquePointsMap = <StandardType, List<String>>{};

    if (json['uniquePoints'] != null) {
      (json['uniquePoints'] as Map<String, dynamic>).forEach((key, value) {
        final standardType = StandardType.values.firstWhere(
              (e) => e.toString().split('.').last == key,
        );
        uniquePointsMap[standardType] = List<String>.from(value);
      });
    }

    return ComparisonInsight(
      topicId: json['topicId'],
      title: json['title'],
      similarities: List<String>.from(json['similarities'] ?? []),
      differences:
      (json['differences'] as List<dynamic>?)
          ?.map((e) => ComparisonDifference.fromJson(e))
          .toList() ??
          [],
      uniquePoints: uniquePointsMap,
    );
  }

  Map<String, dynamic> toJson() {
    final uniquePointsJson = <String, dynamic>{};
    uniquePoints.forEach((key, value) {
      uniquePointsJson[key.toString().split('.').last] = value;
    });

    return {
      'topicId': topicId,
      'title': title,
      'similarities': similarities,
      'differences': differences.map((e) => e.toJson()).toList(),
      'uniquePoints': uniquePointsJson,
    };
  }
}

class ComparisonDifference {
  final String aspect;
  final Map<StandardType, String> descriptions;

  const ComparisonDifference({
    required this.aspect,
    required this.descriptions,
  });

  factory ComparisonDifference.fromJson(Map<String, dynamic> json) {
    final descriptionsMap = <StandardType, String>{};

    if (json['descriptions'] != null) {
      (json['descriptions'] as Map<String, dynamic>).forEach((key, value) {
        final standardType = StandardType.values.firstWhere(
              (e) => e.toString().split('.').last == key,
        );
        descriptionsMap[standardType] = value;
      });
    }

    return ComparisonDifference(
      aspect: json['aspect'],
      descriptions: descriptionsMap,
    );
  }

  Map<String, dynamic> toJson() {
    final descriptionsJson = <String, dynamic>{};
    descriptions.forEach((key, value) {
      descriptionsJson[key.toString().split('.').last] = value;
    });

    return {'aspect': aspect, 'descriptions': descriptionsJson};
  }
}
