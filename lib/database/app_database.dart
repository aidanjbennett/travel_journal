import 'dart:convert';
import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:travel_journal/model/journal_entry_model.dart';
part 'app_database.g.dart';

class JournalEntries extends Table {
  TextColumn get entryId => text()();
  TextColumn get title => text()();
  TextColumn get body => text()();
  RealColumn get latitude => real()();
  RealColumn get longitude => real()();
  TextColumn get locationName => text()();
  TextColumn get imagePaths => text()();
  TextColumn get audioPaths => text()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {entryId};
}

@DriftDatabase(tables: [JournalEntries])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());
  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 1;

  static QueryExecutor _openConnection() {
    return LazyDatabase(() async {
      final dir = await getApplicationDocumentsDirectory();
      final file = File(p.join(dir.path, 'travel_journal.db'));
      return NativeDatabase.createInBackground(file);
    });
  }

  Stream<List<JournalEntryModel>> watchEntries() {
    return (select(journalEntries)
          ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
        .watch()
        .map((rows) => rows.map(_rowToModel).toList());
  }

  Stream<JournalEntryModel?> watchEntry(String entryId) {
    return (select(journalEntries)..where((t) => t.entryId.equals(entryId)))
        .watchSingleOrNull()
        .map((row) => row == null ? null : _rowToModel(row));
  }

  Future<void> updateEntry(JournalEntryModel entry) {
    return (update(
      journalEntries,
    )..where((t) => t.entryId.equals(entry.entryId))).write(
      JournalEntriesCompanion(
        title: Value(entry.title),
        body: Value(entry.body),
        imagePaths: Value(jsonEncode(entry.imagePaths)),
        audioPaths: Value(jsonEncode(entry.audioPaths)),
        updatedAt: Value(entry.updatedAt),
      ),
    );
  }

  JournalEntryModel _rowToModel(JournalEntry row) {
    return JournalEntryModel(
      entryId: row.entryId,
      title: row.title,
      body: row.body,
      latitude: row.latitude,
      longitude: row.longitude,
      locationName: row.locationName,
      imagePaths: List<String>.from(jsonDecode(row.imagePaths)),
      audioPaths: List<String>.from(jsonDecode(row.audioPaths)),
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
    );
  }

  Future<void> removeEntry(String entryId) async {
    await transaction(() async {
      final row = await (select(
        journalEntries,
      )..where((t) => t.entryId.equals(entryId))).getSingleOrNull();

      if (row == null) return;

      for (final path in (jsonDecode(row.audioPaths) as List).cast<String>()) {
        final file = File(path);
        if (file.existsSync()) file.deleteSync();
      }

      for (final path in (jsonDecode(row.imagePaths) as List).cast<String>()) {
        final file = File(path);
        if (file.existsSync()) file.deleteSync();
      }

      await (delete(
        journalEntries,
      )..where((t) => t.entryId.equals(entryId))).go();
    });
  }
}
