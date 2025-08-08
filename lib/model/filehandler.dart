import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:idea_cache/model/block.dart';
import 'package:idea_cache/model/setting.dart';
import 'package:idea_cache/model/status.dart';
import 'package:path_provider/path_provider.dart';

import 'cache.dart';

enum FileDestinationType { cache, block, setting, status }

class FileHandler {
  // File I/O
  static Future<String> _localPath() async {
    final Directory directory = await getApplicationDocumentsDirectory();
    // log(directory.toString(), name: "FileHandler");
    return directory.path;
  }

  // Return the file to be read/written by file name and its DestinationType
  static Future<File> _localFile({
    required FileDestinationType fileDestinationType,
  }) async {
    final String path = await _localPath();
    switch (fileDestinationType) {
      case FileDestinationType.cache:
        return File("$path/IdeaCache/caches.json").create(recursive: true);
      case FileDestinationType.block:
        return File("$path/IdeaCache/blocks.json").create(recursive: true);
      case FileDestinationType.status:
        return File("$path/IdeaCache/status.json").create(recursive: true);
      case FileDestinationType.setting:
        return File("$path/IdeaCache/settings.json").create(recursive: true);
    }
  }

  // Append a new Cache data in form of json
  static Future<File> appendCache(Cache cache) async {
    final File file = await _localFile(
      fileDestinationType: FileDestinationType.cache,
    );
    int occurrence = 1;
    while (await findCacheByName(cache.name) != null) {
      String oldName = cache.name;
      cache.name =
          "${oldName.split('.')[0]}.${occurrence.toString().padLeft(3, '0')}";

      occurrence++;
    }
    List<Cache> existingCaches = await readCaches();
    existingCaches.add(cache);
    JsonEncoder jsonEncoder = JsonEncoder.withIndent("  ");
    return await file.writeAsString(
      jsonEncoder.convert(
        existingCaches.map((value) => value.toJson()).toList(),
      ),
    );
  }

  // Append a new Block data in form of json
  static Future<File> appendBlock(ICBlock block) async {
    final File file = await _localFile(
      fileDestinationType: FileDestinationType.block,
    );
    // If the new block name is already in form abc.001, strip away the .001 first
    block.name = block.name.split('.')[0];
    List<ICBlock>? blocks = await findBlocksByCacheId(block.cacheId);
    if (blocks.isNotEmpty) {
      int occurrence = 0;
      for (int i = 0; i < blocks.length; i++) {
        log(blocks[i].name);
        String oldName = block.name;
        if (blocks[i].name == block.name) {
          occurrence++;
          block.name =
              "${oldName.split('.')[0]}.${occurrence.toString().padLeft(3, '0')}";
        }
      }
    }
    List<ICBlock> existingBlocks = await readBlocks();
    existingBlocks.add(block);
    JsonEncoder jsonEncoder = JsonEncoder.withIndent("  ");
    return await file.writeAsString(
      jsonEncoder.convert(
        existingBlocks.map((value) => value.toJson()).toList(),
      ),
    );
  }

  static Future<File> appendStatus(ICStatus status) async {
    final File file = await _localFile(
      fileDestinationType: FileDestinationType.status,
    );
    // If the new block name is already in form abc.001, strip away the .001 first
    status.statusName = status.statusName.split('.')[0];
    List<ICStatus>? statuses = await readStatus();
    if (statuses.isNotEmpty) {
      int occurrence = 0;
      for (int i = 0; i < statuses.length; i++) {
        String oldName = status.statusName;
        if (statuses[i].statusName == status.statusName) {
          occurrence++;
          status.statusName =
              "${oldName.split('.')[0]}.${occurrence.toString().padLeft(3, '0')}";
        }
      }
    }

    List<ICStatus> existingStatuses = await readStatus();
    existingStatuses.add(status);
    JsonEncoder jsonEncoder = JsonEncoder.withIndent("  ");
    return await file.writeAsString(
      jsonEncoder.convert(
        existingStatuses.map((value) => value.toJson()).toList(),
      ),
    );
  }

  /* 
  Update the current existing Cache in the DB
  If no cache is found, call appendCache(Cache cache) instead
  */
  static Future<File> updateCache(Cache cache) async {
    final File file = await _localFile(
      fileDestinationType: FileDestinationType.cache,
    );
    final Cache? oldCache = await findCacheById(cache.id);
    if (oldCache == null) {
      return appendCache(cache);
    }
    List<Cache>? caches = await readCaches();
    caches.removeWhere((item) => item.id == cache.id);
    if (caches.isNotEmpty) {
      int occurrence = 0;
      for (int i = 0; i < caches.length; i++) {
        String oldName = cache.name;
        if (caches[i].name == cache.name) {
          occurrence++;
          cache.name =
              "${oldName.split('.')[0]}.${occurrence.toString().padLeft(3, '0')}";
        }
      }
    }

    List<Cache> existingCaches = await readCaches();
    // Updating Cache with the same id
    for (int i = 0; i < existingCaches.length; i++) {
      if (existingCaches[i].id == cache.id) {
        existingCaches[i] = cache;
        break;
      }
    }

    JsonEncoder jsonEncoder = JsonEncoder.withIndent("  ");
    return await file.writeAsString(
      jsonEncoder.convert(
        existingCaches.map((value) => value.toJson()).toList(),
      ),
    );
  }

  static Future<File> updateBlock(ICBlock block) async {
    final File file = await _localFile(
      fileDestinationType: FileDestinationType.block,
    );
    final ICBlock? oldBlock = await findBlockById(block.id);
    if (oldBlock == null) {
      return appendBlock(block);
    }
    //Retrieve a list of blocks from the file
    List<ICBlock>? blocks = await findBlocksByCacheId(block.cacheId);
    blocks.removeWhere((item) => item.id == block.id);
    if (blocks.isNotEmpty) {
      int occurrence = 0;
      for (int i = 0; i < blocks.length; i++) {
        String oldName = block.name;
        if (blocks[i].name == block.name) {
          occurrence++;
          block.name =
              "${oldName.split('.')[0]}.${occurrence.toString().padLeft(3, '0')}";
        }
      }
    }

    List<ICBlock> existingBlock = await readBlocks();
    //Replacing Block
    for (int i = 0; i < existingBlock.length; i++) {
      if (existingBlock[i].id == block.id) {
        existingBlock[i] = block;
        break;
      }
    }

    JsonEncoder jsonEncoder = JsonEncoder.withIndent("  ");

    return await file.writeAsString(
      jsonEncoder.convert(
        existingBlock.map((value) => value.toJson()).toList(),
      ),
    );
  }

  static Future<File> updateStatus(ICStatus status) async {
    final File file = await _localFile(
      fileDestinationType: FileDestinationType.status,
    );
    final ICStatus? oldStatus = await findStatusById(status.id);
    if (oldStatus == null) {
      return appendStatus(status);
    }
    // If it is a cache that switch from Global to Local/Local to Local visibility
    if (status.cacheId != oldStatus.cacheId) {
      // First read all block first
      List<ICBlock> blocks = await readBlocks();
      // Then iterate through all blocks, if the block has this status, remove it
      for (int i = 0; i < blocks.length; i++) {
        if (blocks[i].statusId == status.id) {
          blocks[i].statusId = "";
          await updateBlock(blocks[i]);
        }
      }
    }
    List<ICStatus>? statuses = await readStatus();
    statuses.removeWhere((item) => item.id == status.id);
    if (statuses.isNotEmpty) {
      int occurrence = 0;
      for (int i = 0; i < statuses.length; i++) {
        String oldName = status.statusName;
        if (statuses[i].statusName == status.statusName) {
          occurrence++;
          status.statusName =
              "${oldName.split('.')[0]}.${occurrence.toString().padLeft(3, '0')}";
        }
      }
    }

    List<ICStatus> existingStatuses = await readStatus();
    // Updating Status with the same id
    for (int i = 0; i < existingStatuses.length; i++) {
      if (existingStatuses[i].id == status.id) {
        existingStatuses[i] = status;
        break;
      }
    }

    JsonEncoder jsonEncoder = JsonEncoder.withIndent("  ");
    return await file.writeAsString(
      jsonEncoder.convert(
        existingStatuses.map((value) => value.toJson()).toList(),
      ),
    );
  }

  static Future<File> reorderCaches(int from, int to) async {
    File file = await _localFile(
      fileDestinationType: FileDestinationType.cache,
    );
    List<Cache> caches = await readCaches();
    if (from < to) {
      to -= 1;
    }
    final Cache item = caches.removeAt(from);
    caches.insert(to, item);
    return file.writeAsString(
      jsonEncode(caches.map((cache) => cache.toJson()).toList()),
    );
  }

  static Future<File> reorderStatuses(int from, int to) async {
    File file = await _localFile(
      fileDestinationType: FileDestinationType.status,
    );
    List<ICStatus> statuses = await readStatus();
    if (from < to) {
      to -= 1;
    }
    final ICStatus item = statuses.removeAt(from);
    statuses.insert(to, item);
    return file.writeAsString(
      jsonEncode(statuses.map((status) => status.toJson()).toList()),
    );
  }

  static Future<Setting> loadSetting() async {
    File file = await _localFile(
      fileDestinationType: FileDestinationType.setting,
    );
    try {
      if (file.existsSync()) {
        String content = await file.readAsString();
        Map<String, dynamic> jsonMap =
            jsonDecode(content) as Map<String, dynamic>;
        return Setting.fromJson(jsonMap);
      }
    } catch (err) {
      log(name: "FileHandler.loadSetting()", err.toString(), level: 2);
    }
    return Setting();
  }

  static Future<File> saveSetting(Setting setting) async {
    File file = await _localFile(
      fileDestinationType: FileDestinationType.setting,
    );
    String content = "";
    try {
      if (file.existsSync()) {
        content = jsonEncode(setting.toJson());
      }
    } catch (err) {
      log(name: "FileHandler.saveSetting()", err.toString(), level: 2);
    }
    return await file.writeAsString(content);
  }

  /*
  Delete a cache with the given cacheId
  */
  static Future<File> deleteCacheById(String cacheId) async {
    final File file = await _localFile(
      fileDestinationType: FileDestinationType.cache,
    );
    final Cache? cache = await findCacheById(cacheId);
    List<Cache> existingCaches = await readCaches();
    if (cache == null) {
      return file;
    }

    for (int i = 0; i < existingCaches.length; i++) {
      if (existingCaches[i].id == cacheId) {
        existingCaches.removeAt(i);
        break;
      }
    }
    //Remove all the status associated with this cache
    List<ICStatus> statuses = await readStatus();
    for (int i = 0; i < statuses.length; i++) {
      if (statuses[i].cacheId == cacheId) {
        await deleteStatusById(statuses[i].id);
      }
    }
    //Delete all the cacheBlock related
    deleteBlocksByCacheId(cacheId);
    return file.writeAsString(
      jsonEncode(existingCaches.map((value) => value.toJson()).toList()),
    );
  }

  static Future<File> deleteBlocksByCacheId(String cacheId) async {
    final File file = await _localFile(
      fileDestinationType: FileDestinationType.block,
    );
    final List<ICBlock> existingBlocks = await readBlocks();
    List<ICBlock> newBlocks = List.empty(growable: true);
    for (int i = 0; i < existingBlocks.length; i++) {
      if (existingBlocks[i].cacheId != cacheId) {
        newBlocks.add(existingBlocks[i]);
      }
    }
    return file.writeAsString(
      jsonEncode(newBlocks.map((value) => value.toJson()).toList()),
    );
  }

  static Future<File> deleteBlocksById(String blockId) async {
    final File file = await _localFile(
      fileDestinationType: FileDestinationType.block,
    );
    final ICBlock? block = await findBlockById(blockId);
    List<ICBlock> existingBlocks = await readBlocks();
    if (block == null) {
      return file;
    }

    for (int i = 0; i < existingBlocks.length; i++) {
      if (existingBlocks[i].id == blockId) {
        existingBlocks.removeAt(i);
        break;
      }
    }

    return file.writeAsString(
      jsonEncode(existingBlocks.map((value) => value.toJson()).toList()),
    );
  }

  static Future<File> deleteStatusById(String statusId) async {
    final File file = await _localFile(
      fileDestinationType: FileDestinationType.status,
    );
    final ICStatus? status = await findStatusById(statusId);
    List<ICStatus> existingStatuses = await readStatus();
    List<ICBlock> relevantBlocks = await readBlocks();
    if (status == null) {
      return file;
    }

    for (int i = 0; i < existingStatuses.length; i++) {
      if (existingStatuses[i].id == statusId) {
        existingStatuses.removeAt(i);
        break;
      }
    }
    // If any block still have the status in them, remove their status too
    for (int i = 0; i < relevantBlocks.length; i++) {
      if (relevantBlocks[i].statusId == statusId) {
        relevantBlocks[i].statusId = "";
        await updateBlock(relevantBlocks[i]);
      }
    }
    return file.writeAsString(
      jsonEncode(existingStatuses.map((value) => value.toJson()).toList()),
    );
  }

  /*
  Find the Cache by cachename
  */
  static Future<Cache?> findCacheByName(String cachename) async {
    List<Cache>? caches = await readCaches();
    for (int i = 0; i < caches.length; i++) {
      if (caches[i].name == cachename) {
        return caches[i];
      }
    }
    return null;
  }

  static Future<ICStatus?> findStatusByName(String statusname) async {
    List<ICStatus>? statuses = await readStatus();
    for (int i = 0; i < statuses.length; i++) {
      if (statuses[i].statusName == statusname) {
        return statuses[i];
      }
    }
    return null;
  }

  static Future<ICStatus?> findStatusById(String statusId) async {
    List<ICStatus>? statuses = await readStatus();
    for (int i = 0; i < statuses.length; i++) {
      if (statuses[i].id == statusId) {
        return statuses[i];
      }
    }
    return null;
  }

  static Future<ICBlock?> findBlockByName(String blockname) async {
    List<ICBlock>? blocks = await readBlocks();
    for (int i = 0; i < blocks.length; i++) {
      if (blocks[i].name == blockname) {
        return blocks[i];
      }
    }
    return null;
  }

  static Future<List<ICBlock>> findBlocksByCacheId(String cacheId) async {
    List<ICBlock>? unorderedBlocks = List.empty(growable: true);
    List<ICBlock>? orderedblocks = List.empty(growable: true);
    List<ICBlock>? readblocks = await readBlocks();
    Cache? cache = await findCacheById(cacheId);
    if (cache == null) {
      throw Exception("findBlocksByCacheId: cache is null!");
    }
    for (int i = 0; i < readblocks.length; i++) {
      if (readblocks[i].cacheId == cacheId) {
        unorderedBlocks.add(readblocks[i]);
      }
    }
    for (int i = 0; i < cache.blockIds.length; i++) {
      int indexOfTargetBlock = unorderedBlocks
          .map((block) => block.id)
          .toList()
          .indexOf(cache.blockIds[i]);
      orderedblocks.add(unorderedBlocks[indexOfTargetBlock]);
    }
    return orderedblocks;
  }

  static Future<List<ICStatus>> readAvailableStatusByCacheId(
    String cacheId,
  ) async {
    List<ICStatus>? statuses = List.empty(growable: true);
    List<ICStatus>? readStatuses = await readStatus();
    Cache? cache = await findCacheById(cacheId);
    if (cache == null) {
      throw Exception("findBlocksByCacheId: cache is null!");
    }
    // Filtering
    for (int i = 0; i < readStatuses.length; i++) {
      if (readStatuses[i].cacheId == cacheId || readStatuses[i].cacheId == "") {
        statuses.add(readStatuses[i]);
      }
    }
    return statuses;
  }

  static Future<Cache?> findCacheById(String cacheId) async {
    List<Cache>? caches = await readCaches();
    for (int i = 0; i < caches.length; i++) {
      if (caches[i].id == cacheId) {
        return caches[i];
      }
    }
    return null;
  }

  static Future<ICBlock?> findBlockById(String blockId) async {
    List<ICBlock>? blocks = await readBlocks();
    for (int i = 0; i < blocks.length; i++) {
      if (blocks[i].id == blockId) {
        return blocks[i];
      }
    }
    return null;
  }

  static Future<List<Cache>> readCaches() async {
    final File file = await _localFile(
      fileDestinationType: FileDestinationType.cache,
    );
    try {
      if (await file.exists()) {
        final String content = await file.readAsString();
        if (content.isNotEmpty) {
          final List<dynamic> jsonList = jsonDecode(content) as List<dynamic>;
          return jsonList
              .map((json) => Cache.fromJson(json as Map<String, dynamic>))
              .toList();
        }
      }
    } catch (e) {
      log('Error reading caches: $e');
    }
    return []; // Return empty list if file doesn't exist, is empty, or has invalid JSON
  }

  // If data is empty, the readBlocks will automatically fetch data from default storage location
  static Future<List<ICBlock>> readBlocks({String? dataString}) async {
    if (dataString != null && dataString.isNotEmpty) {
      final List<dynamic> jsonList = jsonDecode(dataString) as List<dynamic>;
      // The list Hold list of all blocks existing, and map each of the entry to Map<String, dynamic>
      return jsonList
          .map((json) => ICBlock.fromJson(json as Map<String, dynamic>))
          .toList();
    }
    final File file = await _localFile(
      fileDestinationType: FileDestinationType.block,
    );
    try {
      if (await file.exists()) {
        final String content = await file.readAsString();
        if (content.isNotEmpty) {
          final List<dynamic> jsonList = jsonDecode(content) as List<dynamic>;

          return jsonList
              .map((json) => ICBlock.fromJson(json as Map<String, dynamic>))
              .toList();
        }
      }
    } catch (e) {
      log('Error reading blocks: $e');
    }
    return []; // Return empty list if file doesn't exist, is empty, or has invalid JSON
  }

  static Future<List<ICStatus>> readStatus({String? dataString}) async {
    if (dataString != null && dataString.isNotEmpty) {
      final List<dynamic> jsonList = jsonDecode(dataString) as List<dynamic>;
      // The list Hold list of all blocks existing, and map each of the entry to Map<String, dynamic>
      return jsonList
          .map((json) => ICStatus.fromJson(json as Map<String, dynamic>))
          .toList();
    }
    final File file = await _localFile(
      fileDestinationType: FileDestinationType.status,
    );
    try {
      if (await file.exists()) {
        final String content = await file.readAsString();
        if (content.isNotEmpty) {
          final List<dynamic> jsonList = jsonDecode(content) as List<dynamic>;

          return jsonList
              .map((json) => ICStatus.fromJson(json as Map<String, dynamic>))
              .toList();
        }
      }
    } catch (e) {
      log('Error reading blocks: $e');
    }
    return []; // Return empty list if file doesn't exist, is empty, or has invalid JSON
  }
}
