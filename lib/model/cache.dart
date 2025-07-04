import 'package:uuid/uuid.dart';

class Cache {
  final String _id;
  final List<int> _blockIds = List.empty(growable: true);
  String name;
  // Construct a new Cache with name
  Cache({required this.name}) : _id = Uuid().v4();
  // Construct a Cache from Json
  Cache.fromJson(Map<String, dynamic> json)
    : _id = json['id'],
      name = json['name'] {
    for (int i = 0; i < json['blockIds'].length; i++) {
      addBlockId(json['blockIds'][i]);
    }
  }
  // Convert Cache object to Json String, the String can be encode with dart:convert jsonEncode()
  Map<String, dynamic> toJson() {
    return {'id': _id, 'blockIds': _blockIds, 'name': name};
  }

  String get id {
    return _id;
  }

  List<int> get blockIds {
    return List.unmodifiable(_blockIds);
  }

  List<int> addBlockId(int blockId) {
    if (_blockIds.contains(blockId)) {
      return _blockIds;
    }
    _blockIds.add(blockId);
    return _blockIds;
  }
}
