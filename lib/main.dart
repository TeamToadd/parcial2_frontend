import 'package:flutter/material.dart';
import 'screens/login_screen.dart';

void main() {
  runApp(const Parcial2App());
}

class Parcial2App extends StatelessWidget {
  const Parcial2App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Parcial2',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      home: const LoginScreen(),
    );
  }
}
