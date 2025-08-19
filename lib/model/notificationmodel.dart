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

  Future<void> deleteNotificationById(String id) async {
    FileHandler.deleteNotificationById(id);
    _notifications.removeWhere((item) => item.id == id);
    notifyListeners();
  }
}
