// AI Transparency Statement
// I Aidan Bennett did not use AI for this bit of work

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:travel_journal/database/app_database.dart';
import 'package:travel_journal/screens/entries_screen.dart';
import 'package:travel_journal/providers/entries_view_model.dart';
import 'package:travel_journal/screens/home_screen.dart';
import 'package:travel_journal/providers/home_view_model.dart';
import 'package:travel_journal/providers/settings_view_model.dart';
import 'package:travel_journal/screens/setting_screen.dart';

final _db = AppDatabase();

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<AppDatabase>(create: (_) => _db),
        ChangeNotifierProvider(create: (_) => HomeViewModel(_db)..init()),
        ChangeNotifierProvider(create: (_) => EntriesViewModel(_db)),
        ChangeNotifierProvider(create: (_) => SettingsViewModel(_db)),
      ],
      child: Consumer<SettingsViewModel>(
        builder: (context, settings, _) => MaterialApp(
          debugShowCheckedModeBanner: false,
          themeMode: settings.themeMode,
          theme: ThemeData.light(useMaterial3: true),
          darkTheme: ThemeData.dark(useMaterial3: true),
          initialRoute: '/home',
          routes: {
            '/home': (context) => const HomeScreen(),
            '/entries': (context) => const EntriesScreen(),
            '/settings': (context) => const SettingScreen(),
          },
        ),
      ),
    );
  }
}
