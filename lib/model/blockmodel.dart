import 'dart:collection';
import 'package:flutter/material.dart';
import 'package:idea_cache/model/block.dart';
import 'package:idea_cache/model/cache.dart';
import 'package:idea_cache/model/filehandler.dart';

class ICBlockModel extends ChangeNotifier {
  // final List<ICBlock> _blocks = [];

  final Map<String, List<ICBlock>> _cacheBlocksMap = {};
  // UnmodifiableListView<ICBlock> get blocks => UnmodifiableListView(_blocks);
  UnmodifiableMapView<String, List<ICBlock>> get cacheBlocksMap =>
      UnmodifiableMapView(_cacheBlocksMap);
  bool _isLoading = false;
  bool get isLoading => _isLoading;
  Future<void> loadFromFile() async {
    _isLoading = true;
    notifyListeners();

    _cacheBlocksMap.clear();
    List<Cache> caches = await FileHandler.readCaches();
    for (int i = 0; i < caches.length; i++) {
      _cacheBlocksMap.addAll({
        caches[i].id: await FileHandler.findBlocksByCacheId(caches[i].id),
      });
    }
    _isLoading = false;
    notifyListeners();
  }

  // This function check the existance of certain block in certain cache,
  // return false if the target block not exist
  bool checkExistance(String cacheId, String blockId) {
    if (_cacheBlocksMap[cacheId]!.indexWhere((block) => block.id == blockId) !=
        -1) {
      return true;
    }
    return false;
  }

  Future<void> updateLocalBlockMapByCacheId(String cacheId) async {
    _cacheBlocksMap[cacheId] = await FileHandler.findBlocksByCacheId(cacheId);
    notifyListeners();
  }

  Future<ICBlock> createBlock(String cacheId) async {
    ICBlock block = ICBlock(cacheId: cacheId, name: "Untitled");
    Cache? parentCache = await FileHandler.findCacheById(cacheId);
    if (parentCache == null) {
      throw Exception("createBlock: parentCache cannot be found");
    }

    parentCache.addBlockId(block.id);
    await FileHandler.appendBlock(block);
    await FileHandler.updateCache(parentCache);
    await updateLocalBlockMapByCacheId(cacheId);
    notifyListeners();
    return block;
  }

  Future<void> reorderBlockByCacheId(String cacheId, int from, int to) async {
    if (from < to) {
      to--;
    }
    // Update the local Storge First since it cost less time
    cacheBlocksMap[cacheId]!.insert(
      to,
      cacheBlocksMap[cacheId]!.removeAt(from),
    );
    notifyListeners();

    // Then save it to the storage
    Cache? parentCache = await FileHandler.findCacheById(cacheId);
    if (parentCache == null) {
      throw Exception("reorderBlockByCacheId: parentCache not found!");
    }

    parentCache.swapBlockId(from, to);
    await FileHandler.updateCache(parentCache);

    notifyListeners();
  }

  Future<void> updateBlock(ICBlock block) async {
    await FileHandler.updateBlock(block);
    await updateLocalBlockMapByCacheId(block.cacheId);
    notifyListeners();
  }

  Future<void> deleteBlock(ICBlock block) async {
    await FileHandler.deleteBlocksById(block.id);
    Cache? parentCache = await FileHandler.findCacheById(block.cacheId);
    if (parentCache == null) {
      throw Exception("reorderBlockByCacheId: parentCache not found!");
    }
    parentCache.removeBlockId(block.id);
    await FileHandler.updateCache(parentCache);
    await updateLocalBlockMapByCacheId(block.cacheId);
    notifyListeners();
  }
}
