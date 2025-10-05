import 'package:flutter/material.dart';
import '../../../../core/models/standard.dart';

class PdfNavigationDrawer extends StatelessWidget {
  final StandardType? standardType;
  final Function(int) onPageSelected;

  const PdfNavigationDrawer({
    super.key,
    required this.standardType,
    required this.onPageSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Table of Contents',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _getStandardName(),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                ),
              ],
            ),
          ),
          Expanded(child: ListView(children: _buildTableOfContents())),
        ],
      ),
    );
  }

  String _getStandardName() {
    switch (standardType) {
      case StandardType.pmbok:
        return 'PMBOK Guide 7th Edition';
      case StandardType.prince2:
        return 'PRINCE2 2017 Edition';
      case StandardType.iso21500:
        return 'ISO 21500:2021';
      case StandardType.iso21502:
        return 'ISO 21502:2020';
      default:
        return 'Unknown Standard';
    }
  }

  List<Widget> _buildTableOfContents() {
    // This would typically come from a JSON file or API
    // For now, we'll use sample data based on the standard type
    final chapters = _getChapters();

    return chapters.map((chapter) {
      return ExpansionTile(
        leading: Icon(Icons.folder_outlined, color: _getStandardColor()),
        title: Text(
          chapter['title'],
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text('Page ${chapter['page']}'),
        children: (chapter['sections'] as List<Map<String, dynamic>>).map((
          section,
        ) {
          return ListTile(
            leading: const Icon(Icons.article_outlined, size: 20),
            title: Text(section['title'], style: const TextStyle(fontSize: 14)),
            subtitle: Text('Page ${section['page']}'),
            contentPadding: const EdgeInsets.only(left: 56, right: 16),
            onTap: () => onPageSelected(section['page']),
          );
        }).toList(),
      );
    }).toList();
  }

  Color _getStandardColor() {
    switch (standardType) {
      case StandardType.pmbok:
        return const Color(0xFF4CAF50);
      case StandardType.prince2:
        return const Color(0xFF9C27B0);
      case StandardType.iso21500:
      case StandardType.iso21502:
        return const Color(0xFFFF9800);
      default:
        return Colors.grey;
    }
  }

  List<Map<String, dynamic>> _getChapters() {
    switch (standardType) {
      case StandardType.pmbok:
        return [
          {
            'title': '1. Introduction',
            'page': 1,
            'sections': [
              {'title': '1.1 Purpose of the Guide', 'page': 3},
              {'title': '1.2 What is a Project?', 'page': 5},
              {'title': '1.3 Project Management', 'page': 8},
            ],
          },
          {
            'title': '2. The Environment in Which Projects Operate',
            'page': 15,
            'sections': [
              {'title': '2.1 Overview', 'page': 15},
              {'title': '2.2 Enterprise Environmental Factors', 'page': 17},
              {'title': '2.3 Organizational Process Assets', 'page': 20},
            ],
          },
          {
            'title': '11. Project Risk Management',
            'page': 120,
            'sections': [
              {'title': '11.1 Plan Risk Management', 'page': 122},
              {'title': '11.2 Identify Risks', 'page': 125},
              {'title': '11.3 Perform Qualitative Risk Analysis', 'page': 128},
            ],
          },
        ];
      case StandardType.prince2:
        return [
          {
            'title': 'Introduction',
            'page': 1,
            'sections': [
              {'title': 'What is PRINCE2?', 'page': 3},
              {'title': 'Structure of the Manual', 'page': 5},
            ],
          },
          {
            'title': 'Risk Theme',
            'page': 88,
            'sections': [
              {'title': 'Purpose', 'page': 88},
              {'title': 'Risk Management Approach', 'page': 90},
              {'title': 'Risk Register', 'page': 92},
            ],
          },
        ];
      case StandardType.iso21500:
        return [
          {
            'title': '1. Scope',
            'page': 1,
            'sections': [
              {'title': '1.1 General', 'page': 1},
            ],
          },
          {
            'title': '4.3.8 Risk',
            'page': 54,
            'sections': [
              {'title': 'Risk Management Process', 'page': 54},
              {'title': 'Risk Assessment', 'page': 56},
            ],
          },
        ];
      default:
        return [];
    }
  }
}
