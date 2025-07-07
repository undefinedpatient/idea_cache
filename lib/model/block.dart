import 'package:uuid/uuid.dart';

class Block {
  final String _id;
  String content;
  // Unique within the cache
  String name;
  Block({required this.name}) : _id = Uuid().v4(), content = "";
  Block.fromJson(Map<String, dynamic> json)
    : _id = json['id'],
      name = json['name'],
      content = json['content'];
  // Convert Cache object to Json String, the String can be encode with dart:convert jsonEncode()
  Map<String, dynamic> toJson() {
    return {'id': _id, 'name': name, 'content': content};
  }

  String get id {
    return _id;
  }
}
