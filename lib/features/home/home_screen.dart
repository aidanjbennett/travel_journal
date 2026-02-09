import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: Text("Hello")),
        body: SafeArea(
          child: Center(
            child: Column(
              children: [Text("Travel Journal"), Text("By Aidan Bennett")],
            ),
          ),
        ),
      ),
    );
  }
}
