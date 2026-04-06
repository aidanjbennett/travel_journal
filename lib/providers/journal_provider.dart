import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:travel_journal/shared/models/journal_entry_model.dart';

class JournalStore extends ChangeNotifier {
  final List<JournalEntry> _entries = [];

  List<JournalEntry> get entries => List.unmodifiable(_entries);

  void addEntry(JournalEntry entry) {
    _entries.insert(0, entry); // newest first
    notifyListeners();
  }

  void removeEntry(String entryId) {
    final entry = _entries.firstWhere((e) => e.entryId == entryId);

    // Delete the audio and photo data itself
    for (final path in entry.audioPaths) {
      final file = File(path);
      if (file.existsSync()) file.deleteSync();
    }

    for (final path in entry.imagePaths) {
      final file = File(path);
      if (file.existsSync()) file.deleteSync();
    }

    _entries.removeWhere((e) => e.entryId == entryId);
    notifyListeners();
  }
}
