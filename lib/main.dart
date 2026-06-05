import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/match_provider.dart';
import 'screens/home_screen.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() {
  initializeDateFormatting('es');
  runApp(
    ChangeNotifierProvider(
      create: (_) => MatchProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Football Matches',
      debugShowCheckedModeBanner: false,
      home: const HomeScreen(),
    );
  }
}