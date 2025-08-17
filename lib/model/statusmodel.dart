import 'dart:collection';
import 'package:flutter/material.dart';
import 'package:idea_cache/model/block.dart';
import 'package:idea_cache/model/filehandler.dart';
import 'package:idea_cache/model/status.dart';

class ICStatusModel extends ChangeNotifier {
  final List<ICStatus> _statuses = [];
  UnmodifiableListView<ICStatus> get statuses =>
      UnmodifiableListView(_statuses);
  Future<void> loadFromFile() async {
    _statuses.clear();
    _statuses.addAll(await FileHandler.readStatus());
    notifyListeners();
  }

  Future<void> createStatus() async {
    ICStatus status = ICStatus(statusName: "UnnamedStatus");
    FileHandler.appendStatus(status);
    _statuses.add(status);
    notifyListeners();
  }

  Future<void> reorderStatus(int from, int to) async {
    if (from < to) {
      to--;
    }
    _statuses.insert(to, _statuses.removeAt(from));
    notifyListeners();
    await FileHandler.reorderStatuses(from, to);
    notifyListeners();
  }

  Future<void> updateStatus(ICStatus status) async {
    int targetReplaceIndex = statuses.indexWhere(
      (item) => item.id == status.id,
    );
    _statuses[targetReplaceIndex] = status;
    await FileHandler.updateStatus(status);
    notifyListeners();
  }

  Future<void> deleteStatusById(String statusId) async {
    _statuses.removeWhere((status) => status.id == statusId);
    FileHandler.deleteStatusById(statusId);
    notifyListeners();
  }

  ICStatus? findStatusByBlock(ICBlock block) {
    if (block.statusId == "") {
      return null;
    }
    for (int i = 0; i < statuses.length; i++) {
      if (statuses[i].id == block.statusId &&
          (statuses[i].cacheId == block.cacheId ||
              statuses[i].cacheId.isEmpty)) {
        return statuses[i];
      }
    }
    return null;
  }

  List<ICStatus> findAvailableByCacheId(String cacheId) {
    List<ICStatus>? availableStatuses = List.empty(growable: true);
    // Filtering
    for (int i = 0; i < _statuses.length; i++) {
      if (_statuses[i].cacheId == cacheId || _statuses[i].cacheId == "") {
        availableStatuses.add(_statuses[i]);
      }
    }
    return availableStatuses;
  }
}
