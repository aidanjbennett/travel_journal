import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:travel_journal/features/entries/empty_state_widget.dart';
import 'package:travel_journal/features/entries/entry_card_widget.dart';
import 'package:travel_journal/providers/journal_provider.dart';
import 'package:travel_journal/shared/widgets/main_navbar_widget.dart';
import 'package:travel_journal/shared/widgets/main_title_widget.dart';

class EntriesScreen extends StatelessWidget {
  const EntriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final entries = context.watch<JournalStore>().entries;

    return Scaffold(
      appBar: AppBar(title: const MainTitleWidget()),
      bottomNavigationBar: const MainNavbar(currentIndex: 1),
      body: SafeArea(
        child: entries.isEmpty
            ? const EmptyStateWidget()
            : ListView.separated(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                itemCount: entries.length,
                separatorBuilder: (_, _) => const SizedBox(height: 12),
                itemBuilder: (context, index) =>
                    EntryCardWidget(entry: entries[index]),
              ),
      ),
    );
  }
}
