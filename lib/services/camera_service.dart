import 'package:camera/camera.dart';

class CameraService {
  static Future<List<CameraDescription>> getAvailableCameras() {
    return availableCameras();
  }

  static CameraController createController(
    CameraDescription camera, {
    // High resolution balances quality and performance for a live preview use case
    ResolutionPreset resolution = ResolutionPreset.high,
  }) {
    return CameraController(
      camera,
      resolution,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.jpeg,
    );
  }
}
