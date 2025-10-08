import 'package:dishcovery_app/app.dart';
import 'package:dishcovery_app/core/database/objectbox_database.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:dishcovery_app/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Initialize SharedPreferences
  final preferences = await SharedPreferences.getInstance();

  // Initialize ObjectBox
  final objectbox = await ObjectBoxDatabase.create();

  runApp(App(preferences: preferences, objectBoxDatabase: objectbox));
}
