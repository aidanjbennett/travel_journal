import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:travel_journal/widgets/entries/empty_state_widget.dart';
import 'package:travel_journal/model/entries_view_model.dart';
import 'package:travel_journal/shared/models/journal_entry_model.dart';
import 'package:travel_journal/shared/widgets/main_navbar_widget.dart';
import 'package:travel_journal/shared/widgets/main_title_widget.dart';
import 'package:travel_journal/widgets/entries/swipe_to_delete_card_widget.dart';

class EntriesScreen extends StatelessWidget {
  const EntriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.read<EntriesViewModel>();

    return Scaffold(
      appBar: AppBar(title: const MainTitleWidget()),
      bottomNavigationBar: const MainNavbar(currentIndex: 1),
      body: SafeArea(
        child: StreamBuilder<List<JournalEntryModel>>(
          stream: vm.entriesStream,
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
