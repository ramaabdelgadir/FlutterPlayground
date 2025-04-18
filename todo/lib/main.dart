import 'package:flutter/material.dart';
import 'package:to_do/themes/app_colors.dart';
import 'package:to_do/pages/home_page_view.dart';
import 'package:hive_flutter/hive_flutter.dart';

void main() async {
  await Hive.initFlutter("hive_boxes");
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TODO',
      theme: ThemeData(primaryColor: AppColors.mainColor),
      home: const HomePage(),
    );
  }
}
