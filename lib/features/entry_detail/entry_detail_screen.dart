import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:travel_journal/features/entry_detail/widgets/photo_grid_widget.dart';
import 'package:travel_journal/helper.dart';
import 'package:travel_journal/shared/models/journal_entry_model.dart';

class EntryDetailScreen extends StatefulWidget {
  const EntryDetailScreen({super.key, required this.entry});

  final JournalEntry entry;

  @override
  State<EntryDetailScreen> createState() => _EntryDetailScreenState();
}

class _EntryDetailScreenState extends State<EntryDetailScreen> {
  final FlutterSoundPlayer _player = FlutterSoundPlayer();
  bool _playerReady = false;
  int? _playingIndex;

  @override
  void initState() {
    super.initState();
    _initPlayer();
  }

  Future<void> _initPlayer() async {
    await _player.openPlayer();
    _player.setSubscriptionDuration(const Duration(milliseconds: 100));
    setState(() => _playerReady = true);
  }

  @override
  void dispose() {
    _player.closePlayer();
    super.dispose();
  }

  Future<void> _togglePlayback(int index) async {
    if (!_playerReady) return;

    if (_playingIndex == index) {
      await _player.stopPlayer();
      setState(() => _playingIndex = null);
      return;
    }

    if (_player.isPlaying) await _player.stopPlayer();

    await _player.startPlayer(
      fromURI: widget.entry.audioPaths[index],
      codec: Codec.aacADTS,
      whenFinished: () {
        if (mounted) setState(() => _playingIndex = null);
      },
    );

    setState(() => _playingIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(title: Text(widget.entry.title)),
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
                      widget.entry.locationName,
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: colorScheme.primary,
                      ),
                    ),
                    Text(
                      '${widget.entry.latitude.toStringAsFixed(4)}, '
                      '${widget.entry.longitude.toStringAsFixed(4)}',
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
                formatDate(widget.entry.createdAt),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.outline,
                ),
              ),
              const SizedBox(height: 20),

              Text(widget.entry.text, style: theme.textTheme.bodyMedium),

              if (widget.entry.imagePaths.isNotEmpty) ...[
                const SizedBox(height: 28),
                Text('Photos', style: theme.textTheme.labelLarge),
                const SizedBox(height: 12),
                PhotoGrid(paths: widget.entry.imagePaths),
              ],

              if (widget.entry.audioPaths.isNotEmpty) ...[
                const SizedBox(height: 28),
                Text('Voice Memos', style: theme.textTheme.labelLarge),
                const SizedBox(height: 12),
                ...List.generate(widget.entry.audioPaths.length, (i) {
                  final isPlaying = _playingIndex == i;
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
                    onTap: () => _togglePlayback(i),
                  );
                }),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
