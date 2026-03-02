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
    _entries.removeWhere((e) => e.entryId == entryId);
    notifyListeners();
  }
}
