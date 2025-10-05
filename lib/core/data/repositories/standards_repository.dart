import 'dart:convert';
import 'package:flutter/services.dart';
import '../../models/standard.dart';
import '../../models/topic.dart';
import '../../models/comparison.dart' as comp;

class StandardsRepository {
  static const String _standardsPath = 'assets/data/standards.json';
  static const String _topicsPath = 'assets/data/topics.json';
  static const String _insightsPath = 'assets/data/insights.json';

  List<Standard>? _cachedStandards;
  List<Topic>? _cachedTopics;
  List<comp.ComparisonInsight>? _cachedInsights;

  Future<List<Standard>> getStandards() async {
    if (_cachedStandards != null) return _cachedStandards!;

    try {
      final jsonString = await rootBundle.loadString(_standardsPath);
      final List<dynamic> jsonList = json.decode(jsonString);
      _cachedStandards = jsonList
          .map((json) => Standard.fromJson(json))
          .toList();
      return _cachedStandards!;
    } catch (e) {
      // Return default standards if file doesn't exist
      _cachedStandards = _getDefaultStandards();
      return _cachedStandards!;
    }
  }

  Future<List<Topic>> getTopics() async {
    if (_cachedTopics != null) return _cachedTopics!;

    try {
      final jsonString = await rootBundle.loadString(_topicsPath);
      final List<dynamic> jsonList = json.decode(jsonString);
      _cachedTopics = jsonList.map((json) => Topic.fromJson(json)).toList();
      return _cachedTopics!;
    } catch (e) {
      // Return default topics if file doesn't exist
      _cachedTopics = _getDefaultTopics();
      return _cachedTopics!;
    }
  }

  Future<List<comp.ComparisonInsight>> getInsights() async {
    if (_cachedInsights != null) return _cachedInsights!;

    try {
      final jsonString = await rootBundle.loadString(_insightsPath);
      final List<dynamic> jsonList = json.decode(jsonString);
      _cachedInsights = jsonList
          .map((json) => comp.ComparisonInsight.fromJson(json))
          .toList();
      return _cachedInsights!;
    } catch (e) {
      // Return default insights if file doesn't exist
      _cachedInsights = _getDefaultInsights();
      return _cachedInsights!;
    }
  }

  Future<Topic?> getTopicById(String id) async {
    final topics = await getTopics();
    try {
      return topics.firstWhere((topic) => topic.id == id);
    } catch (e) {
      return null;
    }
  }

  Future<List<Topic>> searchTopics(String query) async {
    final topics = await getTopics();
    final lowercaseQuery = query.toLowerCase();

    return topics.where((topic) {
      return topic.title.toLowerCase().contains(lowercaseQuery) ||
          topic.description.toLowerCase().contains(lowercaseQuery) ||
          topic.keywords.any(
            (keyword) => keyword.toLowerCase().contains(lowercaseQuery),
          );
    }).toList();
  }

  List<Standard> _getDefaultStandards() {
    return [
      const Standard(
        type: StandardType.pmbok,
        name: 'PMBOK Guide',
        version: '7th Edition',
        pdfPath: 'assets/pdfs/pmbok7.pdf',
        description: 'Project Management Body of Knowledge',
        color: '#4CAF50',
      ),
      const Standard(
        type: StandardType.prince2,
        name: 'PRINCE2',
        version: '2017 Edition',
        pdfPath: 'assets/pdfs/prince2.pdf',
        description: 'Projects in Controlled Environments',
        color: '#9C27B0',
      ),
      const Standard(
        type: StandardType.iso21500,
        name: 'ISO 21500',
        version: '2021',
        pdfPath: 'assets/pdfs/iso21500.pdf',
        description: 'Guidance on Project Management',
        color: '#FF9800',
      ),
    ];
  }

  List<Topic> _getDefaultTopics() {
    return [
      Topic(
        id: 'risk_management',
        title: 'Risk Management',
        description: 'Identifying, analyzing, and responding to project risks',
        keywords: ['risk', 'uncertainty', 'threat', 'opportunity'],
        references: {
          StandardType.pmbok: const TopicReference(
            page: 120,
            section: '11. Project Risk Management',
            excerpt:
                'Risk management includes the processes of conducting risk management planning...',
          ),
          StandardType.prince2: const TopicReference(
            page: 88,
            section: 'Risk Theme',
            excerpt:
                'The purpose of the Risk theme is to identify, assess and control uncertainty...',
          ),
          StandardType.iso21500: const TopicReference(
            page: 54,
            section: '4.3.8 Risk',
            excerpt:
                'Risk management should be an integral part of project management...',
          ),
        },
      ),
    ];
  }

  List<comp.ComparisonInsight> _getDefaultInsights() {
    return [
      comp.ComparisonInsight(
        topicId: 'risk_management',
        title: 'Risk Management Comparison',
        similarities: [
          'All standards require risk identification',
          'Risk assessment is fundamental across all frameworks',
          'Risk response planning is emphasized',
        ],
        differences: [
          const comp.ComparisonDifference(
            aspect: 'Risk Categories',
            descriptions: {
              StandardType.pmbok: 'Uses qualitative and quantitative analysis',
              StandardType.prince2: 'Categorizes risks by theme and tolerance',
              StandardType.iso21500: 'Focuses on systematic risk processes',
            },
          ),
        ],
        uniquePoints: {
          StandardType.pmbok: [
            'Monte Carlo simulation',
            'Expected Monetary Value',
          ],
          StandardType.prince2: ['Risk tolerance', 'Risk appetite'],
          StandardType.iso21500: [
            'Risk governance',
            'Stakeholder risk perception',
          ],
        },
      ),
    ];
  }

  void clearCache() {
    _cachedStandards = null;
    _cachedTopics = null;
    _cachedInsights = null;
  }
}
