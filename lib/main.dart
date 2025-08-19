import 'dart:io';

import 'package:flutter/material.dart';
import 'package:idea_cache/app.dart';
import 'package:idea_cache/model/dbhandler.dart';
import 'package:window_manager/window_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
    await windowManager.ensureInitialized();
    await windowManager.setMinimumSize(const Size(420, 560));
  }
  await DataBaseHandler.initDB();
  runApp(const ICApp());
}
