abstract class IFileHandler {
  ///
  /// Init app folder to manage file easily
  Future<String?> initAppCache({
    required String app,
    int day,
  });

  ///
  /// Create a folder to your application local storage
  ///
  /// [folderName] List String of folder name
  ///
  /// if create one folder, provider array with one string, else provide string list
  ///
  /// return List<String> list of success folder created
  Future<List<String>> createFolder({
    required List<String> folders,
    required String parentPath,
  });

  Future<List<String>> deleteFolder({required List<String> folders});

  ///
  /// Write multiple/one file to folder
  ///
  /// [folderPath] the path to the folder where store the files [filePaths]
  Future<List<String>> writeFile({
    required List<String> filePaths,
    required String subFolder,
  });

  Future<List<String>> deleteFile({required List<String> filePaths});

  ///
  /// Count the number of file in a folder
  ///
  /// [folderPath] the path of folder
  Future<int> count({
    required String folderPath,
  });
}
