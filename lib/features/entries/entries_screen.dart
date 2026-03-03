import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:travel_journal/features/entries/widgets/empty_state_widget.dart';
import 'package:travel_journal/providers/journal_provider.dart';
import 'package:travel_journal/shared/widgets/main_navbar_widget.dart';
import 'package:travel_journal/shared/widgets/main_title_widget.dart';
import 'package:travel_journal/features/entries/widgets/swipe_to_delete_card.dart';

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
                itemBuilder: (context, index) => SwipeToDeleteCardWidget(
                  // Key on entryId ensures Flutter rebuilds correctly
                  // when an item is removed from the middle of the list.
                  key: ValueKey(entries[index].entryId),
                  entry: entries[index],
                ),
              ),
      ),
    );
  }
}
