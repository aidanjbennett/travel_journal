import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:travel_journal/database/app_database.dart';

class SettingsViewModel extends ChangeNotifier {
  static const _themePrefKey = 'is_dark_mode';

  final AppDatabase _db;

  bool _isDarkMode = false;
  bool get isDarkMode => _isDarkMode;
  ThemeMode get themeMode => _isDarkMode ? ThemeMode.dark : ThemeMode.light;

  SettingsViewModel(this._db) {
    _loadThemePreference();
  }

  Future<void> _loadThemePreference() async {
    final prefs = await SharedPreferences.getInstance();
    _isDarkMode = prefs.getBool(_themePrefKey) ?? false;
    notifyListeners();
  }

  Future<void> toggleTheme(bool value) async {
    _isDarkMode = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_themePrefKey, value);
  }

  Future<String?> exportJournal() async {
    try {
      final entries = await _db.select(_db.journalEntries).get();

      final json = jsonEncode(
        entries
            .map(
              (e) => {
                'entryId': e.entryId,
                'title': e.title,
                'body': e.body,
                'latitude': e.latitude,
                'longitude': e.longitude,
                'locationName': e.locationName,
                'imagePaths': e.imagePaths,
                'audioPaths': e.audioPaths,
                'createdAt': e.createdAt.toIso8601String(),
                'updatedAt': e.updatedAt.toIso8601String(),
              },
            )
            .toList(),
      );

      final now = DateTime.now();
      final file = await _resolveOutputFile(now);

      if (file == null) return null;

      await file.writeAsString(json, flush: true);
      return file.path;
    } catch (e) {
      debugPrint('Export failed: $e');
      return null;
    }
  }

  Future<File?> _resolveOutputFile(DateTime now) async {
    final folderName =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    final filename = 'journal_backup_${now.millisecondsSinceEpoch}.json';

    if (Platform.isAndroid) {
      if (await _requestStoragePermissionIfNeeded()) {
        final dir = Directory('/storage/emulated/0/Download/$folderName');
        if (!await dir.exists()) await dir.create(recursive: true);
        return File('${dir.path}/$filename');
      }
      return null;
    }

    if (Platform.isIOS) {
      final base = await getApplicationDocumentsDirectory();
      final dir = Directory('${base.path}/$folderName');
      if (!await dir.exists()) await dir.create(recursive: true);
      return File('${dir.path}/$filename');
    }

    return null;
  }

  Future<bool> _requestStoragePermissionIfNeeded() async {
    // Android 10+ doesn't need WRITE_EXTERNAL_STORAGE for Downloads
    if (await Permission.storage.isGranted) return true;
    final result = await Permission.storage.request();
    return result.isGranted;
  }

  Future<bool> clearAllData() async {
    try {
      final entries = await _db.select(_db.journalEntries).get();

      for (final entry in entries) {
        await _deleteFiles(entry.imagePaths);
        await _deleteFiles(entry.audioPaths);
      }

      await _db.delete(_db.journalEntries).go();
      return true;
    } catch (e) {
      debugPrint('Clear failed: $e');
      return false;
    }
  }

  Future<void> _deleteFiles(String pathsJson) async {
    try {
      final paths = List<String>.from(jsonDecode(pathsJson));
      for (final path in paths) {
        final file = File(path);
        if (await file.exists()) await file.delete();
      }
    } catch (e) {
      debugPrint('Failed to delete files: $e');
    }
  }
}
