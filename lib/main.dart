import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:idea_cache/app.dart';
import 'package:idea_cache/model/dbhandler.dart';
import 'package:idea_cache/notificationhandler.dart';
import 'package:window_manager/window_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
    await windowManager.ensureInitialized();
    await windowManager.setMinimumSize(const Size(420, 560));
  }
  // await NotificationHandler.init();
  runApp(const ICApp());
}
