import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:idea_cache/model/block.dart';
import 'package:path_provider/path_provider.dart';

import 'cache.dart';

enum FileDestinationType { cache, block }

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
    return await file.writeAsString(
      jsonEncode(existingCaches.map((value) => value.toJson()).toList()),
    );
  }

  // Append a new Block data in form of json
  static Future<File> appendBlock(ICBlock block) async {
    final File file = await _localFile(
      fileDestinationType: FileDestinationType.block,
    );

    List<ICBlock>? blocks = await findBlocksByCacheId(block.cacheid);
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

    List<ICBlock> existingBlocks = await readBlocks();
    existingBlocks.add(block);
    return await file.writeAsString(
      jsonEncode(existingBlocks.map((value) => value.toJson()).toList()),
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

    int occurrence = 0;
    while (await findCacheByName(cache.name) != null) {
      String oldName = cache.name;
      cache.name =
          "${oldName.split('.')[0]}.${occurrence.toString().padLeft(3, '0')}";
      occurrence++;
    }
    List<Cache> existingCaches = await readCaches();
    for (int i = 0; i < existingCaches.length; i++) {
      if (existingCaches[i].id == cache.id) {
        existingCaches[i] = cache;
        break;
      }
    }
    // log("Cache Updated", name: "updateCache");
    return await file.writeAsString(
      jsonEncode(existingCaches.map((value) => value.toJson()).toList()),
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

    List<ICBlock>? blocks = await findBlocksByCacheId(block.cacheid);
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

    List<ICBlock> exisitingBlock = await readBlocks();
    //Replacing Block
    for (int i = 0; i < exisitingBlock.length; i++) {
      if (exisitingBlock[i].id == block.id) {
        exisitingBlock[i] = block;
        break;
      }
    }
    return await file.writeAsString(
      jsonEncode(exisitingBlock.map((value) => value.toJson()).toList()),
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
      if (existingBlocks[i].cacheid != cacheId) {
        newBlocks.add(existingBlocks[i]);
      }
    }
    return file.writeAsString(
      jsonEncode(newBlocks.map((value) => value.toJson()).toList()),
    );
  }

  static Future<File> deleteBlocksById(blockId) async {
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

  static Future<ICBlock?> findBlockByName(String blockname) async {
    List<ICBlock>? blocks = await readBlocks();
    for (int i = 0; i < blocks.length; i++) {
      if (blocks[i].name == blockname) {
        return blocks[i];
      }
    }
    return null;
  }

  static Future<List<ICBlock>> findBlocksByCacheId(String cacheid) async {
    List<ICBlock>? unorderedBlocks = List.empty(growable: true);
    //
    List<ICBlock>? orderedblocks = List.empty(growable: true);
    List<ICBlock>? readblocks = await readBlocks();
    Cache? cache = await findCacheById(cacheid);
    if (cache == null) {
      throw Exception("findBlocksByCacheId: cache is null!");
    }
    for (int i = 0; i < readblocks.length; i++) {
      if (readblocks[i].cacheid == cacheid) {
        unorderedBlocks.add(readblocks[i]);
      }
    }
    // log(
    //   name: "readblocks",
    //   readblocks.map((block) => block.id).toList().toString(),
    // );
    // log(
    //   name: "unorderedBlocks",
    //   unorderedBlocks.map((block) => block.id).toList().toString(),
    // );
    // log(name: "cache.blockIds", cache.blockIds.toString());

    for (int i = 0; i < cache.blockIds.length; i++) {
      int indexOfTargetBlock = unorderedBlocks
          .map((block) => block.id)
          .toList()
          .indexOf(cache.blockIds[i]);
      orderedblocks.add(unorderedBlocks[indexOfTargetBlock]);
    }
    return orderedblocks;
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

  static Future<List<ICBlock>> readBlocks() async {
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
}
