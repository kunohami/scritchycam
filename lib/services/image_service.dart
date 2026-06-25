import 'dart:io';
import 'package:image_picker/image_picker.dart';

class ImageService {
  static final _picker = ImagePicker();

  static Future<File?> pickFromGallery() async {
    final result = await _picker.pickImage(source: ImageSource.gallery);
    if (result == null) return null;
    return File(result.path);
  }
}
