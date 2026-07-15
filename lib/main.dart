import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gym_coach/app.dart';
import 'package:gym_coach/data/datasources/local_database.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await LocalDatabase.instance.open();
  runApp(
    const ProviderScope(
      child: GymCoachApp(),
    ),
  );
}
