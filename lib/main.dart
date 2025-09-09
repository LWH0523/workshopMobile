import 'package:flutter/material.dart';
import 'MapLauncherExample.dart'; // Correct import

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MapLauncherExample(),
    );
  }
}
