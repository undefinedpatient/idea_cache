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
    _reminders.addAll(await FileHandler.readReminders());
    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadFromFileSlient() async {
    _reminders.clear();
    _reminders.addAll(await FileHandler.readReminders());
  }

  Future<void> appendReminder(ICReminder reminder) async {
    await FileHandler.appendReminder(reminder);
    _reminders.add(reminder);
    notifyListeners();
  }

  Future<void> updateReminder(ICReminder reminder) async {
    await FileHandler.updateReminder(reminder);
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

  Future<void> reorderReminder(int from, int to) async {
    log("From $from, to $to");
    FileHandler.reorderNotification(from, to);
    if (from < to) {
      to--;
    }
    _reminders.insert(to, _reminders.removeAt(from));
    notifyListeners();
  }
}
