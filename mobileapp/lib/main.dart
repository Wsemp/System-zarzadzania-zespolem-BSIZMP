import 'package:flutter/material.dart';
import 'screens/login_screen.dart';

void main() {
  runApp(const TaskManagerApp());
}

class TaskManagerApp extends StatelessWidget {
  const TaskManagerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Task Manager',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: const Color(0xFFF4F6FB),
        fontFamily: 'Roboto',
      ),
      // Aplikacja od razu kieruje na zewnetrzny ekran logowania
      home: const LoginScreen(),
    );
  }
}
