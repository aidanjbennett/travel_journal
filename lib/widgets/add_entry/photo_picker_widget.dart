import 'package:flutter/material.dart';
import 'package:travel_journal/widgets/add_entry/add_photo_tile_widget.dart';
import 'package:travel_journal/widgets/add_entry/photo_tile_widget.dart';

class PhotoPicker extends StatelessWidget {
  const PhotoPicker({
    super.key,
    required this.paths,
    required this.onAdd,
    required this.onRemove,
  });

  final List<String> paths;
  final VoidCallback onAdd;
  final void Function(int index) onRemove;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Photos', style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: 12),
        SizedBox(
          height: 100,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              // Add button always first
              AddPhotoTile(colorScheme: colorScheme, onTap: onAdd),
              const SizedBox(width: 8),
              ...List.generate(paths.length, (i) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: PhotoTile(path: paths[i], onRemove: () => onRemove(i)),
                );
              }),
            ],
          ),
        ),
      ],
    );
  }
}
