import 'package:flutter/material.dart';

class EmptyStateWidget extends StatelessWidget {
  const EmptyStateWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.map_outlined, size: 72, color: color.outlineVariant),
          const SizedBox(height: 16),
          Text(
            'No entries yet',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(color: color.outline),
          ),
          const SizedBox(height: 6),
          Text(
            'Tap + on the map to add your first one.',
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: color.outlineVariant),
          ),
        ],
      ),
    );
  }
}
