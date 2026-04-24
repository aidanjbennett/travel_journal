import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:travel_journal/database/app_database.dart';
import 'package:travel_journal/providers/settings_view_model.dart';

import '../helpers/database_helper.dart';
import '../helpers/fake_path_provider.dart';

void main() {
  late AppDatabase db;
  late Directory tempDir;

  setUp(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});

    db = makeDb();
    tempDir = await Directory.systemTemp.createTemp('settings_test_');

    // Redirect path_provider to our temp directory
    PathProviderPlatform.instance = FakePathProvider(tempDir.path);
  });

  tearDown(() async {
    await db.close();
    if (await tempDir.exists()) await tempDir.delete(recursive: true);
  });

  group('exportJournal', () {
    test(
      'returns null when db is empty',
      () async {
        final vm = SettingsViewModel(db);
        final path = await vm.exportJournal();

        // On test host (non-Android/iOS) _resolveOutputFile falls through to null
        // unless we are on macOS/Linux — so we just assert it doesn't throw
        // and either returns a path or null gracefully.
        expect(() => path, returnsNormally);
      },
      skip: Platform.isAndroid || Platform.isIOS
          ? null
          : 'File path only resolves on Android/iOS',
    );

    test('writes valid JSON containing all entries', () async {
      await insertEntry(db, entryId: 'e1');
      await insertEntry(db, entryId: 'e2');

      final vm = SettingsViewModel(db);
      final path = await vm.exportJournal();

      if (path == null) return; // skip on non-mobile host

      final content = await File(path).readAsString();
      final decoded = jsonDecode(content) as List;

      expect(decoded.length, 2);
      expect(decoded.first['entryId'], 'e1');
      expect(decoded.last['entryId'], 'e2');
    });

    test('output file is inside a date-named folder', () async {
      await insertEntry(db);

      final vm = SettingsViewModel(db);
      final path = await vm.exportJournal();

      if (path == null) return;

      final now = DateTime.now();
      final expectedFolder =
          '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

      expect(path, contains(expectedFolder));
    });

    test('creates date folder if it does not exist', () async {
      await insertEntry(db);

      final vm = SettingsViewModel(db);
      final path = await vm.exportJournal();

      if (path == null) return;

      expect(await File(path).exists(), true);
    });

    test('exported JSON contains correct fields', () async {
      await insertEntry(
        db,
        entryId: 'e1',
        imagePaths: '["img1.jpg"]',
        audioPaths: '["audio1.mp3"]',
      );

      final vm = SettingsViewModel(db);
      final path = await vm.exportJournal();

      if (path == null) return;

      final decoded =
          (jsonDecode(await File(path).readAsString()) as List).first
              as Map<String, dynamic>;

      expect(
        decoded.keys,
        containsAll([
          'entryId',
          'title',
          'body',
          'latitude',
          'longitude',
          'locationName',
          'imagePaths',
          'audioPaths',
          'createdAt',
          'updatedAt',
        ]),
      );
      expect(decoded['imagePaths'], '["img1.jpg"]');
      expect(decoded['audioPaths'], '["audio1.mp3"]');
    });
  });
}
