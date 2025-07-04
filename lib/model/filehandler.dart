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
    required String filename,
  }) async {
    final String path = await _localPath();
    switch (fileDestinationType) {
      case FileDestinationType.cache:
        return File("$path/$filename.txt");
      case FileDestinationType.block:
        return File("$path/$filename.txt");
    }
  }

  static Future<File> writeCache(Cache cache) async {
    final File file = await _localFile(
      fileDestinationType: FileDestinationType.cache,
      filename: cache.name,
    );
    return file.writeAsString(jsonEncode(cache.toJson()));
  }

  static Future<File> writeCounter({
    required FileDestinationType fileDestinationType,
    required String filename,
  }) async {
    final file = await _localFile(
      fileDestinationType: fileDestinationType,
      filename: filename,
    );
    return file.writeAsString('987');
  }

  static Future<int> readCounter({
    required FileDestinationType fileDestinationType,
    required String filename,
  }) async {
    try {
      final File file = await _localFile(
        fileDestinationType: fileDestinationType,
        filename: filename,
      );

      // Read the file
      final String contents = await file.readAsString();
      log(contents, name: "Cache.readCounter()");
      return int.parse(contents);
    } catch (e) {
      // If encountering an error, return 0
      return 0;
    }
  }
}
