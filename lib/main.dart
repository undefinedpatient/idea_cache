import 'package:flutter/material.dart';
import 'package:idea_cache/app.dart';
import 'package:window_manager/window_manager.dart';
import 'package:window_manager/window_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();
  await windowManager.setMinimumSize(const Size(720, 420));

  runApp(const ICApp());
}
