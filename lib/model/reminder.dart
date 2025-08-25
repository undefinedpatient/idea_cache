import 'dart:math';

import 'package:uuid/uuid.dart';

enum reminderStatus { NOTACTIVE, SCHEDULED, TRIGGERED, DISMISSED }

class ICReminder {
  final String _id;
  final int scheduleId;
  String cacheId;
  String blockId;
  reminderStatus status;
  String name;
  DateTime time;

  ICReminder({
    this.cacheId = "",
    this.blockId = "",
    this.status = reminderStatus.SCHEDULED,
    this.name = "Untitled",
    required this.time,
  }) : _id = Uuid().v4(),
       scheduleId = DateTime.now().millisecondsSinceEpoch;

  String get id => _id;
  int get hours {
    return (time.difference(DateTime.now()).isNegative)
        ? 0
        : time.difference(DateTime.now()).inHours;
  }

  int get minutes {
    return (time.difference(DateTime.now()).isNegative)
        ? 0
        : time.difference(DateTime.now()).inMinutes % 60;
  }

  int get seconds {
    return (time.difference(DateTime.now()).isNegative)
        ? 0
        : time.difference(DateTime.now()).inSeconds % 60;
  }

  // Convert to Map for DB
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'scheduleId': scheduleId,
      'cacheId': cacheId,
      'blockId': blockId,
      'status': status.index,
      'name': name,
      'time': time.toString(),
    };
  }

  ICReminder.fromMap(Map<String, dynamic> map)
    : _id = map['id'],
      scheduleId = map['scheduleId'] ?? 0,
      cacheId = map["cacheId"] ?? "",
      blockId = map['blockId'] ?? "",
      status = reminderStatus.values[map['status']],
      name = map['name'] ?? "",
      time = DateTime.parse(map['time']);
  @override
  String toString() {
    return toMap().toString();
  }

  int getTimeReminding() {
    return time.difference(DateTime.now()).inMinutes;
  }
}
