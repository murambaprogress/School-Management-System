import 'package:flutter/material.dart';

import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive
  await Hive.initFlutter();

  // Initialize date formatting
  await initializeDateFormatting();

  // Open the financial box and handle potential errors
  try {
    await Hive.openBox('financial_box');
  } catch (e) {
    print("Error opening financial_box: $e");
  }

  // Open the asset box and handle potential errors
  try {
    await Hive.openBox('asset_box');
  } catch (e) {
    print("Error opening asset_box: $e");
  }

  // Open the financial position box and handle potential errors
  try {
    await Hive.openBox('financial_position_box');
  } catch (e) {
    print("Error opening financial_position_box: $e");
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'School Financial Management',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: const HomePage(),
    );
  }
}