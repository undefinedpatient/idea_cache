import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class ICStatus {
  final String _id;
  String cacheId = ""; //If cacheId is empty, then it is a global status
  String statusName = "";
  int colorCode = const Color.fromARGB(
    255,
    0,
    0,
    0,
  ).toARGB32(); //If all 0, then default color is used, default is depending on the theme
  ICStatus({String? cacheId, required String statusName, int? colorCode})
    : _id = Uuid().v4(),
      statusName = statusName {
    this.cacheId = (cacheId != null) ? cacheId : this.cacheId;
    this.colorCode = (colorCode != null) ? colorCode : this.colorCode;
  }
  ICStatus.empty() : _id = "", statusName = "None";
  ICStatus.fromMap(Map<String, dynamic> json)
    : _id = json['id'],
      cacheId = json['cacheId'],
      statusName = json['statusName'],
      colorCode = json['colorCode'];

  String get id {
    return _id;
  }

  Map<String, dynamic> toMap() {
    return {
      'id': _id,
      'cacheId': cacheId,
      'statusName': statusName,
      'colorCode': colorCode,
    };
  }
}
