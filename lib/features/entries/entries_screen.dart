import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:travel_journal/features/entries/widgets/empty_state_widget.dart';
import 'package:travel_journal/providers/journal_provider.dart';
import 'package:travel_journal/shared/models/journal_entry_model.dart';
import 'package:travel_journal/shared/widgets/main_navbar_widget.dart';
import 'package:travel_journal/shared/widgets/main_title_widget.dart';
import 'package:travel_journal/features/entries/widgets/swipe_to_delete_card_widget.dart';

class EntriesScreen extends StatelessWidget {
  const EntriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final store = context.read<JournalStore>();

    return Scaffold(
      appBar: AppBar(title: const MainTitleWidget()),
      bottomNavigationBar: const MainNavbar(currentIndex: 1),
      body: SafeArea(
        child: StreamBuilder<List<JournalEntryModel>>(
          stream: store.watchEntries(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final entries = snapshot.data ?? [];

            if (entries.isEmpty) return const EmptyStateWidget();

            return ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              itemCount: entries.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, index) => SwipeToDeleteCardWidget(
                // Key on entryId ensures Flutter rebuilds correctly
                // when an item is removed from the middle of the list.
                key: ValueKey(entries[index].entryId),
                entry: entries[index],
              ),
            );
          },
        ),
      ),
    );
  }
}
