import 'dart:collection';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:idea_cache/model/filehandler.dart';
import 'package:idea_cache/model/notification.dart';

class ICNotificationModel extends ChangeNotifier {
  final List<ICNotification> _notifications = [];
  UnmodifiableListView<ICNotification> get notifications =>
      UnmodifiableListView(_notifications);
  bool _isLoading = false;
  bool get isLoading => _isLoading;
  Future<void> loadFromFile() async {
    _isLoading = true;
    notifyListeners();
    _notifications.clear();
    _notifications.addAll(await FileHandler.readNotifications());
    _notifications.forEach((item) => log(item.name));
    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadFromFileSlient() async {
    _notifications.clear();
    _notifications.addAll(await FileHandler.readNotifications());
  }

  Future<void> appendNotification(ICNotification notification) async {
    FileHandler.appendNotification(notification);
    _notifications.add(notification);
    notifyListeners();
  }

  Future<void> updateNotification(ICNotification notification) async {
    FileHandler.updateNotification(notification);
    int updateTargetIndex = _notifications.indexWhere(
      (item) => item.id == notification.id,
    );
    if (updateTargetIndex < 0) {
      throw Exception("Cannot find Notification to Update!");
    }
    _notifications[updateTargetIndex] = notification;
    notifyListeners();
  }

  Future<void> deleteNotificationById(String id) async {
    FileHandler.deleteNotificationById(id);
    _notifications.removeWhere((item) => item.id == id);
    notifyListeners();
  }

  Future<void> updateStatusAll() async {
    await Future.forEach(_notifications, updateStatus);
    notifyListeners();
  }

  Future<void> updateStatus(ICNotification notification) async {
    if (DateTime.now().isBefore(notification.dateTime) &&
        notification.status == notificationStatus.SCHEDULED) {
      notification.status = notificationStatus.TRIGGERED;
      await FileHandler.updateNotification(notification);
    }
  }
}
