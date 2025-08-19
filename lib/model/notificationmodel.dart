import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:idea_cache/model/dbhandler.dart';
import 'package:idea_cache/model/notification.dart';

class ICNotificationModel extends ChangeNotifier {
  final List<ICNotification> _notifications = [];
  UnmodifiableListView<ICNotification> get notifications =>
      UnmodifiableListView(_notifications);
  bool _isLoading = false;
  bool get isLoading => _isLoading;
  Future<void> loadFromDB() async {
    _isLoading = true;
    notifyListeners();
    _notifications.clear();
    _notifications.addAll(await DataBaseHandler().getNotifications());
    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadFromDBSlient() async {
    _notifications.clear();
    _notifications.addAll(await DataBaseHandler().getNotifications());
  }
}
