import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DBFileManager {
  Database? _db;
  String? _databasePath;

  static const String tbAppFileManager = 'AppFileManager';
  static const String _fieldExpiredDay = 'expireDay';

  ///
  /// Flag to check that this record was sync or not
  static const String _fieldSynchronized = 'synchronized';

  ///
  /// File path on mobile device
  static const String _fieldFilePath = 'filePath';

  Future<void> initDB({
    required String dbName,
    bool devMode = true,
    int version = 1,
  }) async {
    var databasesPath = await getDatabasesPath();
    _databasePath = join(databasesPath, '$dbName.db');

    _db = await openDatabase(_databasePath!, version: version,
        onCreate: (Database db, int version) async {
      await db.execute('CREATE TABLE $tbAppFileManager'
          ' ('
          'id INTEGER PRIMARY KEY,'
          '$_fieldFilePath TEXT,'
          '$_fieldSynchronized INTEGER,'
          '$_fieldExpiredDay INTEGER'
          ')');
    });

    if (devMode) {
      Sqflite.setDebugModeOn(devMode);
      debugPrint('${await _db?.query(tbAppFileManager)}');
    }
  }

  ///
  /// Save list of file path to database
  ///
  /// [files] file paths
  /// [day] number of day these file will live from the time it was saved
  ///
  /// return List of file save successfully
  Future<List<Map>> saveFile({
    required List<String> files,
    required int day,
  }) async {
    List<Map> output = [];
    await _db?.transaction((txn) async {
      for (String f in files) {
        try {
          int expireDay =
              // DateTime.now().add(Duration(days: day)).millisecondsSinceEpoch;
          DateTime.now().add(Duration(seconds: day)).millisecondsSinceEpoch;
          int v = await txn.rawInsert('INSERT INTO '
              '$tbAppFileManager($_fieldFilePath,$_fieldSynchronized, $_fieldExpiredDay)'
              ' VALUES("$f", 0 , $expireDay)');
          output.add({
            'id': v,
            _fieldFilePath: f,
            _fieldSynchronized: 0,
            _fieldExpiredDay: expireDay,
          });
        } catch (e) {
          debugPrint('DBFileManager:::saveFile:::$f failed cuz $e');
        }
      }
    });
    return output;
  }

  ///
  /// Check expired file
  ///
  /// [targetDate] Target date to check expire after
  /// [safeDelete] if you want to delete those record in database
  ///
  /// return List of expired file record
  Future<List<Map>> checkExpire({
    DateTime? targetDate,
    bool safeDelete = false,
  }) async {
    targetDate ??= DateTime.now();
    List<Map> output = [];
    List<Map>? list = await _db?.query(
      tbAppFileManager,
      where: '$_fieldExpiredDay > ?',
      whereArgs: ['${targetDate.millisecondsSinceEpoch}'],
    );
    if (safeDelete) {
      await _db?.rawDelete(
          'DELETE FROM $tbAppFileManager WHERE $_fieldExpiredDay > ?',
          ['${targetDate.millisecondsSinceEpoch}']);
    }

    output = list?.map((e) => e).toList() ?? [];
    return output;
  }

  ///
  /// Get un-sync file and not expired
  /// return List of un-synchronized file in database
  Future<List<Map>> getUnSynchronizedFile() async {
    List<Map> output = [];
    List<Map>? list = await _db?.query(
      tbAppFileManager,
      where: '$_fieldSynchronized = ? AND $_fieldExpiredDay > ?',
      whereArgs: ['0', DateTime.now().millisecondsSinceEpoch],
    );

    output = list?.map((e) => e).toList() ?? [];
    return output;
  }

  Future<List<Map>> synchronizeFile({List<Map>? files}) async {
    List<Map> output = [];
    files ??= await getUnSynchronizedFile();
    if (files.isEmpty) {
      return [];
    }
    await _db?.transaction((txn) async {
      for (Map f in files!) {
        try {
          // update flag for synchronized column to 1 by record id
          int v = await txn.rawUpdate(
              'UPDATE $tbAppFileManager SET $_fieldSynchronized = ? WHERE id =?',
              ['1', '${f['id']}']);

          // map data
          output.add({
            'id': v,
            _fieldFilePath: f['filePath'],
            _fieldSynchronized: 1,
          });
        } catch (e) {
          debugPrint('DBFileManager:::synchronizeFile:::$f failed cuz $e');
        }
      }
    });
    return output;
    return output;
  }

  Future<void> closeDB() async => await _db?.close();

  Future<void> deleteDBPath() async {
    if (_databasePath != null) {
      await deleteDatabase(_databasePath!);
    }
  }

  /// *********************** Generated constructor ************************ ///
  DBFileManager._();

  static DBFileManager? get instance {
    _instance ??= DBFileManager._();
    return _instance;
  }

  static DBFileManager? _instance;

  /// *********************** Generated constructor ************************ ///
}
