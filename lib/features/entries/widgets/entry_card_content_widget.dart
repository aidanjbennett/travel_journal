import 'package:flutter/material.dart';
import 'package:travel_journal/shared/models/journal_entry_model.dart';

class EntryCardContent extends StatelessWidget {
  const EntryCardContent({super.key, required this.entry});

  final JournalEntry entry;

  String get _formattedDate {
    final d = entry.createdAt;
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[d.month - 1]} ${d.day}, ${d.year}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = theme.colorScheme;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: color.outlineVariant.withOpacity(0.5)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    entry.title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  _formattedDate,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: color.outline,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              entry.body,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: color.onSurfaceVariant,
                height: 1.45,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 1),
                  child: Icon(
                    Icons.location_on_outlined,
                    size: 14,
                    color: color.primary,
                  ),
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        entry.locationName,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: color.primary,
                          fontWeight: FontWeight.w600,
                          height: 1.4,
                        ),
                        softWrap: true,
                      ),
                      const SizedBox(height: 1),
                      Text(
                        '${entry.latitude.toStringAsFixed(4)}, '
                        '${entry.longitude.toStringAsFixed(4)}',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: color.outline,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
