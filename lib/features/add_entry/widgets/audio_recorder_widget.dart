import 'package:flutter/material.dart';

class AudioRecorderWidget extends StatelessWidget {
  const AudioRecorderWidget({
    super.key,
    required this.isRecording,
    required this.duration,
    required this.audioPaths,
    required this.onToggle,
    required this.onRemove,
    required this.formatDuration,
  });

  final bool isRecording;
  final Duration duration;
  final List<String> audioPaths;
  final VoidCallback onToggle;
  final void Function(int index) onRemove;
  final String Function(Duration) formatDuration;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Voice Memos', style: theme.textTheme.labelLarge),
        const SizedBox(height: 12),

        Row(
          children: [
            GestureDetector(
              onTap: onToggle,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: isRecording
                      ? colorScheme.errorContainer
                      : colorScheme.primaryContainer,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isRecording ? Icons.stop : Icons.mic,
                  color: isRecording
                      ? colorScheme.onErrorContainer
                      : colorScheme.onPrimaryContainer,
                ),
              ),
            ),
            const SizedBox(width: 16),
            if (isRecording) ...[
              Icon(Icons.circle, size: 10, color: colorScheme.error),
              const SizedBox(width: 6),
              Text(
                formatDuration(duration),
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.error,
                  fontFeatures: [const FontFeature.tabularFigures()],
                ),
              ),
            ] else
              Text(
                audioPaths.isEmpty ? 'Tap to record' : 'Tap to record another',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.outline,
                ),
              ),
          ],
        ),

        if (audioPaths.isNotEmpty) ...[
          const SizedBox(height: 12),
          ...List.generate(audioPaths.length, (i) {
            return ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(Icons.audiotrack, color: colorScheme.primary),
              title: Text(
                'Recording ${i + 1}',
                style: theme.textTheme.bodyMedium,
              ),
              trailing: IconButton(
                icon: Icon(Icons.delete_outline, color: colorScheme.error),
                onPressed: () => onRemove(i),
              ),
            );
          }),
        ],
      ],
    );
  }
}
