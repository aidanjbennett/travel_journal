import 'package:flutter/material.dart';
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

  bool _isSaving = false;

  @override
  void dispose() {
    _titleController.dispose();
    _textController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    final now = DateTime.now();
    final entry = JournalEntry(
      title: _titleController.text.trim(),
      text: _textController.text.trim(),
      latitude: widget.initialLatitude,
      longitude: widget.initialLongitude,
      locationName: widget.locationName,
      createdAt: now,
      updatedAt: now,
    );

    if (mounted) Navigator.of(context).pop(entry);
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
                  label: Text(
                    '${widget.initialLatitude.toStringAsFixed(4)}, '
                    '${widget.initialLongitude.toStringAsFixed(4)}',
                    style: theme.textTheme.bodySmall,
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
