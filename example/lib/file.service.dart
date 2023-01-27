import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

class FileService {
  static Future<String> getPath() async {
    Directory appDocDir = await getApplicationDocumentsDirectory();
    return appDocDir.path;
  }

  static Future<void> loadFileToTemp(List<String> filenames) async {
    for (var filename in filenames) {
      var bytes = await rootBundle.load("assets/$filename");
      String path = await getPath();
      await FileService.writeToFile(bytes, '$path/$filename');
    }
  }

//write to app path
  static Future<void> writeToFile(ByteData data, String path) {
    final buffer = data.buffer;
    return new File(path).writeAsBytes(
        buffer.asUint8List(data.offsetInBytes, data.lengthInBytes));
  }
}
