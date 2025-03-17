import 'package:flutter/material.dart';
import 'package:moveit/Pages/home_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MoveIt',
      theme: ThemeData(scaffoldBackgroundColor: Color(0xFF1F1F1F)),
      home: HomePage(),
    );
  }
}
