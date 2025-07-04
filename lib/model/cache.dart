import 'package:uuid/uuid.dart';

class Cache {
  final String _id;
  late List<int> _blockIds;
  String name;
  // Construct a new Cache with name
  Cache({required this.name}) : _id = Uuid().v4() {
    _blockIds = List.empty(growable: true);
  }
  // Construct a Cache from Json
  Cache.fromJson(Map<String, dynamic> json)
    : _id = json['id'],
      name = json['name'] {
    for (int i = 0; i < json['blockId'].length; i++) {
      addBlockId(json['blockId'][i]);
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
