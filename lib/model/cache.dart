import 'dart:developer';
import 'dart:io';
import 'dart:convert';
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

  // File I/O
  static Future<String> _localPath() async {
    final Directory directory = await getApplicationDocumentsDirectory();
    log(directory.toString());
    return directory.path;
  }

  static Future<File> _localFile() async {
    final path = await _localPath();
    return File("$path/counter.txt");
  }

  static Future<File> writeCounter(int counter) async {
    final file = await _localFile();
    return file.writeAsString('$counter');
  }

  static Future<int> readCounter() async {
    try {
      final File file = await _localFile();

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
