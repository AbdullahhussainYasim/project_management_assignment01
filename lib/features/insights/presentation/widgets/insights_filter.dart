import 'package:flutter/material.dart';

class InsightsFilter extends StatelessWidget {
  final String selectedFilter;
  final Function(String) onFilterChanged;

  const InsightsFilter({
    super.key,
    required this.selectedFilter,
    required this.onFilterChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
          ),
        ),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _FilterChip(
              label: 'All',
              value: 'all',
              selectedValue: selectedFilter,
              onSelected: onFilterChanged,
              icon: Icons.view_list,
            ),
            const SizedBox(width: 8),
            _FilterChip(
              label: 'Similarities',
              value: 'similarities',
              selectedValue: selectedFilter,
              onSelected: onFilterChanged,
              icon: Icons.check_circle_outline,
              color: Colors.green,
            ),
            const SizedBox(width: 8),
            _FilterChip(
              label: 'Differences',
              value: 'differences',
              selectedValue: selectedFilter,
              onSelected: onFilterChanged,
              icon: Icons.compare_arrows,
              color: Colors.orange,
            ),
            const SizedBox(width: 8),
            _FilterChip(
              label: 'Unique Points',
              value: 'unique',
              selectedValue: selectedFilter,
              onSelected: onFilterChanged,
              icon: Icons.star_outline,
              color: Colors.blue,
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final String value;
  final String selectedValue;
  final Function(String) onSelected;
  final IconData icon;
  final Color? color;

  const _FilterChip({
    required this.label,
    required this.value,
    required this.selectedValue,
    required this.onSelected,
    required this.icon,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = selectedValue == value;
    final chipColor = color ?? Theme.of(context).colorScheme.primary;

    return FilterChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: isSelected ? Colors.white : chipColor),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : chipColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
      selected: isSelected,
      onSelected: (_) => onSelected(value),
      backgroundColor: chipColor.withValues(alpha: 0.1),
      selectedColor: chipColor,
      checkmarkColor: Colors.white,
      side: BorderSide(color: chipColor.withValues(alpha: 0.3)),
    );
  }
}
