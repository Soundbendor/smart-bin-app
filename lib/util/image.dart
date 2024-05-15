import 'dart:io';

File? getImage(String image, Directory? appDocDir) {
  if (appDocDir != null) {
    String imagePath = '${appDocDir.path}/$image';
    File imageFile = File(imagePath);
    if (imageFile.existsSync()) {
      return imageFile;
    } else {
      return null;
    }
  } else {
    return null;
  }
}
