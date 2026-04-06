import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:travel_journal/database/app_database.dart';
import 'package:travel_journal/shared/models/journal_entry_model.dart';

class JournalStore extends ChangeNotifier {
  final AppDatabase _db;

  JournalStore(this._db);

  // Returns a stream that emits a fresh list whenever the database changes
  Stream<List<JournalEntryModel>> watchEntries() {
    return (_db.select(_db.journalEntries)
          ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
        .watch()
        .map((rows) => rows.map(_fromRow).toList());
  }

  Future<void> addEntry(JournalEntryModel entry) async {
    await _db.transaction(() async {
      await _db.into(_db.journalEntries).insert(_toCompanion(entry));
    });
  }

  Future<void> removeEntry(String entryId) async {
    await _db.transaction(() async {
      final entry = await (_db.select(
        _db.journalEntries,
      )..where((t) => t.entryId.equals(entryId))).getSingleOrNull();

      if (entry == null) return;

      // Delete associated audio files from disk
      for (final path
          in (jsonDecode(entry.audioPaths) as List).cast<String>()) {
        final file = File(path);
        if (file.existsSync()) file.deleteSync();
      }

      // Delete associated image files from disk
      for (final path
          in (jsonDecode(entry.imagePaths) as List).cast<String>()) {
        final file = File(path);
        if (file.existsSync()) file.deleteSync();
      }

      // Remove the row from the database
      await (_db.delete(
        _db.journalEntries,
      )..where((t) => t.entryId.equals(entryId))).go();
    });
  }

  JournalEntryModel _fromRow(JournalEntry row) {
    return JournalEntryModel(
      title: row.title,
      body: row.body,
      latitude: row.latitude,
      longitude: row.longitude,
      locationName: row.locationName,
      imagePaths: (jsonDecode(row.imagePaths) as List).cast<String>(),
      audioPaths: (jsonDecode(row.audioPaths) as List).cast<String>(),
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
    );
  }

  JournalEntriesCompanion _toCompanion(JournalEntryModel entry) {
    return JournalEntriesCompanion(
      entryId: Value(entry.entryId),
      title: Value(entry.title),
      body: Value(entry.body),
      latitude: Value(entry.latitude),
      longitude: Value(entry.longitude),
      locationName: Value(entry.locationName),
      imagePaths: Value(jsonEncode(entry.imagePaths)),
      audioPaths: Value(jsonEncode(entry.audioPaths)),
      createdAt: Value(entry.createdAt),
      updatedAt: Value(entry.updatedAt),
    );
  }
}
