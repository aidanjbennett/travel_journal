import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:travel_journal/database/app_database.dart';
import 'package:travel_journal/providers/settings_view_model.dart';

import '../helpers/database_helper.dart';
import '../helpers/fake_path_provider.dart';

void main() {
  late AppDatabase db;
  late Directory tempDir;

  setUp(() async {
    db = makeDb();
    tempDir = await Directory.systemTemp.createTemp('settings_test_');

    // Redirect path_provider to our temp directory
    PathProviderPlatform.instance = FakePathProvider(tempDir.path);
  });

  tearDown(() async {
    await db.close();
    if (await tempDir.exists()) await tempDir.delete(recursive: true);
  });

  group('clearAllData', () {
    test('returns true on success', () async {
      await insertEntry(db);
      final vm = SettingsViewModel(db);
      expect(await vm.clearAllData(), true);
    });

    test('removes all rows from the database', () async {
      await insertEntry(db, entryId: 'e1');
      await insertEntry(db, entryId: 'e2');

      final vm = SettingsViewModel(db);
      await vm.clearAllData();

      final remaining = await db.select(db.journalEntries).get();
      expect(remaining, isEmpty);
    });

    test('deletes image files referenced in entries', () async {
      final imageFile = File('${tempDir.path}/img.jpg');
      await imageFile.writeAsString('fake image');

      await insertEntry(db, imagePaths: jsonEncode([imageFile.path]));

      final vm = SettingsViewModel(db);
      await vm.clearAllData();

      expect(await imageFile.exists(), false);
    });

    test('deletes audio files referenced in entries', () async {
      final audioFile = File('${tempDir.path}/audio.mp3');
      await audioFile.writeAsString('fake audio');

      await insertEntry(db, audioPaths: jsonEncode([audioFile.path]));

      final vm = SettingsViewModel(db);
      await vm.clearAllData();

      expect(await audioFile.exists(), false);
    });

    test('continues if a referenced file does not exist', () async {
      await insertEntry(
        db,
        imagePaths: jsonEncode(['/nonexistent/path/img.jpg']),
      );

      final vm = SettingsViewModel(db);
      expect(await vm.clearAllData(), true);
    });

    test('continues if imagePaths JSON is malformed', () async {
      await insertEntry(db, imagePaths: 'not-valid-json');
      final vm = SettingsViewModel(db);
      expect(await vm.clearAllData(), true);
    });

    test('deletes files across multiple entries', () async {
      final file1 = File('${tempDir.path}/img1.jpg')..writeAsStringSync('a');
      final file2 = File('${tempDir.path}/img2.jpg')..writeAsStringSync('b');

      await insertEntry(
        db,
        entryId: 'e1',
        imagePaths: jsonEncode([file1.path]),
      );
      await insertEntry(
        db,
        entryId: 'e2',
        imagePaths: jsonEncode([file2.path]),
      );

      final vm = SettingsViewModel(db);
      await vm.clearAllData();

      expect(await file1.exists(), false);
      expect(await file2.exists(), false);
    });
  });
}
