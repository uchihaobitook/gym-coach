import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gym_coach/app.dart';
import 'package:gym_coach/data/datasources/local_database.dart';
import 'package:gym_coach/data/repositories/profile_repository.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await LocalDatabase.instance.open();
  await ProfileRepository().migrateIfNeeded();
  runApp(
    const ProviderScope(
      child: GymCoachApp(),
    ),
  );
}
