import 'package:flutter/material.dart';
import 'package:travel_journal/database/app_database.dart';
import 'package:travel_journal/model/journal_entry_model.dart';

class EntriesViewModel extends ChangeNotifier {
  final AppDatabase _db;

  EntriesViewModel(this._db);

  Stream<List<JournalEntryModel>> get entriesStream => _db.watchEntries();
}
