import 'package:flutter/material.dart';

class AddPhotoTile extends StatelessWidget {
  const AddPhotoTile({
    super.key,
    required this.colorScheme,
    required this.onTap,
  });

  final ColorScheme colorScheme;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 100,
        height: 100,
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: colorScheme.outlineVariant, width: 1.5),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_a_photo_outlined, color: colorScheme.primary),
            const SizedBox(height: 6),
            Text(
              'Add photo',
              style: TextStyle(fontSize: 11, color: colorScheme.primary),
            ),
          ],
        ),
      ),
    );
  }
}
