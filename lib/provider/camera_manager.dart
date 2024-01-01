import 'package:camera/camera.dart';

class CameraManager {
  // Declare your camera list here
  List<CameraDescription> _cameras = <CameraDescription>[];

  // Constructor
  CameraManager._privateConstructor();

  // initialise instance
  static final CameraManager instance =
      CameraManager._privateConstructor();

  // Add a getter to access camera list
  List<CameraDescription> get cameras => _cameras;

  // Init method
  init() async {
    try {
      _cameras = await availableCameras();
    } on CameraException catch (e) {
      print(e);
    }
  }
}
