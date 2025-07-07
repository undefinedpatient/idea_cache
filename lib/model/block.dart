import 'package:uuid/uuid.dart';

class Block {
  final String _id;
  String cacheid;
  String content;
  // Unique within the cache
  String name;
  Block({required String cacheid, required this.name})
    : _id = Uuid().v4(),
      cacheid = cacheid,
      content = "";
  Block.fromJson(Map<String, dynamic> json)
    : cacheid = json['cacheid'],
      _id = json['id'],
      name = json['name'],
      content = json['content'];
  // Convert Cache object to Json String, the String can be encode with dart:convert jsonEncode()
  Map<String, dynamic> toJson() {
    return {'id': _id, 'cacheid': cacheid, 'name': name, 'content': content};
  }

  String get id {
    return _id;
  }
}
