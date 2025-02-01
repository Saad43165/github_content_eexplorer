// lib/main.dart
import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';

void main() {
  runApp(GitHubExplorerApp());
}

class GitHubExplorerApp extends StatefulWidget {
  @override
  _GitHubExplorerAppState createState() => _GitHubExplorerAppState();
}

class _GitHubExplorerAppState extends State<GitHubExplorerApp> {
  bool _isDarkMode = false;

  void _toggleTheme() {
    setState(() {
      _isDarkMode = !_isDarkMode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GitHub Explorer',
      debugShowCheckedModeBanner: false,
      theme: _isDarkMode
          ? ThemeData.dark().copyWith(
        primaryColor: Colors.indigo,
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.indigo,
        ),
      )
          : ThemeData(
        primarySwatch: Colors.indigo,
        scaffoldBackgroundColor: Colors.grey[100],
        appBarTheme: AppBarTheme(
          elevation: 0,
          backgroundColor: Colors.indigo,
        ),
      ),
      home: SplashScreen(toggleTheme: _toggleTheme),
    );
  }
}
