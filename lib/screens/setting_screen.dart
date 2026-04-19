import 'package:flutter/material.dart';
import 'package:travel_journal/widgets/main_navbar_widget.dart';
import 'package:travel_journal/widgets/main_title_widget.dart';

class SettingScreen extends StatelessWidget {
  const SettingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const MainTitleWidget()),
      bottomNavigationBar: MainNavbar(currentIndex: 2),
      body: SafeArea(child: Column(children: [Text("Settings")])),
    );
  }
}
