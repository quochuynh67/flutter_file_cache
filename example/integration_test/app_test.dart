import 'dart:io';

import 'package:flutter_app_cache/flutter_app_cache.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:path_provider/path_provider.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  test('create root folder for app', () async {
    String? path =
        await FlutterAppCache.instance?.initAppCache(app: 'quochuynh');
    expect(true, path != null);
    expect('quochuynh', path!.split('/').last);
  });

  test('create subfolder from root', () async {
    List<String>? folders =
        await FlutterAppCache.instance?.createFolder(folders: [
      'videos',
      'images',
      'synchronized',
    ]);
    expect(true, folders != null);
    expect(3, folders!.length);
    expect('videos', folders[0].split('/').last);
  });
  test('count file in videos folder', () async {
    int? count = await FlutterAppCache.instance
        ?.count(folderPath: FlutterAppCache.instance!.appDirPath! + '/videos');
    expect(true, count != null);
    expect(0, count!);
  });

  test('count file in images folder', () async {
    int? count = await FlutterAppCache.instance
        ?.count(folderPath: FlutterAppCache.instance!.appDirPath! + '/images');
    expect(true, count != null);
    expect(0, count!);
  });

  group('write file and count again', () {
    test('copy file from another file path', () async {
      final Directory directory = await getApplicationDocumentsDirectory();
      final File file = File('${directory.path}/my_file.txt');
      await file.writeAsString('huynhbaoquoc');
      List<String>? writeFileResult = await FlutterAppCache.instance?.writeFile(
        filePaths: [file.path],
        subFolder: 'images',
      );
      expect(true, writeFileResult != null);
    });

    test('count file in images folder after write', () async {
      int? count = await FlutterAppCache.instance?.count(
          folderPath: FlutterAppCache.instance!.appDirPath! + '/images');
      expect(true, count != null);
      expect(1, count!);
    });
  });
}
