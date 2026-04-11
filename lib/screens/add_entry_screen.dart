import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:travel_journal/model/add_entry_view_model.dart';
import 'package:travel_journal/shared/models/journal_entry_model.dart';
import 'package:travel_journal/widgets/add_entry/audio_recorder_widget.dart';
import 'package:travel_journal/widgets/add_entry/photo_picker_widget.dart';

class AddEntryScreen extends StatelessWidget {
  const AddEntryScreen({
    super.key,
    required this.initialLatitude,
    required this.initialLongitude,
    required this.locationName,
  });

  final double initialLatitude;
  final double initialLongitude;
  final String locationName;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AddEntryViewModel(
        initialLatitude: initialLatitude,
        initialLongitude: initialLongitude,
        locationName: locationName,
      ),
      child: const _AddEntryView(),
    );
  }
}

class _AddEntryView extends StatefulWidget {
  const _AddEntryView();

  @override
  State<_AddEntryView> createState() => _AddEntryViewState();
}

class _AddEntryViewState extends State<_AddEntryView> {
  final _formKey = GlobalKey<FormState>();

  void _showImageSourceSheet(BuildContext context) {
    final vm = context.read<AddEntryViewModel>();

    showModalBottomSheet<void>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt_outlined),
              title: const Text('Take a photo'),
              onTap: () {
                Navigator.pop(context);
                vm.pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Choose from library'),
              onTap: () {
                Navigator.pop(context);
                vm.pickImage(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AddEntryViewModel>();
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('New Entry'),
        leading: IconButton(
          tooltip: 'Discard',
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          FilledButton(
            onPressed: vm.isSaving
                ? null
                : () async {
                    final JournalEntryModel? entry = await vm.save(_formKey);

                    if (entry != null && context.mounted) {
                      Navigator.of(context).pop(entry);
                    }
                  },
            child: vm.isSaving
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Save'),
          ),
          const SizedBox(width: 8),
        ],
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
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
                        vm.locationName,
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: colorScheme.primary,
                        ),
                      ),
                      Text(
                        '${vm.initialLatitude.toStringAsFixed(4)}, '
                        '${vm.initialLongitude.toStringAsFixed(4)}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontSize: 10,
                          color: colorScheme.outline,
                        ),
                      ),
                    ],
                  ),
                  backgroundColor: colorScheme.primaryContainer,
                ),
                const SizedBox(height: 24),
                TextFormField(
                  controller: vm.titleController,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(
                    labelText: 'Title',
                    hintText: 'Where are you?',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) => (value == null || value.trim().isEmpty)
                      ? 'Please enter a title'
                      : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: vm.textController,
                  textCapitalization: TextCapitalization.sentences,
                  maxLines: 10,
                  decoration: const InputDecoration(
                    labelText: 'Journal entry',
                    hintText: 'Write about your experience…',
                    border: OutlineInputBorder(),
                    alignLabelWithHint: true,
                  ),
                  validator: (value) => (value == null || value.trim().isEmpty)
                      ? 'Please write something'
                      : null,
                ),
                const SizedBox(height: 24),
                PhotoPicker(
                  paths: vm.imagePaths,
                  onAdd: () => _showImageSourceSheet(context),
                  onRemove: vm.removeImage,
                ),
                const SizedBox(height: 24),
                AudioRecorderWidget(
                  isRecording: vm.isRecording,
                  duration: vm.recordingDuration,
                  audioPaths: vm.audioPaths,
                  onToggle: vm.toggleRecording,
                  onRemove: vm.removeAudio,
                  formatDuration: vm.formatDuration,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
