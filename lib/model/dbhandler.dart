import 'dart:developer';
import 'dart:io' show Platform;

import 'package:idea_cache/model/notification.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

enum DataBaseDestinationType { cache, block, setting, status, notification }

class DataBaseHandler {
  static final DataBaseHandler _instance = DataBaseHandler._internal();
  static Database? _cacheDB;
  static Database? _blockDB;
  static Database? _notificationDB;
  static Database? _statusDB;
  // Dart will not generate any constuctor since one is defined here
  DataBaseHandler._internal();
  // Public Factory for returning the singleton
  factory DataBaseHandler() {
    return _instance;
  }
  // Getter
  Future<Database> get cacheDB async {
    if (_cacheDB == null) {
      await initDB();
    }
    return _cacheDB!;
  }

  Future<Database> get blockDB async {
    if (_blockDB == null) {
      await initDB();
    }
    return _blockDB!;
  }

  Future<Database> get notificationDB async {
    if (_notificationDB == null) {
      await initDB();
    }
    return _notificationDB!;
  }

  Future<Database> get statusDB async {
    if (_statusDB == null) {
      await initDB();
    }
    return _statusDB!;
  }

  // The only DB init you need
  static Future<void> initDB() async {
    // Initialize sqflite_ffi for desktop
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }
    log(await getDatabasesPath());
    _cacheDB = await openDatabase(
      join(await getDatabasesPath(), "notifications.db"),
      version: 1,
      onCreate: (db, version) {
        return db.execute("""
          CREATE TABLE caches(
            id TEXT PRIMARY KEY,
            blockId TEXT NOT NULL,
            status INTEGER NOT NULL,
            title TEXT NOT NULL,
            description TEXT NOT NULL,
            time INTEGER NOT NULL
          )
        """);
      },
    );
    _notificationDB = await openDatabase(
      join(await getDatabasesPath(), "notifications.db"),
      version: 1,
      onCreate: (db, version) {
        return db.execute("""
          CREATE TABLE notifications(
            id TEXT PRIMARY KEY,
            blockId TEXT NOT NULL,
            status INTEGER NOT NULL,
            title TEXT NOT NULL,
            description TEXT NOT NULL,
            time INTEGER NOT NULL
          )
        """);
      },
    );
  }

  Future<List<ICNotification>> getNotifications() async {
    final db = _notificationDB;
    final List<Map<String, dynamic>> maps = await db!.query('notifications');
    return List.generate(maps.length, (i) => ICNotification.fromMap(maps[i]));
  }

  // Return int ID
  Future<int> insertNotification(ICNotification item) async {
    final db = _notificationDB;
    return await db!.insert("notifications", item.toMap());
  }

  Future<int> deleteNotification(String id) async {
    final db = _notificationDB;
    return await db!.delete("notifications", where: "id = ?", whereArgs: [id]);
  }
}
