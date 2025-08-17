import 'dart:collection';
import 'dart:developer';
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

    // _blocks.clear();
    _cacheBlocksMap.clear();
    // _blocks.addAll(await FileHandler.readBlocks());
    log("Update Completed");
    List<Cache> caches = await FileHandler.readCaches();
    for (int i = 0; i < caches.length; i++) {
      _cacheBlocksMap.addAll({
        caches[i].id: await FileHandler.findBlocksByCacheId(caches[i].id),
      });
    }
    log("Update Completed1");
    _isLoading = false;
    notifyListeners();
  }

  Future<void> updateLocalBlockMapByCacheId(String cacheId) async {
    _cacheBlocksMap[cacheId] = await FileHandler.findBlocksByCacheId(cacheId);
    notifyListeners();
  }

  Future<void> createBlock(String cacheId) async {
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

  Future<void> deleteBlockById(ICBlock block) async {
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
