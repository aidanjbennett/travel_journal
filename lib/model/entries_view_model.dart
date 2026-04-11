import 'package:flutter/material.dart';
import 'package:travel_journal/providers/journal_provider.dart';
import 'package:travel_journal/shared/models/journal_entry_model.dart';

class EntriesViewModel extends ChangeNotifier {
  final JournalStore store;

  EntriesViewModel(this.store);

  Stream<List<JournalEntryModel>> get entriesStream {
    return store.watchEntries();
  }
}
