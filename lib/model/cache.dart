import 'dart:developer';

import 'package:uuid/uuid.dart';

class Cache {
  final String _id;
  final List<String> _blockIds = List.empty(growable: true);
  final List<String> _statusIds = List.empty(growable: true);
  // Priorize, current only have 0(Normal) and 1 (Pinned)
  int priority = 0;
  String name;
  // Construct a new Cache with name
  Cache({required this.name}) : _id = Uuid().v4(), priority = 0;
  // Construct a Cache from Json
  Cache.fromJson(Map<String, dynamic> json)
    : _id = json['id'],
      name = json['name'],
      priority = json['priority'] {
    for (int i = 0; i < json['blockIds'].length; i++) {
      addBlockId(json['blockIds'][i]);
    }
    for (int i = 0; i < json['statusIds'].length; i++) {
      addStatusId(json['statusIds'][i]);
    }
  }
  // Convert Cache object to Json String, the String can be encode with dart:convert jsonEncode()
  Map<String, dynamic> toJson() {
    return {
      'id': _id,
      'blockIds': _blockIds,
      'statusIds': _statusIds,
      'name': name,
      'priority': priority,
    };
  }

  String get id {
    return _id;
  }

  List<String> get blockIds {
    return List.unmodifiable(_blockIds);
  }

  List<String> addStatusId(String statusId) {
    if (_statusIds.contains(statusId)) {
      return List.unmodifiable(_statusIds);
    }
    _statusIds.add(statusId);
    return List.unmodifiable(_statusIds);
  }

  List<String> removeStatusId(String statusId) {
    if (_statusIds.contains(statusId)) {
      _statusIds.remove(statusId);
      return List.unmodifiable(_statusIds);
    }
    return List.unmodifiable(_statusIds);
  }

  List<String> removeBlockId(String blockId) {
    if (_blockIds.contains(blockId)) {
      _blockIds.remove(blockId);
      log(name: "removeBlockIds", "current Block id ${_blockIds.toList()}");
      return List.unmodifiable(_blockIds);
    }
    return List.unmodifiable(_blockIds);
  }

  List<String> addBlockId(String blockId) {
    if (_blockIds.contains(blockId)) {
      return List.unmodifiable(_blockIds);
    }
    _blockIds.add(blockId);
    return List.unmodifiable(_blockIds);
  }

  List<String> reorderBlockId(int from, int to) {
    if (to > _blockIds.length - 1) {
      throw Exception("Index Error: Trying to access out of range");
    }
    String temp = _blockIds[to];
    _blockIds[to] = _blockIds[from];
    _blockIds[from] = temp;
    return List.unmodifiable(_blockIds);
  }
}
