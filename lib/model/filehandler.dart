import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:idea_cache/model/block.dart';
import 'package:idea_cache/model/reminder.dart';
import 'package:idea_cache/model/status.dart';
import 'package:path_provider/path_provider.dart';

import 'cache.dart';

enum FileDestinationType { cache, block, setting, status, reminder }

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
      case FileDestinationType.reminder:
        return File("$path/IdeaCache/reminders.json").create(recursive: true);
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
        existingCaches.map((value) => value.toMap()).toList(),
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
        // log(blocks[i].name);
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
        existingBlocks.map((value) => value.toMap()).toList(),
      ),
    );
  }

  // Append a new Status data in form of json
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
        existingStatuses.map((value) => value.toMap()).toList(),
      ),
    );
  }

  // Append a new Notification data in form of json
  static Future<File> appendReminder(ICReminder reminder) async {
    final File file = await _localFile(
      fileDestinationType: FileDestinationType.reminder,
    );
    // If the new block name is already in form abc.001, strip away the .001 first
    reminder.name = reminder.name.split('.')[0];
    List<ICReminder>? notifications = await readReminders();
    if (notifications.isNotEmpty) {
      int occurrence = 0;
      for (int i = 0; i < notifications.length; i++) {
        String oldName = reminder.name;
        if (notifications[i].name == reminder.name) {
          occurrence++;
          reminder.name =
              "${oldName.split('.')[0]}.${occurrence.toString().padLeft(3, '0')}";
        }
      }
    }

    List<ICReminder> existingNotification = await readReminders();
    existingNotification.add(reminder);
    JsonEncoder jsonEncoder = JsonEncoder.withIndent("  ");
    return await file.writeAsString(
      jsonEncoder.convert(
        existingNotification.map((value) => value.toMap()).toList(),
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
        existingCaches.map((value) => value.toMap()).toList(),
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
      jsonEncoder.convert(existingBlock.map((value) => value.toMap()).toList()),
    );
  }

  static Future<File> updateStatus(ICStatus newStatus) async {
    final File file = await _localFile(
      fileDestinationType: FileDestinationType.status,
    );
    final ICStatus? oldStatus = await findStatusById(newStatus.id);
    if (oldStatus == null) {
      return appendStatus(newStatus);
    }
    // If it is a cache that switch any visibility
    if (newStatus.cacheId != oldStatus.cacheId) {
      // First read all block first
      List<ICBlock> blocks = await readBlocks();
      // Then iterate through all blocks, if the block has this status, remove it
      for (int i = 0; i < blocks.length; i++) {
        // If the block has the statusId that is being updated
        if (blocks[i].statusId == newStatus.id) {
          // From Global to Local, plus the block is not included anymore
          if (newStatus.cacheId != "" &&
              oldStatus.cacheId == "" &&
              blocks[i].cacheId != newStatus.cacheId) {
            blocks[i].statusId = "";
            await updateBlock(blocks[i]);
            continue;
          }
          // From Local to Local, plus the block is excluded
          if (newStatus.cacheId != "" &&
              oldStatus.cacheId != "" &&
              blocks[i].cacheId != newStatus.cacheId) {
            blocks[i].statusId = "";
            await updateBlock(blocks[i]);
            continue;
          }
        }
      }
    }
    List<ICStatus>? statuses = await readStatus();
    statuses.removeWhere((item) => item.id == newStatus.id);
    if (statuses.isNotEmpty) {
      int occurrence = 0;
      for (int i = 0; i < statuses.length; i++) {
        String oldName = newStatus.statusName;
        if (statuses[i].statusName == newStatus.statusName) {
          occurrence++;
          newStatus.statusName =
              "${oldName.split('.')[0]}.${occurrence.toString().padLeft(3, '0')}";
        }
      }
    }

    List<ICStatus> existingStatuses = await readStatus();
    // Updating Status with the same id
    for (int i = 0; i < existingStatuses.length; i++) {
      if (existingStatuses[i].id == newStatus.id) {
        existingStatuses[i] = newStatus;
        break;
      }
    }

    JsonEncoder jsonEncoder = JsonEncoder.withIndent("  ");
    return await file.writeAsString(
      jsonEncoder.convert(
        existingStatuses.map((value) => value.toMap()).toList(),
      ),
    );
  }

  static Future<File> updateReminder(ICReminder reminder) async {
    final File file = await _localFile(
      fileDestinationType: FileDestinationType.reminder,
    );
    final ICReminder? oldReminder = await findReminderById(reminder.id);
    if (oldReminder == null) {
      return appendReminder(reminder);
    }
    //Retrieve a list of blocks from the file
    List<ICReminder>? notifications = await readReminders();
    notifications.removeWhere((item) => item.id == reminder.id);
    if (notifications.isNotEmpty) {
      int occurrence = 0;
      for (int i = 0; i < notifications.length; i++) {
        String oldName = reminder.name;
        if (notifications[i].name == reminder.name) {
          occurrence++;
          reminder.name =
              "${oldName.split('.')[0]}.${occurrence.toString().padLeft(3, '0')}";
        }
      }
    }

    List<ICReminder> existingNotifications = await readReminders();
    //Replacing Notification
    for (int i = 0; i < existingNotifications.length; i++) {
      if (existingNotifications[i].id == reminder.id) {
        existingNotifications[i] = reminder;
        break;
      }
    }

    JsonEncoder jsonEncoder = JsonEncoder.withIndent("  ");

    return await file.writeAsString(
      jsonEncoder.convert(
        existingNotifications.map((value) => value.toMap()).toList(),
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
    JsonEncoder jsonEncoder = JsonEncoder.withIndent("  ");
    return file.writeAsString(
      jsonEncoder.convert(caches.map((cache) => cache.toMap()).toList()),
    );
  }

  static Future<File> reorderCachesByIds(String from, String to) async {
    File file = await _localFile(
      fileDestinationType: FileDestinationType.cache,
    );
    List<Cache> caches = await readCaches();
    int fromIndex = caches.indexWhere((cache) => cache.id == from);
    int toIndex = caches.indexWhere((cache) => cache.id == to);
    Cache fromCache = caches.removeAt(fromIndex);
    caches.insert(toIndex, fromCache);
    JsonEncoder jsonEncoder = JsonEncoder.withIndent("  ");
    return file.writeAsString(
      jsonEncoder.convert(caches.map((cache) => cache.toMap()).toList()),
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
    JsonEncoder jsonEncoder = JsonEncoder.withIndent("  ");
    return file.writeAsString(
      jsonEncoder.convert(statuses.map((status) => status.toMap()).toList()),
    );
  }

  static Future<File> reorderNotification(int from, int to) async {
    File file = await _localFile(
      fileDestinationType: FileDestinationType.reminder,
    );
    List<ICReminder> notifications = await readReminders();
    if (from < to) {
      to -= 1;
    }
    final ICReminder item = notifications.removeAt(from);
    notifications.insert(to, item);
    JsonEncoder jsonEncoder = JsonEncoder.withIndent("  ");
    return file.writeAsString(
      jsonEncoder.convert(
        notifications.map((status) => status.toMap()).toList(),
      ),
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
    //Remove all the statutoMapciated with this cache
    List<ICStatus> statuses = await readStatus();
    for (int i = 0; i < statuses.length; i++) {
      if (statuses[i].cacheId == cacheId) {
        await deleteStatusById(statuses[i].id);
      }
    }
    //Delete all the cacheBlock related
    deleteBlocksByCacheId(cacheId);
    JsonEncoder jsonEncoder = JsonEncoder.withIndent("  ");
    return file.writeAsString(
      jsonEncoder.convert(
        existingCaches.map((value) => value.toMap()).toList(),
      ),
    );
  }

  static Future<File> deleteBlocksByCacheId(String cacheId) async {
    final File file = await _localFile(
      fileDestinationType: FileDestinationType.block,
    );
    List<ICBlock> existingBlocks = await readBlocks();
    List<ICBlock> newBlocks = List.empty(growable: true);
    for (int i = 0; i < existingBlocks.length; i++) {
      if (existingBlocks[i].cacheId != cacheId) {
        newBlocks.add(existingBlocks[i]);
      }
    }
    JsonEncoder jsonEncoder = JsonEncoder.withIndent("  ");
    return file.writeAsString(
      jsonEncoder.convert(newBlocks.map((value) => value.toMap()).toList()),
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
    JsonEncoder jsonEncoder = JsonEncoder.withIndent("  ");
    return file.writeAsString(
      jsonEncoder.convert(
        existingBlocks.map((value) => value.toMap()).toList(),
      ),
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
    JsonEncoder jsonEncoder = JsonEncoder.withIndent("  ");
    return file.writeAsString(
      jsonEncoder.convert(
        existingStatuses.map((value) => value.toMap()).toList(),
      ),
    );
  }

  static Future<File> deleteReminderById(String notificationId) async {
    final File file = await _localFile(
      fileDestinationType: FileDestinationType.reminder,
    );
    final ICReminder? reminder = await findReminderById(notificationId);
    List<ICReminder> existingNotifications = await readReminders();
    if (reminder == null) {
      return file;
    }

    for (int i = 0; i < existingNotifications.length; i++) {
      if (existingNotifications[i].id == notificationId) {
        existingNotifications.removeAt(i);
        break;
      }
    }

    for (int i = 0; i < existingNotifications.length; i++) {
      if (existingNotifications[i].cacheId == notificationId) {
        await deleteStatusById(existingNotifications[i].id);
      }
    }
    JsonEncoder jsonEncoder = JsonEncoder.withIndent("  ");
    return file.writeAsString(
      jsonEncoder.convert(
        existingNotifications.map((value) => value.toMap()).toList(),
      ),
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
    Cache? cache = await findCacheById(cacheId);
    List<ICBlock>? unorderedBlocks = List.empty(growable: true);
    List<ICBlock>? orderedblocks = List.empty(growable: true);
    List<ICBlock>? readblocks = await readBlocks();

    if (cache == null) {
      throw Exception("findBlocksByCacheId: cache is null");
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

  static Future<ICReminder?> findReminderById(String id) async {
    List<ICReminder>? reminders = await readReminders();
    for (int i = 0; i < reminders.length; i++) {
      if (reminders[i].id == id) {
        return reminders[i];
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
              .map((json) => Cache.fromMap(json as Map<String, dynamic>))
              .toList();
        }
      }
    } catch (e) {
      log('Error reading caches: $e');
    }
    return []; // Return empty list if file doesn't exist, is empty, or has invalid JSON
  }

  static Future<List<ICBlock>> readBlocks({String? dataString}) async {
    if (dataString != null && dataString.isNotEmpty) {
      final List<dynamic> jsonList = jsonDecode(dataString) as List<dynamic>;
      // The list Hold list of all blocks existing, and map each of the entry to Map<String, dynamic> jsonList
      jsonList
          .map((json) => ICBlock.fromMap(json as Map<String, dynamic>))
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
              .map((json) => ICBlock.fromMap(json as Map<String, dynamic>))
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
          .map((json) => ICStatus.fromMap(json as Map<String, dynamic>))
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
              .map((json) => ICStatus.fromMap(json as Map<String, dynamic>))
              .toList();
        }
      }
    } catch (e) {
      log('Error reading blocks: $e');
    }
    return []; // Return empty list if file doesn't exist, is empty, or has invalid JSON
  }

  static Future<List<ICReminder>> readReminders({String? dataString}) async {
    if (dataString != null && dataString.isNotEmpty) {
      final List<dynamic> jsonList = jsonDecode(dataString) as List<dynamic>;
      // The list Hold list of all blocks existing, and map each of the entry to Map<String, dynamic>
      return jsonList
          .map((json) => ICReminder.fromMap(json as Map<String, dynamic>))
          .toList();
    }
    final File file = await _localFile(
      fileDestinationType: FileDestinationType.reminder,
    );
    try {
      if (await file.exists()) {
        final String content = await file.readAsString();
        if (content.isNotEmpty) {
          final List<dynamic> jsonList = jsonDecode(content) as List<dynamic>;

          return jsonList
              .map((json) => ICReminder.fromMap(json as Map<String, dynamic>))
              .toList();
        }
      }
    } catch (e) {
      log('Error reading notifications: $e');
    }
    return []; // Return empty list if file doesn't exist, is empty, or has invalid JSON
  }
}
