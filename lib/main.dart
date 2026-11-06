import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_displaymode/flutter_displaymode.dart';

import 'core/providers/settings_provider.dart';
import 'core/providers/history_provider.dart';
import 'core/providers/mastery_provider.dart';
import 'core/services/notification_service.dart';
import 'data/local/settings_repository.dart';
import 'yormath_home.dart';

import 'package:flutter/foundation.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  if (!kIsWeb && Platform.isAndroid) {
    try {
      await FlutterDisplayMode.setHighRefreshRate();
    } catch (e) {
      debugPrint('Failed to set high refresh rate: $e');
    }
  }

  // Initialize notifications
  await NotificationService().init();
  
  final prefs = await SharedPreferences.getInstance();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => SettingsProvider(SettingsRepository()),
        ),
        ChangeNotifierProvider(
          create: (_) => HistoryProvider()..loadHistory(),
        ),
        ChangeNotifierProvider(
          create: (_) => MasteryProvider(prefs),
        ),
      ],
      child: const MathWorkoutApp(),
    ),
  );
}

class MathWorkoutApp extends StatelessWidget {
  const MathWorkoutApp({super.key});

  ThemeData _buildTheme(String themeName) {
    switch (themeName) {
      case 'Dark':
        return ThemeData.dark().copyWith(
          primaryColor: Colors.teal,
          scaffoldBackgroundColor: const Color(0xFF121212),
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.teal,
            brightness: Brightness.dark,
            surface: const Color(0xFF1E1E2E),
          ),
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFF1E1E2E),
            foregroundColor: Colors.white,
            elevation: 0,
            centerTitle: true,
          ),
        );
      case 'Blue':
        return ThemeData(
          brightness: Brightness.light,
          primaryColor: const Color(0xFF1976D2),
          scaffoldBackgroundColor: const Color(0xFFE3F2FD),
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFF1976D2),
            foregroundColor: Colors.white,
            elevation: 0,
            centerTitle: true,
          ),
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1976D2)),
        );
      case 'Purple':
        return ThemeData(
          brightness: Brightness.light,
          primaryColor: Colors.deepPurple,
          scaffoldBackgroundColor: const Color(0xFFEDE7F6),
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.deepPurple,
            foregroundColor: Colors.white,
            elevation: 0,
            centerTitle: true,
          ),
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        );
      case 'Default':
      default:
        return ThemeData(
          brightness: Brightness.light,
          primaryColor: const Color(0xFF1976D2),
          scaffoldBackgroundColor: const Color(0xFFF5F7FA),
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFF1976D2),
            foregroundColor: Colors.white,
            elevation: 0,
            centerTitle: true,
          ),
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1976D2)),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsProvider>(
      builder: (context, settingsProvider, _) {
        if (!settingsProvider.isLoaded) {
          return const MaterialApp(home: Scaffold(body: Center(child: CircularProgressIndicator())));
        }
        
        return MaterialApp(
          title: 'Math Workout',
          theme: _buildTheme(settingsProvider.settings.themeName),
          home: const YormathHome(),
          debugShowCheckedModeBanner: false,
        );
      },
    );
  }
}
