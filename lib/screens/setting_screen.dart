import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:travel_journal/providers/settings_view_model.dart';
import 'package:travel_journal/widgets/main_navbar_widget.dart';
import 'package:travel_journal/widgets/main_title_widget.dart';
import 'package:travel_journal/widgets/setting_section_header_widget.dart';

class SettingScreen extends StatelessWidget {
  const SettingScreen({super.key});

  Future<void> _confirmClearData(
    BuildContext context,
    SettingsViewModel vm,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Clear All Data'),
        content: const Text(
          'This will permanently delete all journal entries. This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.redAccent),
            child: const Text('Clear'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await vm.clearAllData();
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('All data cleared.')));
      }
    }
  }

  Future<void> _exportJournal(
    BuildContext context,
    SettingsViewModel vm,
  ) async {
    await vm.exportJournal();
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Journal exported successfully.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<SettingsViewModel>();

    return Scaffold(
      appBar: AppBar(title: const MainTitleWidget()),
      bottomNavigationBar: const MainNavbar(currentIndex: 2),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: 10),
          children: [
            SettingSectionHeaderWidget(title: 'Appearance'),
            ListTile(
              leading: const Icon(Icons.dark_mode_outlined),
              title: const Text('Dark Mode'),
              trailing: Switch(value: vm.isDarkMode, onChanged: vm.toggleTheme),
            ),
            SettingSectionHeaderWidget(title: 'Journal Data'),
            ListTile(
              leading: const Icon(Icons.backup_outlined),
              title: const Text('Export Journal (Backup)'),
              subtitle: const Text('Save your entries to a local file'),
              onTap: () => _exportJournal(context, vm),
            ),
            ListTile(
              leading: const Icon(
                Icons.delete_sweep_outlined,
                color: Colors.redAccent,
              ),
              title: const Text(
                'Clear All Data',
                style: TextStyle(color: Colors.redAccent),
              ),
              onTap: () => _confirmClearData(context, vm),
            ),
            SettingSectionHeaderWidget(title: 'About'),
            const ListTile(
              leading: Icon(Icons.info_outline),
              title: Text('App Version'),
              trailing: Text('1.0.0'),
            ),
          ],
        ),
      ),
    );
  }
}
