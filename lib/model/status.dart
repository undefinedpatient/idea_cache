import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class ICStatus {
  final String _id;
  String cacheId = ""; //If cacheId is empty, then it is a global status
  String statusName = "";
  int colorCode = Colors.black.toARGB32();
  ICStatus({String? cacheId, String? statusName, int? colorCode})
    : _id = Uuid().v4() {
    this.cacheId = (cacheId != null) ? cacheId : this.cacheId;
    this.statusName = (statusName != null) ? statusName : this.statusName;
    this.colorCode = (colorCode != null) ? colorCode : this.colorCode;
  }
  ICStatus.fromJson(Map<String, dynamic> json)
    : _id = json['id'],
      cacheId = json['cacheId'],
      statusName = json['statusName'],
      colorCode = json['colorCode'];

  String get id {
    return _id;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': _id,
      'cacheId': cacheId,
      'statusName': statusName,
      'colorCode': colorCode,
    };
  }
}
