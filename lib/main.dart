import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:idea_cache/app.dart';
import 'package:idea_cache/notificationhandler.dart';
import 'package:idea_cache/userpreferences.dart';
import 'package:window_manager/window_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ICNotificationHandler.loadRemindersFromFile();
  await ICNotificationHandler.initNotification();
  await ICNotificationHandler.loadAllScheduleNotifications();
  await ICUserPreferences().loadPreferences();
  if (Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
    await windowManager.ensureInitialized();
    await windowManager.setMinimumSize(const Size(420, 420));
    windowManager.setAlwaysOnTop(ICUserPreferences().windowPinValue);
  } else {
    AndroidFlutterLocalNotificationsPlugin().requestExactAlarmsPermission();
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }
  runApp(const ICApp());
}
