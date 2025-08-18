import 'dart:developer';
import 'dart:io' show Platform;

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

enum DataBaseDestinationType { cache, block, setting, status }

class DataBaseHandler {
  static late final Database blockDB;
  static late final Database cacheDB;
  static late final Database statusDB;
  static Future<void> init() async {
    // Initialize sqflite_ffi for desktop
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }
    log(join(await getDatabasesPath(), "blocks.db"));
    blockDB = await openDatabase(
      join(await getDatabasesPath(), "blocks.db"),
      version: 1,
      onCreate: (db, version) {
        return db.execute("""
          CREATE TABLE IF NOT EXISTS blocks(
            id TEXT PRIMARY KEY,
            cacheId TEXT NOT NULL,
            statusId TEXT DEFAULT "",
            name TEXT DEFAULT NOT NULL,
            content TEXT DEFAULT ""
          )
        """);
      },
    );
  }
}
