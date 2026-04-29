import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:travel_journal/database/app_database.dart';
import 'package:travel_journal/helper.dart';
import 'package:travel_journal/providers/entry_detail_view_model.dart';
import 'package:travel_journal/model/journal_entry_model.dart';
import 'package:travel_journal/screens/edit_entry_screen.dart';
import 'package:travel_journal/widgets/entry_detail/photo_grid_widget.dart';

class EntryDetailScreen extends StatelessWidget {
  const EntryDetailScreen({super.key, required this.entryId});

  final String entryId;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => EntryDetailViewModel()..initPlayer(),
      child: _EntryDetailView(entryId: entryId),
    );
  }
}

class _EntryDetailView extends StatelessWidget {
  const _EntryDetailView({required this.entryId});

  final String entryId;

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<EntryDetailViewModel>();
    final db = context.read<AppDatabase>();
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return StreamBuilder<JournalEntryModel?>(
      stream: db.watchEntry(entryId),
      builder: (context, snapshot) {
        final entry = snapshot.data;

        if (entry == null) {
          return Scaffold(
            appBar: AppBar(),
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: Text(entry.title),
            actions: [
              IconButton(
                tooltip: 'Edit',
                icon: const Icon(Icons.edit_outlined),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => EditEntryScreen(entry: entry),
                    ),
                  );
                },
              ),
            ],
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                  Text(
                    formatDateLong(entry.createdAt),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.outline,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(entry.body, style: theme.textTheme.bodyMedium),
                  if (entry.imagePaths.isNotEmpty) ...[
                    const SizedBox(height: 28),
                    Text('Photos', style: theme.textTheme.labelLarge),
                    const SizedBox(height: 12),
                    PhotoGrid(paths: entry.imagePaths),
                  ],
                  if (entry.audioPaths.isNotEmpty) ...[
                    const SizedBox(height: 28),
                    Text('Voice Memos', style: theme.textTheme.labelLarge),
                    const SizedBox(height: 12),
                    ...List.generate(entry.audioPaths.length, (i) {
                      final isPlaying = vm.playingIndex == i;
                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: isPlaying
                                ? colorScheme.primaryContainer
                                : colorScheme.surfaceContainerHighest,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            isPlaying ? Icons.stop : Icons.play_arrow,
                            color: isPlaying
                                ? colorScheme.primary
                                : colorScheme.onSurfaceVariant,
                          ),
                        ),
                        title: Text(
                          'Recording ${i + 1}',
                          style: theme.textTheme.bodyMedium,
                        ),
                        subtitle: isPlaying
                            ? Text(
                                'Playing…',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: colorScheme.primary,
                                ),
                              )
                            : null,
                        onTap: vm.transitioning
                            ? null
                            : () => vm.togglePlayback(i, entry.audioPaths),
                      );
                    }),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
