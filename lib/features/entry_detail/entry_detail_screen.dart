import 'package:flutter/material.dart';
import 'package:travel_journal/features/entry_detail/widgets/photo_grid_widget.dart';
import 'package:travel_journal/shared/models/journal_entry_model.dart';

class EntryDetailScreen extends StatelessWidget {
  const EntryDetailScreen({super.key, required this.entry});

  final JournalEntry entry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(title: Text(entry.title)),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Location chip
              Chip(
                avatar: Icon(
                  Icons.location_on,
                  size: 16,
                  color: colorScheme.primary,
                ),
                label: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      entry.locationName,
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: colorScheme.primary,
                      ),
                    ),
                    Text(
                      '${entry.latitude.toStringAsFixed(4)}, '
                      '${entry.longitude.toStringAsFixed(4)}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontSize: 10,
                        color: colorScheme.outline,
                      ),
                    ),
                  ],
                ),
                backgroundColor: colorScheme.primaryContainer,
              ),
              const SizedBox(height: 8),

              // Date
              Text(
                _formatDate(entry.createdAt),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.outline,
                ),
              ),
              const SizedBox(height: 20),

              // Journal text
              Text(entry.text, style: theme.textTheme.bodyMedium),

              // Photos
              if (entry.imagePaths.isNotEmpty) ...[
                const SizedBox(height: 28),
                Text('Photos', style: theme.textTheme.labelLarge),
                const SizedBox(height: 12),
                PhotoGrid(paths: entry.imagePaths),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime dt) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return '${months[dt.month - 1]} ${dt.day}, ${dt.year}';
  }
}
