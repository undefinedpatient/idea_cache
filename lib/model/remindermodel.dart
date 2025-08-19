import 'dart:collection';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:idea_cache/model/filehandler.dart';
import 'package:idea_cache/model/reminder.dart';

class ICReminderModel extends ChangeNotifier {
  final List<ICReminder> _reminders = [];
  UnmodifiableListView<ICReminder> get reminders =>
      UnmodifiableListView(_reminders);
  bool _isLoading = false;
  bool get isLoading => _isLoading;
  Future<void> loadFromFile() async {
    _isLoading = true;
    notifyListeners();
    _reminders.clear();
    _reminders.addAll(await FileHandler.readReminder());
    _reminders.forEach((item) => log(item.name));
    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadFromFileSlient() async {
    _reminders.clear();
    _reminders.addAll(await FileHandler.readReminder());
  }

  Future<void> appendReminder(ICReminder reminder) async {
    FileHandler.appendReminder(reminder);
    _reminders.add(reminder);
    notifyListeners();
  }

  Future<void> updateReminder(ICReminder reminder) async {
    FileHandler.updateReminder(reminder);
    int updateTargetIndex = _reminders.indexWhere(
      (item) => item.id == reminder.id,
    );
    if (updateTargetIndex < 0) {
      throw Exception("Cannot find Notification to Update!");
    }
    _reminders[updateTargetIndex] = reminder;
    notifyListeners();
  }

  Future<void> deleteReminderById(String id) async {
    FileHandler.deleteReminderById(id);
    _reminders.removeWhere((item) => item.id == id);
    notifyListeners();
  }

  Future<void> updateStatusAll() async {
    await Future.forEach(_reminders, updateStatus);
    notifyListeners();
  }

  Future<void> updateStatus(ICReminder reminder) async {
    // if (DateTime.now().isBefore(reminder.time) &&
    //     reminder.status == reminderStatus.SCHEDULED) {
    //   reminder.status = reminderStatus.TRIGGERED;
    //   await FileHandler.updateNotification(reminder);
    // }
  }
}
