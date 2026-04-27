import 'package:flutter/material.dart';
import 'package:gestao_escolar_app/screens/login_screen.dart';
import 'package:gestao_escolar_app/theme/app_theme.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SIGA - Gestão Escolar',
      theme: AppTheme.theme,
      debugShowCheckedModeBanner: false,
      home: LoginScreen(),
    );
  }
}
