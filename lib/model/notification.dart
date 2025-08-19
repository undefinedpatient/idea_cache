import 'dart:math';

import 'package:uuid/uuid.dart';

enum notificationStatus { SCHEDULED, TRIGGERED, DISMISSED }

class ICNotification {
  final String _id;
  final int scheduleId;
  String cacheId;
  String blockId;
  notificationStatus status;
  String name;
  String description;
  DateTime dateTime;

  ICNotification({
    this.cacheId = "",
    this.blockId = "",
    this.status = notificationStatus.SCHEDULED,
    this.name = "Untitled",
    this.description = "",
    required this.dateTime,
  }) : _id = Uuid().v4(),
       scheduleId = Random().nextInt(9999999);

  String get id => _id;
  // Convert to Map for DB
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'scheduleId': scheduleId,
      'cacheId': cacheId,
      'blockId': blockId,
      'status': status.index,
      'name': name,
      'description': description,
      'dateTime': dateTime.toString(),
    };
  }

  ICNotification.fromMap(Map<String, dynamic> map)
    : _id = map['id'],
      scheduleId = map['scheduleId'] ?? 0,
      cacheId = map["cacheId"] ?? "",
      blockId = map['blockId'] ?? "",
      status = notificationStatus.values[map['status']],
      name = map['name'] ?? "",
      description = map['description'] ?? "",
      dateTime = DateTime.parse(map['dateTime']);
  String toString() {
    return toMap().toString();
  }
}
