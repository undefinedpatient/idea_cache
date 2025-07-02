import 'dart:ffi';

class Cache {
  Cache(int id, this.name) : _id = id;
  final int _id;
  final List<Int> _blockIds = List.empty(growable: true);
  String name;

  int get id {
    return _id;
  }

  List<Int> get blockIds {
    return _blockIds;
  }

  List<Int> addBlockId(Int blockId) {
    if (_blockIds.contains(blockId)) {
      return _blockIds;
    }
    _blockIds.add(blockId);
    return _blockIds;
  }
}
