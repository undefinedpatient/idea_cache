import 'dart:async';
import 'dart:developer' as dev;
import 'package:flutter/widgets.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:idea_cache/model/filehandler.dart';
import 'package:idea_cache/model/reminder.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/timezone.dart';

// local Notification : in app
// Notification : pop up on screen, like message notification
class ICNotificationHandler extends ChangeNotifier {
  static final List<ICReminder> _alarmList = [];
  static Map<reminderStatus, List<ICReminder>> reminderMap = {
    reminderStatus.DISMISSED: [],
    reminderStatus.NOTACTIVE: [],
    reminderStatus.SCHEDULED: [],
    reminderStatus.TRIGGERED: [],
  };
  static Timer? timer;
  List<ICReminder> get alarmList => _alarmList;
  static ICReminder? get oldestTriggeredReminder {
    return reminderMap[reminderStatus.TRIGGERED]!.lastOrNull;
  }

  static ICReminder? get upcomingReminder {
    return reminderMap[reminderStatus.SCHEDULED]!.firstOrNull;
  }

  void clearQueue() {
    reminderMap.clear();
    notifyListeners();
  }

  void wipeTimer(Timer timer) {
    timer.cancel();
  }

  void alarmCallBack(ICReminder reminder) {
    _alarmList.removeWhere((item) => item.scheduleId == reminder.scheduleId);
  }

  static Future<void> initReminders() async {
    List<ICReminder> reminders = await FileHandler.readReminders();
    for (int i = 0; i < reminders.length; i++) {
      // If the reminders should be in Triggered Status
      if (reminders[i].status == reminderStatus.SCHEDULED &&
          reminders[i].time.isBefore(DateTime.now())) {
        reminders[i].status = reminderStatus.TRIGGERED;
        reminderMap[reminderStatus.TRIGGERED]!.add(reminders[i]);
        await FileHandler.updateReminder(reminders[i]);

        _alarmList.add(reminders[i]);
        continue;
      }
      if (reminders[i].status == reminderStatus.TRIGGERED) {
        reminderMap[reminderStatus.TRIGGERED]!.add(reminders[i]);
        _alarmList.add(reminders[i]);
        continue;
      }
      if (reminders[i].status == reminderStatus.SCHEDULED) {
        reminderMap[reminderStatus.SCHEDULED]!.add(reminders[i]);
        continue;
      }

      if (reminders[i].status == reminderStatus.NOTACTIVE) {
        reminderMap[reminderStatus.NOTACTIVE]!.add(reminders[i]);
        continue;
      }
      if (reminders[i].status == reminderStatus.DISMISSED) {
        reminderMap[reminderStatus.DISMISSED]!.add(reminders[i]);
        continue;
      }
    }
  }

  void initLoop() {
    timer = Timer.periodic(Duration(milliseconds: 1000), check);
  }

  void updateReminder(ICReminder reminder) {
    reminderMap.forEach((status, reminders) {
      reminders.removeWhere((item) => reminder.scheduleId == item.scheduleId);
    });
    reminderMap[reminder.status]!.add(reminder);
    reminderMap = _sort();
    notifyListeners();
  }

  void removeReminder(ICReminder reminder) {
    reminderMap.forEach((status, reminders) {
      reminders.removeWhere((item) => reminder.scheduleId == item.scheduleId);
    });
    _alarmList.removeWhere((item) => item.id == reminder.id);
    notifyListeners();
  }

  void printInfo() {
    String timerInfo = timer?.tick.toString() ?? "Timer unavailable";
    String notActiveInfo = "";
    for (ICReminder value in reminderMap[reminderStatus.NOTACTIVE]!) {
      notActiveInfo += "{${value.name}} ";
    }
    String scheduleInfo = "";
    for (ICReminder value in reminderMap[reminderStatus.SCHEDULED]!) {
      scheduleInfo += "{${value.name}} ";
    }
    String triggeredInfo = "";
    for (ICReminder value in reminderMap[reminderStatus.TRIGGERED]!) {
      triggeredInfo += "{${value.name}} ";
    }
    String dismissedInfo = "";
    for (ICReminder value in reminderMap[reminderStatus.DISMISSED]!) {
      dismissedInfo += "{${value.name}} ";
    }
    String alarmsInfo = "";
    for (ICReminder value in alarmList) {
      alarmsInfo += "{${value.name}} ";
    }
    String upcomingMessage = (upcomingReminder != null)
        ? upcomingReminder!.name
        : "";
    dev.log(
      timerInfo +
          "\n NOT ACTIVE:" +
          notActiveInfo +
          "\n SCHEDULED: " +
          scheduleInfo +
          "\n TRIGGERED: " +
          triggeredInfo +
          "\n DISMISSED:" +
          dismissedInfo +
          "\n Upcoming:" +
          upcomingMessage +
          "\n AlarmsInfo" +
          alarmsInfo,
    );
  }

  // Only compute the latest upcoming reminder
  void check(Timer timer) async {
    printInfo();
    ICReminder? checkedReminder = upcomingReminder;
    if (checkedReminder == null) {
      return;
    }
    if (checkedReminder.time.compareTo(DateTime.now()) <= 0 ||
        checkedReminder.time.isAtSameMomentAs(DateTime.now())) {
      reminderMap[reminderStatus.SCHEDULED]!.removeWhere(
        (item) => item.scheduleId == checkedReminder.scheduleId,
      );
      checkedReminder.status = reminderStatus.TRIGGERED;
      FileHandler.updateReminder(checkedReminder);
      updateReminder(checkedReminder);
      _alarmList.add(checkedReminder);
      reminderMap = _sort();
      notifyListeners();
      return;
    }
  }

  static Map<reminderStatus, List<ICReminder>> _sort() {
    Map<reminderStatus, List<ICReminder>> temp = reminderMap;
    temp.forEach((status, reminders) {
      for (int i = 0; i < reminders.length; i++) {
        for (int j = i; j < reminders.length - i; j++) {
          if (reminders[i].time.isAfter(reminders[j].time)) {
            ICReminder temp = reminders[i];
            reminders[i] = reminders[j];
            reminders[j] = temp;
          }
        }
      }
    });
    return temp;
  }

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
