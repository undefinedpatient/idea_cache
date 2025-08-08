
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

  @override
  bool operator ==(Object other) {
    // if (identical(this, other)) return true;
    // if (other.runtimeType != runtimeType) return false;
    other = other as ICBlock;
    return other._id == _id &&
        other.cacheId == cacheId &&
        other.name == name &&
        other.content == content &&
        other.statusId == statusId;
  }

  @override
  int get hashCode {
    return Object.hash(_id, cacheId, name, content, statusId);
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
