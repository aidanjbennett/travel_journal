import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:travel_journal/database/app_database.dart';
import 'package:travel_journal/providers/journal_provider.dart';
import 'package:travel_journal/shared/models/journal_entry_model.dart';

AppDatabase _createInMemoryDatabase() {
  return AppDatabase.forTesting(NativeDatabase.memory());
}

JournalEntryModel _makeEntry({
  String? entryId,
  String title = 'Test Entry',
  String body = 'Test body',
  double latitude = 51.5074,
  double longitude = -0.1278,
  String locationName = 'London, UK',
  DateTime? createdAt,
  DateTime? updatedAt,
}) {
  final now = DateTime.now();
  return JournalEntryModel(
    entryId: entryId,
    title: title,
    body: body,
    latitude: latitude,
    longitude: longitude,
    locationName: locationName,
    createdAt: createdAt ?? now,
    updatedAt: updatedAt ?? now,
  );
}

void main() {
  late AppDatabase db;
  late JournalStore store;

  setUp(() {
    db = _createInMemoryDatabase();
    store = JournalStore(db);
  });

  tearDown(() async {
    await db.close();
  });

  group('JournalStore', () {
    group('addEntry', () {
      test('persists a new entry to the database', () async {
        final entry = _makeEntry();
        await store.addEntry(entry);

        final result = await store.getEntry(entry.entryId);
        expect(result, isNotNull);
        expect(result!.entryId, equals(entry.entryId));
        expect(result.title, equals(entry.title));
        expect(result.body, equals(entry.body));
      });

      test('persists imagePaths correctly', () async {
        final entry = _makeEntry();
        final entryWithImages = JournalEntryModel(
          entryId: entry.entryId,
          title: entry.title,
          body: entry.body,
          latitude: entry.latitude,
          longitude: entry.longitude,
          locationName: entry.locationName,
          imagePaths: const ['path/to/image1.jpg', 'path/to/image2.jpg'],
          createdAt: entry.createdAt,
          updatedAt: entry.updatedAt,
        );

        await store.addEntry(entryWithImages);

        final result = await store.getEntry(entryWithImages.entryId);
        expect(
          result!.imagePaths,
          equals(['path/to/image1.jpg', 'path/to/image2.jpg']),
        );
      });

      test('persists audioPaths correctly', () async {
        final entry = JournalEntryModel(
          title: 'Audio Entry',
          body: 'Has audio',
          latitude: 51.5074,
          longitude: -0.1278,
          locationName: 'London, UK',
          audioPaths: const ['path/to/audio1.aac'],
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        await store.addEntry(entry);

        final result = await store.getEntry(entry.entryId);
        expect(result!.audioPaths, equals(['path/to/audio1.aac']));
      });
    });

    group('getEntry', () {
      test('returns null for a non-existent entry', () async {
        final result = await store.getEntry('non-existent-id');
        expect(result, isNull);
      });

      test('returns the correct entry by ID', () async {
        final entry1 = _makeEntry(title: 'Entry 1');
        final entry2 = _makeEntry(title: 'Entry 2');
        await store.addEntry(entry1);
        await store.addEntry(entry2);

        final result = await store.getEntry(entry1.entryId);
        expect(result!.title, equals('Entry 1'));
      });
    });

    group('updateEntry', () {
      test('updates title and body', () async {
        final entry = _makeEntry();
        await store.addEntry(entry);

        await store.updateEntry(
          JournalEntryModel(
            entryId: entry.entryId,
            title: 'Updated Title',
            body: 'Updated body',
            latitude: entry.latitude,
            longitude: entry.longitude,
            locationName: entry.locationName,
            createdAt: entry.createdAt,
            updatedAt: DateTime.now(),
          ),
        );

        final result = await store.getEntry(entry.entryId);
        expect(result!.title, equals('Updated Title'));
        expect(result.body, equals('Updated body'));
      });

      test('updates updatedAt timestamp', () async {
        final entry = _makeEntry();
        await store.addEntry(entry);

        await Future.delayed(const Duration(milliseconds: 10));
        final updatedAt = DateTime.now().add(const Duration(seconds: 1));

        await store.updateEntry(
          JournalEntryModel(
            entryId: entry.entryId,
            title: entry.title,
            body: entry.body,
            latitude: entry.latitude,
            longitude: entry.longitude,
            locationName: entry.locationName,
            createdAt: entry.createdAt,
            updatedAt: updatedAt,
          ),
        );

        final result = await store.getEntry(entry.entryId);
        expect(result!.updatedAt.isAfter(entry.createdAt), isTrue);
      });
    });

    group('removeEntry', () {
      test('removes the entry from the database', () async {
        final entry = _makeEntry();
        await store.addEntry(entry);

        await store.removeEntry(entry.entryId);

        final result = await store.getEntry(entry.entryId);
        expect(result, isNull);
      });

      test('does nothing for a non-existent entry', () async {
        await expectLater(store.removeEntry('non-existent-id'), completes);
      });
    });

    group('watchEntries', () {
      test('emits empty list when no entries exist', () async {
        expect(store.watchEntries(), emits(isEmpty));
      });

      test('emits updated list when entry is added', () async {
        final entry = _makeEntry();

        expect(
          store.watchEntries(),
          emitsThrough(
            predicate<List<JournalEntryModel>>(
              (list) => list.any((e) => e.entryId == entry.entryId),
            ),
          ),
        );

        await store.addEntry(entry);
      });

      test('emits entries in descending createdAt order', () async {
        final older = _makeEntry(
          title: 'Older',
          createdAt: DateTime(2024, 1, 1),
          updatedAt: DateTime(2024, 1, 1),
        );
        final newer = _makeEntry(
          title: 'Newer',
          createdAt: DateTime(2024, 6, 1),
          updatedAt: DateTime(2024, 6, 1),
        );

        await store.addEntry(older);
        await store.addEntry(newer);

        expect(
          store.watchEntries(),
          emitsThrough(
            predicate<List<JournalEntryModel>>(
              (list) =>
                  list.first.title == 'Newer' && list.last.title == 'Older',
            ),
          ),
        );
      });
    });
  });
}
