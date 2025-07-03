import 'package:path_provider/path_provider.dart';

class Cache {
  Cache({required int id, required this.name}) : _id = id;
  final int _id;
  final List<int> _blockIds = List.empty(growable: true);
  String name;

  int get id {
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
