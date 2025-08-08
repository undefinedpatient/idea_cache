import 'dart:developer';

import 'package:uuid/uuid.dart';

class ICBlock {
  final String _id;
  String cacheId;
  String content;
  String statusId;
  // Unique within the cache
  String name;
  ICBlock({required String cacheid, required this.name})
    : _id = Uuid().v4(),
      cacheId = cacheid,
      content = "",
      statusId = "";
  ICBlock.fromJson(Map<String, dynamic> json)
    : cacheId = json['cacheId'],
      _id = json['id'],
      name = json['name'],
      content = json['content'],
      statusId = json['statusId'];

  String get id {
    return _id;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': _id,
      'cacheId': cacheId,
      'name': name,
      'content': content,
      'statusId': statusId,
    };
  }

  ICBlock setContent(String content) {
    this.content = content;
    return this;
  }
}
