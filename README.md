Flutter file cache

This is my own file cache and manager in Flutter, It not suitable for all project.

This only simple serve for my project!

### Support
- [X] cache file to your app folder
- [X] create sub folder
- [X] set expired day for the file
- [x] mark file is sync or not
- [X] write/copy file from file path (in case of camera recorder, camera take picture, download image. These case will save on itself so we need to copy to our app folder to manage easily)
- [X] delete files and delete in cache after sync/expired


### Usage
###### Create root folder
To create the root folder, by call:
```dart
String? path = await FlutterAppCache.instance?.initAppCache(app: 'quochuynh');

print('path: $path');

/// Output
path: "/storage/emulated/0/Android/data/com.example.example/files/quochuynh/"
```

###### Create sub folder from root
To create sub folder from root, by call:
```dart
List<String>? folders = await FlutterAppCache.instance?.createFolder(folders: [
            'videos',
            'images',
            'synchronized',
          ]);
print(folders);

/// Output
[
/storage/emulated/0/Android/data/com.example.example/files/quochuynh/videos/,
/storage/emulated/0/Android/data/com.example.example/files/quochuynh/images/,
/storage/emulated/0/Android/data/com.example.example/files/quochuynh/synchronized,
]
```

###### Write/copy file from another file path (after record camera, take picture, download from network but in save in another place)
To write/copy file to app folder, by call:
```dart
List<String>? writeFileResult = await FlutterAppCache.instance?.writeFile(
         filePaths: [value.path],
         subFolder: 'videos',
         );
debugPrint('$writeFileResult');

/// Output
[
/storage/emulated/0/Android/data/com.example.example/files/quochuynh/videos/REC8499496126340864983.mp4,
/storage/emulated/0/Android/data/com.example.example/files/quochuynh/videos/REC8152775761166081192.mp4,
/storage/emulated/0/Android/data/com.example.example/files/quochuynh/videos/REC8755270808040118239.mp4,
]
```

### Count file in the folder
To count file in a folder, by call:
```dart
int = await FlutterAppCache.instance?.count(
      folderPath: FlutterAppCache.instance!.appDirPath! + '/videos');

debugPrint('video count: $count');

/// Output
video count: 3
```


### Checking files are expired
To check expired files, by call:
- `safeDelete`: `true` when you want to delete the record in database, else It just return the list of expired file. Then you can do anything with this list
- `targetDate`: the date to filter that which file are exceeded

```dart
List<Map>? expiredFile = await DBFileManager.instance?.checkExpire(safeDelete: true);

debugPrint('expiredFile: ${expiredFile?.length}');
debugPrint('expiredFile: $expiredFile');
```

### Deleting expired file and delete in database
To delete file and delete in database, by call:
- `filePaths`: List file path you got in function `checkExpire()` above.
```dart
List<String>? deleteFileResult = await FlutterAppCache.instance?.deleteFile(
                     filePaths: expiredFile!
                         .map((e) => e['filePath'].toString())
                         .toList());
debugPrint('deleteFileResult:::::$deleteFileResult');
```

### Sync files to cloud and update local database
To sync, by call:
- if you pass argument for this function, it will handle the input argument, else it will get the data from database automatically
```dart
List<Map>? syncFileToCloud = await DBFileManager.instance?.synchronizeFile();
debugPrint('syncFileToCloud: ${syncFileToCloud?.length}');
debugPrint('syncFileToCloud: $syncFileToCloud');
```

### Logout! Clear file, clear data, clear all.
To clear, by call:
```dart
FlutterAppCache.instance?.clearAppCache().then((value) {
  debugPrint('Main clearAppcache success');
}, onError: (e) {
  debugPrint('Main clearAppcache error: $e');
});
```


### Integration test
To integration test in example, by run:
```
flutter test integration_test/app_test.dart
```