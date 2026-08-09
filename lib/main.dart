import 'package:flutter/material.dart';
import 'package:tahsilat_mobile/features/auth/pages/login_page.dart';

void main() {
  runApp(const YigitAkuApp());
}

class YigitAkuApp extends StatelessWidget {
  const YigitAkuApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Yiğit Akü',
      theme: ThemeData(
        colorSchemeSeed: const Color(0xFFE31E24),
        useMaterial3: true,
        fontFamily: 'Segoe UI',
      ),
      home: const LoginPage(),
    );
  }
}