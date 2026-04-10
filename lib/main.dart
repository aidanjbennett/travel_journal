import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:travel_journal/database/app_database.dart';
import 'package:travel_journal/features/entries/entries_screen.dart';
import 'package:travel_journal/screens/home_screen.dart';
import 'package:travel_journal/model/home_view_model.dart';
import 'package:travel_journal/providers/journal_provider.dart';

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
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        initialRoute: '/home',
        routes: {
          '/home': (context) => const HomeScreen(),
          '/entries': (context) => const EntriesScreen(),
        },
      ),
    );
  }
}
