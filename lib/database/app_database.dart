import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

part 'app_database.g.dart';

class JournalEntries extends Table {
  TextColumn get entryId => text()();
  TextColumn get title => text()();
  TextColumn get body => text()();
  RealColumn get latitude => real()();
  RealColumn get longitude => real()();
  TextColumn get locationName => text()();
  TextColumn get imagePaths => text()(); // stored as JSON
  TextColumn get audioPaths => text()(); // stored as JSON
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {entryId};
}

@DriftDatabase(tables: [JournalEntries])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  // Constructor for unit tests — uses an in-memory database instead of a file
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
}
