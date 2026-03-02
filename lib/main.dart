import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:travel_journal/features/entries/entries_screen.dart';
import 'package:travel_journal/features/home/home_screen.dart';
import 'package:travel_journal/providers/journal_provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => JournalStore(),
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
