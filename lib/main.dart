import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:travel_journal/database/app_database.dart';
import 'package:travel_journal/screens/entries_screen.dart';
import 'package:travel_journal/model/entries_view_model.dart';
import 'package:travel_journal/screens/home_screen.dart';
import 'package:travel_journal/model/home_view_model.dart';
import 'package:travel_journal/providers/journal_provider.dart';
import 'package:travel_journal/screens/setting_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => JournalStore(AppDatabase())),
        ChangeNotifierProvider(
          create: (context) =>
              HomeViewModel(context.read<JournalStore>())..init(),
        ),
        ChangeNotifierProvider(
          create: (context) => EntriesViewModel(context.read<JournalStore>()),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        initialRoute: '/home',
        routes: {
          '/home': (context) => const HomeScreen(),
          '/entries': (context) => const EntriesScreen(),
          '/settings': (context) => const SettingScreen(),
        },
      ),
    );
  }
}
