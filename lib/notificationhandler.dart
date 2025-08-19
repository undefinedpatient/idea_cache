import 'dart:async';
import 'dart:math';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:idea_cache/model/filehandler.dart';
import 'package:idea_cache/model/reminder.dart';
import 'package:idea_cache/model/remindermodel.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/timezone.dart';

class NotificationHandler {
  // static const WindowsInitializationSettings initializationSettingsWindows =
  //     WindowsInitializationSettings(
  //       appName: 'IdeaCache',
  //       appUserModelId: 'Com.Patient.IdeaCache',
  //       guid: '9d8409f2-8955-483b-83b3-b5d982db52f5',
  //     );
  // // static const AndroidInitializationSettings androidSettings =
  // //     AndroidInitializationSettings('@mipmap/ic_launcher');
  // static final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  //     FlutterLocalNotificationsPlugin();

  // static Future<void> init() async {
  //   // Initialize notification plugin
  //   const InitializationSettings initSettings = InitializationSettings(
  //     // android: androidSettings,
  //     windows: initializationSettingsWindows,
  //   );

  //   await flutterLocalNotificationsPlugin.initialize(
  //     initSettings,
  //     onDidReceiveNotificationResponse: (payload) {},
  //   );
  //   String timezoneLocation = await FlutterTimezone.getLocalTimezone();
  //   tz.initializeTimeZones();
  //   tz.setLocalLocation(tz.getLocation(timezoneLocation));
  // }

  // // Debug/Developement Purpose
  // static Future<void> sendSampleNotification() async {
  //   WindowsNotificationDetails windowsNotificationDetails =
  //       WindowsNotificationDetails(
  //         actions: [WindowsAction(content: "Action", arguments: "arguments")],
  //       );
  //   NotificationDetails details = NotificationDetails(
  //     windows: windowsNotificationDetails,
  //   );
  //   NotificationHandler.flutterLocalNotificationsPlugin.show(
  //     0,
  //     "Sample Notification",
  //     "You Get it!",
  //     details,
  //   );
  // }

  // static Future<void> scheduleLocalNotification(
  //   ICReminder notification, {
  //   required Function() callBack,
  // }) async {
  //   Duration secondCountDown = notification.dateTime.difference(DateTime.now());
  //   Timer(secondCountDown, () async {
  //     ICReminder? instantNotification = await FileHandler.findNotificationById(
  //       notification.id,
  //     );
  //     // If the notification scheduled is deleted
  //     if (instantNotification == null) {
  //       return;
  //     }
  //     // If the notification time was updated
  //     if (instantNotification.dateTime.compareTo(notification.dateTime) != 0) {
  //       return;
  //     }
  //     callBack();
  //   });
  // }

  // static Future<void> cancelNotification(ICReminder notification) async {
  //   await flutterLocalNotificationsPlugin.cancel(notification.scheduleId);
  // }

  // static Future<void> scheduleNotification(ICReminder notification) async {
  //   AndroidScheduleMode androidScheduleMode = AndroidScheduleMode.exact;
  //   DateTime time = notification.dateTime;
  //   WindowsNotificationDetails windowsNotificationDetails =
  //       WindowsNotificationDetails();
  //   NotificationDetails notificationDetails = NotificationDetails(
  //     windows: windowsNotificationDetails,
  //   );

  //   flutterLocalNotificationsPlugin.zonedSchedule(
  //     notification.scheduleId,
  //     notification.name,
  //     notification.description,
  //     tz.TZDateTime.utc(
  //       time.year,
  //       time.month,
  //       time.day,
  //       time.hour,
  //       time.minute,
  //     ),
  //     notificationDetails,
  //     androidScheduleMode: androidScheduleMode,
  //   );
  // }
}
