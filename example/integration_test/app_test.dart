import 'package:flutter_app_cache/flutter_app_cache.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('create root folder for app', (WidgetTester tester) async {
    String? path =
        await FlutterAppCache.instance?.initAppCache(app: 'quochuynh');
    expect(true, path != null);
    expect('quochuynh', path!.split('/').last);
  });

  testWidgets('create subfolder from root', (WidgetTester tester) async {
    List<String>? folders =
        await FlutterAppCache.instance?.createFolder(folders: [
      'videos',
      'images',
      'synchronized',
    ]);
    expect(true, folders != null);
    expect(3, folders!.length);
    expect('videos', folders[0]);
  });
  testWidgets('count file in videos folder', (WidgetTester tester) async {
    int? count = await FlutterAppCache.instance
        ?.count(folderPath: FlutterAppCache.instance!.appDirPath! + '/videos');
    expect(true, count != null);
    expect(0, count!);
  });

  testWidgets('count file in images folder', (WidgetTester tester) async {
    int? count = await FlutterAppCache.instance
        ?.count(folderPath: FlutterAppCache.instance!.appDirPath! + '/images');
    expect(true, count != null);
    expect(0, count!);
  });

  testWidgets('copy file from another file path', (WidgetTester tester) async {
    List<String>? writeFileResult = await FlutterAppCache.instance?.writeFile(
      filePaths: [
        '/storage/emulated/0/Android/data/com.example.example/files/quochuynh/videos/REC8499496126340864983.mp4'
      ],
      subFolder: 'images',
    );
    expect(true, writeFileResult != null);
  });

  testWidgets('count file in images folder after write',
      (WidgetTester tester) async {
    int? count = await FlutterAppCache.instance
        ?.count(folderPath: FlutterAppCache.instance!.appDirPath! + '/images');
    expect(true, count != null);
    expect(1, count!);
  });

}
