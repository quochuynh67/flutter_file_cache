import 'dart:async';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter_app_cache/db/file_db_manager.dart';
import 'package:flutter_app_cache/flutter_app_cache.dart';

List<CameraDescription>? cameras;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  cameras = await availableCameras();
  runApp(const CameraApp());
}

class CameraApp extends StatefulWidget {
  const CameraApp({Key? key}) : super(key: key);

  @override
  _CameraAppState createState() => _CameraAppState();
}

class _CameraAppState extends State<CameraApp> {
  CameraController? controller;

  @override
  void initState() {
    super.initState();
    controller = CameraController(cameras![1], ResolutionPreset.max);
    controller?.initialize().then((_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _testRecord();
      });
    });
  }

  _testRecord() async {
    debugPrint('startVideoRecording...');

    await controller?.startVideoRecording();

    Future.delayed(const Duration(seconds: 5), () {
      controller?.stopVideoRecording().then((value) async {
        debugPrint('stopVideoRecording success: ${value.path}');

        // create app cache folder
        String? path =
            await FlutterAppCache.instance?.initAppCache(app: 'hbq_cache');

        // create folders inside
        if (path != null) {
          List<String>? folders =
              await FlutterAppCache.instance?.createFolder(folders: [
            'videos',
            'images',
            'synchronized',
            'un_synchronized',
          ]);

          if (folders != null && folders.isNotEmpty) {
            ///
            /// Write file and cache to database
            ///
            // List<String>? writeFileResult = await FlutterAppCache.instance
            //     ?.writeFile(filePaths: [value.path], subFolder: 'videos');
            // debugPrint('writeFileResult:::::$writeFileResult');

            ///
            /// count file
            ///
            int? count = await FlutterAppCache.instance?.count(
                folderPath: FlutterAppCache.instance!.appDirPath! + '/videos');

            debugPrint('video count: $count');

            ///
            /// check expire
            ///
            // List<Map>? expiredFile =
            //     await DBFileManager.instance?.checkExpire(safeDelete: true);
            // debugPrint('expiredFile: ${expiredFile?.length}');
            // debugPrint('expiredFile: $expiredFile');

            ///
            /// check expire
            ///
            List<Map>? syncFileToCloud =
                await DBFileManager.instance?.synchronizeFile();
            debugPrint('syncFileToCloud: ${syncFileToCloud?.length}');
            debugPrint('syncFileToCloud: $syncFileToCloud');

            ///
            /// delete expired
            ///
            // List<String>? deleteFileResult = await FlutterAppCache.instance
            //     ?.deleteFile(
            //         filePaths: expiredFile!
            //             .map((e) => e['filePath'].toString())
            //             .toList());
            // debugPrint('deleteFileResult:::::$deleteFileResult');
          }
        }
      }, onError: (e) {
        debugPrint('stopVideoRecording error: $e');
      });
    });

    // await FlutterAppCache.instance?.initAppCache(app: 'hbq_cache');
    // FlutterAppCache.instance?.clearAppCache().then((value) {
    //   debugPrint('Main clearAppcache success');
    // }, onError: (e) {
    //   debugPrint('Main clearAppcache error: $e');
    // });
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!controller!.value.isInitialized) {
      return Container();
    }
    return MaterialApp(
      home: CameraPreview(controller!),
    );
  }
}
