import 'dart:io';

import 'package:flutter/material.dart';
import 'package:travel_journal/features/entry_detail/widgets/fullscreen_photo_viewer_widget.dart';

class PhotoGrid extends StatelessWidget {
  const PhotoGrid({super.key, required this.paths});

  final List<String> paths;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: paths.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemBuilder: (context, index) => GestureDetector(
        onTap: () => _openFullscreen(context, index),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Image.file(File(paths[index]), fit: BoxFit.cover),
        ),
      ),
    );
  }

  void _openFullscreen(BuildContext context, int initialIndex) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) =>
            FullscreenPhotoViewer(paths: paths, initialIndex: initialIndex),
      ),
    );
  }
}
