import 'dart:io';

import 'package:flutter/material.dart';
import 'package:idea_cache/app.dart';
import 'package:idea_cache/notificationhandler.dart';
import 'package:window_manager/window_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ICNotificationHandler.initReminders();
  await ICNotificationHandler.initNotification();
  if (Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
    await windowManager.ensureInitialized();
    await windowManager.setMinimumSize(const Size(420, 560));
  }

  runApp(const ICApp());
}
