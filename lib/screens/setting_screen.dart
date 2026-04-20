import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:travel_journal/widgets/main_navbar_widget.dart';
import 'package:travel_journal/widgets/main_title_widget.dart';
import 'package:travel_journal/widgets/setting_section_header_widget.dart';

class SettingScreen extends StatelessWidget {
  const SettingScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
              trailing: Switch(
                value: Theme.of(context).brightness == Brightness.dark,
                onChanged: (bool value) {
                  // TODO: Implement theme switching logic
                  if (kDebugMode) {
                    print("toggled");
                  }
                },
              ),
            ),

            SettingSectionHeaderWidget(title: "Journal Data"),
            ListTile(
              leading: const Icon(Icons.backup_outlined),
              title: const Text('Export Journal (Backup)'),
              subtitle: const Text('Save your entries to a local file'),
              onTap: () {
                // TODO: Logic to generate a JSON/PDF backup
                if (kDebugMode) {
                  print("tapped export data");
                }
              },
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
              onTap: () => {
                if (kDebugMode) {print("tapped clear all data")},
              },
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
