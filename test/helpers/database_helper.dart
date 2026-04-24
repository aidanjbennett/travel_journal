import 'package:drift/native.dart';
import 'package:travel_journal/database/app_database.dart';

AppDatabase makeDb() => AppDatabase.forTesting(NativeDatabase.memory());

Future<void> insertEntry(
  AppDatabase db, {
  String entryId = 'e1',
  String imagePaths = '[]',
  String audioPaths = '[]',
}) async {
  await db
      .into(db.journalEntries)
      .insert(
        JournalEntriesCompanion.insert(
          entryId: entryId,
          title: 'Test Entry',
          body: 'Body text',
          latitude: 0.0,
          longitude: 0.0,
          locationName: 'Nowhere',
          imagePaths: imagePaths,
          audioPaths: audioPaths,
          createdAt: DateTime(2024, 1, 1),
          updatedAt: DateTime(2024, 1, 1),
        ),
      );
}
