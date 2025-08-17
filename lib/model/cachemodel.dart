import 'dart:collection';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:idea_cache/model/cache.dart';
import 'package:idea_cache/model/filehandler.dart';

class ICCacheModel extends ChangeNotifier {
  final List<Cache> _caches = []; // Unordered List
  UnmodifiableListView<Cache> get caches => UnmodifiableListView(_caches);
  bool _isLoading = false;
  bool get isLoading => _isLoading;
  Future<void> loadFromFile() async {
    _isLoading = true;
    notifyListeners();
    caches.clear();
    await FileHandler.readCaches().then((caches) {
      for (Cache item in caches) {
        _caches.add(item);
      }
    });
    _isLoading = false;
    notifyListeners();
  }

  Future<void> reorderCachesByIds(String from, String to) async {
    int fromIndex = _caches.indexWhere((cache) => cache.id == from);
    int toIndex = _caches.indexWhere((cache) => cache.id == to);
    log("from: ${fromIndex} to: ${toIndex}");
    Cache fromCache = _caches.removeAt(fromIndex);
    _caches.insert(toIndex, fromCache);
    // FileHandler.reorderCachesByIds(from, to);
    notifyListeners();
  }

  Future<void> reorderCache(int from, int to) async {
    if (from < to) {
      to--;
    }
    FileHandler.reorderCaches(from, to);
    _caches.insert(to, _caches.removeAt(from));
    notifyListeners();
  }

  Future<Cache> createCache() async {
    Cache cache = Cache(name: "Untitled");
    await FileHandler.appendCache(cache);
    _caches.add(cache);
    notifyListeners();
    return cache;
  }

  Future<void> updateCache(Cache cache) async {
    await FileHandler.updateCache(cache);
    int targetReplaceIndex = _caches.indexWhere((item) => item.id == cache.id);
    _caches[targetReplaceIndex] = cache;
    notifyListeners();
  }

  Future<void> deleteCacheById(String id) async {
    await FileHandler.deleteCacheById(id);
    _caches.removeWhere((caches) => caches.id == id);
    notifyListeners();
  }
}
