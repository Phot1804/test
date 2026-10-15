import 'package:flutter/material.dart';
import 'screens/home/home_screen.dart';

void main() {
  // บังคับเตรียมการ Binding ก่อนรันแอปพลิเคชัน
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // ซ่อนป้าย DEBUG
      title: 'Expense Tracker',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      home: const HomeScreen(), // กำหนดให้เปิด HomeScreen เป็นหน้าแรก
    );
  }
}