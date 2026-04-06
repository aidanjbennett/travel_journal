import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:travel_journal/features/add_entry/widgets/photo_picker_widget.dart';
import 'package:travel_journal/features/add_entry/widgets/audio_recorder_widget.dart';
import 'package:travel_journal/shared/models/journal_entry_model.dart';

class AddEntryScreen extends StatefulWidget {
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
  State<AddEntryScreen> createState() => _AddEntryScreenState();
}

class _AddEntryScreenState extends State<AddEntryScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _textController = TextEditingController();
  final _picker = ImagePicker();

  final List<String> _imagePaths = [];
  final List<String> _audioPaths = [];

  final FlutterSoundRecorder _recorder = FlutterSoundRecorder();
  bool _recorderReady = false;
  bool _isRecording = false;
  Duration _recordingDuration = Duration.zero;

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _initRecorder();
  }

  Future<void> _initRecorder() async {
    await _recorder.openRecorder();
    _recorder.setSubscriptionDuration(const Duration(milliseconds: 500));
    setState(() => _recorderReady = true);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _textController.dispose();
    _recorder.closeRecorder();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    final XFile? file = await _picker.pickImage(
      source: source,
      imageQuality: 85,
    );
    if (file == null) return;
    setState(() => _imagePaths.add(file.path));
  }

  void _removeImage(int index) {
    setState(() => _imagePaths.removeAt(index));
  }

  void _showImageSourceSheet() {
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
                Navigator.of(context).pop();
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Choose from library'),
              onTap: () {
                Navigator.of(context).pop();
                _pickImage(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<String> _buildAudioPath() async {
    final dir = await getApplicationDocumentsDirectory();
    final filename = 'audio_${DateTime.now().millisecondsSinceEpoch}.aac';
    return '${dir.path}/$filename';
  }

  Future<void> _toggleRecording() async {
    if (!_recorderReady) return;

    if (_isRecording) {
      final path = await _recorder.stopRecorder();
      setState(() {
        _isRecording = false;
        _recordingDuration = Duration.zero;
        if (path != null) _audioPaths.add(path);
      });
    } else {
      final path = await _buildAudioPath();
      await _recorder.startRecorder(toFile: path, codec: Codec.aacADTS);
      _recorder.onProgress?.listen((event) {
        if (mounted) {
          setState(() => _recordingDuration = event.duration);
        }
      });
      setState(() => _isRecording = true);
    }
  }

  void _removeAudio(int index) {
    final path = _audioPaths[index];
    setState(() => _audioPaths.removeAt(index));
    File(path).deleteSync();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    if (_isRecording) await _toggleRecording();

    setState(() => _isSaving = true);

    final now = DateTime.now();
    final entry = JournalEntry(
      title: _titleController.text.trim(),
      text: _textController.text.trim(),
      latitude: widget.initialLatitude,
      longitude: widget.initialLongitude,
      locationName: widget.locationName,
      imagePaths: List.unmodifiable(_imagePaths),
      audioPaths: List.unmodifiable(_audioPaths),
      createdAt: now,
      updatedAt: now,
    );

    if (mounted) Navigator.of(context).pop(entry);
  }

  String _formatDuration(Duration d) {
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
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
            onPressed: _isSaving ? null : _save,
            child: _isSaving
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
                        widget.locationName,
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: colorScheme.primary,
                        ),
                        softWrap: true,
                      ),
                      Text(
                        '${widget.initialLatitude.toStringAsFixed(4)}, '
                        '${widget.initialLongitude.toStringAsFixed(4)}',
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
                  controller: _titleController,
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
                  controller: _textController,
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
                  paths: _imagePaths,
                  onAdd: _showImageSourceSheet,
                  onRemove: _removeImage,
                ),
                const SizedBox(height: 24),

                AudioRecorderWidget(
                  isRecording: _isRecording,
                  duration: _recordingDuration,
                  audioPaths: _audioPaths,
                  onToggle: _toggleRecording,
                  onRemove: _removeAudio,
                  formatDuration: _formatDuration,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
