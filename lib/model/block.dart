import 'package:uuid/uuid.dart';

class ICBlock {
  final String _id;
  String cacheid;
  String content;
  // Unique within the cache
  String name;
  ICBlock({required String cacheid, required this.name})
    : _id = Uuid().v4(),
      cacheid = cacheid,
      content = "";
  ICBlock.fromJson(Map<String, dynamic> json)
    : cacheid = json['cacheid'],
      _id = json['id'],
      name = json['name'],
      content = json['content'];
  // (json['content'] as List<dynamic>)
  //     .map((item) => Map<String, dynamic>.from(item as Map))
  //     .toList();
  // Convert Cache object to Json String, the String can be encode with dart:convert jsonEncode()
  Map<String, dynamic> toJson() {
    return {'id': _id, 'cacheid': cacheid, 'name': name, 'content': content};
  }

  String get id {
    return _id;
  }

  ICBlock setContent(String content) {
    this.content = content;
    return this;
  }
}
