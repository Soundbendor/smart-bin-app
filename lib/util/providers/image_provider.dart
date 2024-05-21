// Flutter imports:
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';

// Package imports:
import 'package:path_provider/path_provider.dart';
import 'package:archive/archive_io.dart';

// Project imports:
import 'package:binsight_ai/util/print.dart';

class ImageNotifier extends ChangeNotifier {
  Future<void> saveAndExtract(String zipData) async {
    Uint8List bytes = Uint8List.fromList(zipData.codeUnits);
    Directory tempDir = await getTemporaryDirectory();
    Directory appDocDir = await getApplicationDocumentsDirectory();
    String tempPath = '${tempDir.path}/temp.zip';
    await File(tempPath).writeAsBytes(bytes);
    Archive archive =
        ZipDecoder().decodeBytes(File(tempPath).readAsBytesSync());
    for (ArchiveFile file in archive) {
      String fileName = '${appDocDir.path}/${file.name}';
      File(fileName)
        ..createSync(recursive: true)
        ..writeAsBytesSync(file.content);
      debug('Extracted file: $fileName');
    }
    debug("'Directory: ${appDocDir.path}");
    File(tempPath).deleteSync();

    notifyListeners();
  }
}
