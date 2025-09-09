import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:testapi/ui/update.dart';
import 'MapLauncherExample.dart'; // Correct import

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://idximjrqcfioksobtulx.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImlkeGltanJxY2Zpb2tzb2J0dWx4Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTczNDExMjYsImV4cCI6MjA3MjkxNzEyNn0.015VvfNFMhUBbQgrkI_7QrDpTkpN9WHakVca7j7uFJU'
  );

  print('Supabase initialized!');

  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MapLauncherExample(),
      //home:SetRoutePage(),
    );
  }
}
