import 'package:flutter/material.dart';

class SettingsButtonWidget extends StatelessWidget {
  const SettingsButtonWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () => Navigator.pushReplacementNamed(context, '/settings'),
      icon: const Icon(Icons.settings),
    );
  }
}
