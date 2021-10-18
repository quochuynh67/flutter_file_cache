library flutter_app_cache;

import 'dart:io';

import 'package:flutter_app_cache/db/file_db_manager.dart';
import 'package:flutter_app_cache/handler.dart';
import 'package:path_provider/path_provider.dart';

class FlutterAppCache extends IFileHandler {
  ///
  /// Make sure this class initialized
  bool _initialized = false;

  ///
  /// Keep file in N day (unit: day)
  ///
  /// default 30
  int _day = 30;

  ///
  /// Keep root path
  String? _appDirPath;

  void _assert() {
    assert(_initialized != false,
        'Need to call FlutterAppCache.instance?.initAppCache().');
  }

  bool isDirectoryExist(String path) => Directory(path).existsSync();

  ///
  /// Root path
  String? get appDirPath => _appDirPath;

  ///
  /// Example:
  ///
  /// FlutterAppCache.instance?.initAppCache(app: 'VideoMonster')
  @override
  Future<String?> initAppCache({
    required String app,
    int day = 30,
    String dbName = 'video_monster_caching',
  }) async {
    try {
      Directory? appDir = await getExternalStorageDirectory();
      if (appDir != null) {
        String pathToApp = appDir.path + '/' + app;
        Directory appFolder = Directory(pathToApp);

        _appDirPath = (await appFolder.create()).path;
        _initialized = true;
        _day = day;

        await DBFileManager.instance?.initDB(dbName: dbName);
        return _appDirPath;
      }
      throw 'Creating app cache folder was not finished yet.';
    } catch (e) {
      rethrow;
    }
  }

  ///
  /// Example:
  ///
  ///  FlutterAppCache.instance?.count(folderPath: value)
  @override
  Future<int> count({required String folderPath}) async {
    _assert();
    if (isDirectoryExist(folderPath)) {
      Directory dir = Directory(folderPath);
      return dir.listSync().length;
    } else {
      throw '$folderPath folder does not exists';
    }
  }

  ///
  /// Example:
  ///
  /// FlutterAppCache.instance?.createFolder(
  ///      folders: ['child1', 'child2', 'child3'],
  ///      parentPath: 'hbq1')
  @override
  Future<List<String>> createFolder({
    required List<String> folders,
    String parentPath = '',
  }) async {
    _assert();
    List<String> output = [];

    if (_appDirPath != null) {
      if (parentPath.isNotEmpty) {
        parentPath += '/';
      }
      await Future.wait(folders.map((e) {
        return Directory(_appDirPath! + '/' + parentPath + e).create();
      })).then((value) {
        output = value.map((e) => e.path).toList();
      }, onError: (e) {
        throw 'Error when create the folder $e';
      });
    }

    return output;
  }

  @override
  Future<List<String>> writeFile({
    required List<String> filePaths,
    required String subFolder,
  }) async {
    _assert();
    List<String> output = [];

    await Future.wait(filePaths.map((e) {
      return File(e)
          .copy(_appDirPath! + '/' + subFolder + '/' + e.split('/').last);
    })).then((value) async {
      output = value.map((e) => e.path).toList();
      //save to db
      await DBFileManager.instance?.saveFile(
        files: output,
        day: _day,
      );
    }, onError: (e) {
      throw 'Error when create the files $e';
    });
    return output;
  }

  @override
  Future<List<String>> deleteFile({required List<String> filePaths}) async {
    _assert();
    List<String> output = [];

    await Future.wait(filePaths.map((e) => File(e).delete())).then((value) {
      output = value.map((e) => e.path).toList();
    }, onError: (e) {
      throw 'Error when delete the files $e';
    });
    return output;
  }

  @override
  Future<List<String>> deleteFolder({required List<String> folders}) async {
    _assert();
    List<String> output = [];

    if (_appDirPath != null) {
      await Future.wait(folders.map((e) => Directory(e).delete())).then(
          (value) {
        output = value.map((e) => e.path).toList();
      }, onError: (e) {
        throw 'Error when delete the folder $e';
      });
    }

    return output;
  }

  Future<void> clearAppCache() async {
    try {
      await DBFileManager.instance?.deleteDBPath();
      if (_appDirPath != null) {
        await Directory(_appDirPath!).delete(recursive: true);
      }
    } catch (e) {
      throw 'clearAppCache error: $e';
    }
  }

  /// *********************** Generated constructor ************************ ///

  FlutterAppCache._();

  static FlutterAppCache? _instance;

  static FlutterAppCache? get instance {
    _instance ??= FlutterAppCache._();
    return _instance;
  }

  /// *********************** Generated constructor ************************ ///
}
