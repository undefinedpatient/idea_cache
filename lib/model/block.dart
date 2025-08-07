import 'package:idea_cache/model/status.dart';
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

  // (json['content'] as List<dynamic>)
  //     .map((item) => Map<String, dynamic>.from(item as Map))
  //     .toList();
  // Convert Cache object to Json String, the String can be encode with dart:convert jsonEncode()
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
