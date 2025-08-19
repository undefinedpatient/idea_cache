import 'package:uuid/uuid.dart';

enum notificationStatus { SCHEDULED, TRIGGERED, DISMISSED }

class ICNotification {
  final String _id;
  String blockId;
  notificationStatus status;
  String name;
  String description;
  int time = 0;
  ICNotification({
    required this.blockId,
    this.status = notificationStatus.SCHEDULED,
    this.name = "Untitled",
    this.description = "",
    required this.time,
  }) : _id = Uuid().v4();

  String get id => _id;
  // Convert to Map for DB
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'blockId': blockId,
      'status': status.index,
      'title': name,
      'description': description,
      'time': time,
    };
  }

  ICNotification.fromMap(Map<String, dynamic> map)
    : _id = map['id'],
      blockId = map['blockId'],
      status = map['status'],
      name = map['title'],
      description = map['description'],
      time = map['time'];
}
