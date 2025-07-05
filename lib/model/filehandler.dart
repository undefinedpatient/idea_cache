import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

import 'cache.dart';

enum FileDestinationType { cache, block }

class FileHandler {
  // File I/O
  static Future<String> _localPath() async {
    final Directory directory = await getApplicationDocumentsDirectory();
    log(directory.toString());
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
  static Future<File> writeCache(Cache cache) async {
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

  static Future<Cache?> findCacheByName(String cachename) async {
    List<Cache>? caches = await readCaches();
    for (int i = 0; i < caches.length; i++) {
      if (caches[i].name == cachename) {
        return caches[i];
      }
    }
    return null;
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
}
