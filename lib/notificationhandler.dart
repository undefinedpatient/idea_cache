import 'dart:async';
import 'dart:developer' as dev;
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:idea_cache/model/filehandler.dart';
import 'package:idea_cache/model/reminder.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class ICNotificationHandler extends ChangeNotifier {
  static final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  static AndroidNotificationChannel channel = const AndroidNotificationChannel(
    'idea_cache',
    'idea_cache_reminder',
    description: 'This channel is used for Reminder notifications.',
    importance: Importance.high,
    playSound: true,
  );
  static const WindowsInitializationSettings initializationSettingsWindows =
      WindowsInitializationSettings(
        appName: 'IdeaCache',
        appUserModelId: 'Com.Patient.IdeaCache',
        guid: '9d8409f2-8955-483b-83b3-b5d982db52f5',
      );
  static const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');
  // This is for InApp popupdialog notification
  static final List<ICReminder> _popupDialogList = [];
  static Map<reminderStatus, List<ICReminder>> reminderMap = {
    reminderStatus.DISMISSED: [],
    reminderStatus.NOTACTIVE: [],
    reminderStatus.SCHEDULED: [],
    reminderStatus.TRIGGERED: [],
  };

  static Timer? timer;
  static Timer? timer2;
  List<ICReminder> get popupDialogList => _popupDialogList;
  static ICReminder? get oldestTriggeredReminder {
    return reminderMap[reminderStatus.TRIGGERED]!.lastOrNull;
  }

  static ICReminder? get upcomingReminder {
    return reminderMap[reminderStatus.SCHEDULED]!.firstOrNull;
  }

  // Load all the reminders data as local data, and assign them with different role
  static Future<void> loadRemindersFromFile() async {
    List<ICReminder> reminders = await FileHandler.readReminders();
    for (int i = 0; i < reminders.length; i++) {
      // If the reminders should be in Triggered Status
      if (reminders[i].status == reminderStatus.SCHEDULED &&
          reminders[i].time.isBefore(DateTime.now())) {
        reminders[i].status = reminderStatus.TRIGGERED;
        reminderMap[reminderStatus.TRIGGERED]!.add(reminders[i]);
        await FileHandler.updateReminder(reminders[i]);

        continue;
      }
      if (reminders[i].status == reminderStatus.TRIGGERED) {
        reminderMap[reminderStatus.TRIGGERED]!.add(reminders[i]);
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
    /*
      It is required to sort the reminders if they are not appended in order
      doing so can ensure the check() check the correct reminder
    */
    _sortReminders();
  }

  // Execute the checking per second, use checkInAppNotification as callback
  void initInAppCheckLoop() {
    timer = Timer.periodic(
      Duration(milliseconds: 1000),
      checkInAppNotification,
    );
  }

  // It is executed per second throughout the lifetime, only compute the latest upcoming reminder
  void checkInAppNotification(Timer timer) async {
    // _printInfo();
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
      await FileHandler.updateReminder(checkedReminder);

      reminderMap.forEach((status, reminders) {
        reminders.removeWhere(
          (item) => checkedReminder.scheduleId == item.scheduleId,
        );
      });
      reminderMap[checkedReminder.status]!.add(checkedReminder);

      reminderMap = _sortReminders();
      _popupDialogList.add(checkedReminder);
      reminderMap = _sortReminders();
      notifyListeners();
      return;
    }
  }

  static Future<void> initNotification() async {
    
    // Initialize notification plugin
    const InitializationSettings initSettings = InitializationSettings(
      // android: androidSettings,
      windows: initializationSettingsWindows,
      android: initializationSettingsAndroid,
    );
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.requestNotificationsPermission();
    await flutterLocalNotificationsPlugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (payload) {},
    );
    // Set the local location such that the notification pop up at the right timezone
    String timezoneLocation = await FlutterTimezone.getLocalTimezone();
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation(timezoneLocation));
  }

  static Future<void> loadAllScheduleNotifications() async {
    await flutterLocalNotificationsPlugin.cancelAll();
    NotificationDetails details = NotificationDetails(
      windows: WindowsNotificationDetails(),
      android: AndroidNotificationDetails(
        channel.id,
        channel.name,
        channelDescription: channel.description,
        importance: Importance.high,
        color: const Color.fromARGB(255, 255, 255, 0),
        playSound: true,
        icon: '@mipmap/ic_launcher',
      ),
    );
    for (int i = 0; i < reminderMap[reminderStatus.SCHEDULED]!.length; i++) {
      await flutterLocalNotificationsPlugin.zonedSchedule(
        reminderMap[reminderStatus.SCHEDULED]![i].scheduleId,
        "ICReminder",
        reminderMap[reminderStatus.SCHEDULED]![i].name,
        tz.TZDateTime.from(
          reminderMap[reminderStatus.SCHEDULED]![i].time,
          tz.local,
        ),
        details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      );
    }
  }

  static Future<void> _scheduleNotification(ICReminder reminder) async {
    NotificationDetails details = NotificationDetails(
      windows: WindowsNotificationDetails(),
      android: AndroidNotificationDetails(
        channel.id,
        channel.name,
        channelDescription: channel.description,
        importance: Importance.high,
        color: const Color.fromARGB(255, 255, 255, 0),
        playSound: true,
        icon: '@mipmap/ic_launcher',
      ),
    );
    tz.TZDateTime tzDateTime;
    tzDateTime = tz.TZDateTime.from(reminder.time, tz.local);
    dev.log(tzDateTime.toString());
    // }
    await flutterLocalNotificationsPlugin.zonedSchedule(
      reminder.scheduleId,
      "ICReminder",
      reminder.name,
      tzDateTime,
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

  static Future<void> _removeNotification(ICReminder reminder) async {
    await flutterLocalNotificationsPlugin.cancel(reminder.scheduleId);
  }

  void clearQueue() {
    reminderMap.clear();
    notifyListeners();
  }

  void alarmCallBack(ICReminder reminder) {
    _popupDialogList.clear();
  }

  // Update/Add new formed Reminder
  Future<void> updateReminder(ICReminder reminder) async {
    dev.log("Reminder ${reminder.name} updated");
    reminderMap.forEach((status, reminders) {
      reminders.removeWhere((item) => reminder.scheduleId == item.scheduleId);
    });
    // There is one case when the reminder is already passed, changing from mute to schedule should not be possible
    if (reminder.time.isBefore(DateTime.now())) {
      reminder.status = reminderStatus.DISMISSED;
    }
    reminderMap[reminder.status]!.add(reminder);
    reminderMap = _sortReminders();
    //Attempt to remove existing regardless whether it is in the list
    await _removeNotification(reminder);
    if (reminder.status == reminderStatus.SCHEDULED) {
      await _scheduleNotification(reminder);
    }

    notifyListeners();
  }

  // Remove the target reminder
  Future<void> removeReminder(ICReminder reminder) async {
    dev.log("Reminder ${reminder.name} removed");
    reminderMap.forEach((status, reminders) {
      reminders.removeWhere((item) => reminder.scheduleId == item.scheduleId);
    });
    _popupDialogList.removeWhere((item) => item.id == reminder.id);
    await _removeNotification(reminder);
    notifyListeners();
  }

  // Debug Function
  void _printInfo() async {
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
    for (ICReminder value in popupDialogList) {
      alarmsInfo += "{${value.name}} ";
    }
    String upcomingMessage = (upcomingReminder != null)
        ? upcomingReminder!.name
        : "";
    dev.log(
      "$timerInfo\n NOT ACTIVE:$notActiveInfo\n SCHEDULED: $scheduleInfo\n TRIGGERED: $triggeredInfo\n DISMISSED:$dismissedInfo\n Upcoming:$upcomingMessage\n AlarmsInfo:$alarmsInfo",
    );
    String notificationInfo = "";
    List<PendingNotificationRequest> notifications =
        await flutterLocalNotificationsPlugin.pendingNotificationRequests();
    for (PendingNotificationRequest request in notifications) {
      notificationInfo += "{${request.id} ${request.body}}";
    }

    dev.log(notificationInfo);
  }

  static Map<reminderStatus, List<ICReminder>> _sortReminders() {
    Map<reminderStatus, List<ICReminder>> temp = reminderMap;
    temp.forEach((status, reminders) {
      for (int i = 0; i < reminders.length; i++) {
        for (int j = i + 1; j < reminders.length; j++) {
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
}
