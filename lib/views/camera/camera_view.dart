import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import '/provider/camera_manager.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import '/views/camera/camera_overlay.dart';

// A screen that allows users to take a picture using a given camera.
class TakePictureScreen extends StatefulWidget {
  const TakePictureScreen({Key? key}) : super(key: key);

  @override
  TakePictureScreenState createState() => TakePictureScreenState();
}

class TakePictureScreenState extends State<TakePictureScreen>
    with WidgetsBindingObserver {
  CameraController? _controller;
  bool _isCameraInitialized = false;
  FlashMode? _currentFlashMode;

  Future resetTorch() async {
      final currentFlash = _controller?.value.flashMode;
      if (currentFlash != null && currentFlash != FlashMode.off) {
        if (currentFlash == FlashMode.auto || currentFlash == FlashMode.always) {
          await _controller!.setFlashMode(FlashMode.torch);
        }
        await _controller!.setFlashMode(FlashMode.off);
        await _controller!.setFlashMode(currentFlash);
      }
  }

  void onNewCameraSelected(CameraDescription cameraDescription) async {
    final previousCameraController = _controller;
    // Instantiating the camera controller
    final CameraController cameraController = CameraController(
      cameraDescription,
      ResolutionPreset.high,
      imageFormatGroup: ImageFormatGroup.jpeg,
    );

    // Dispose the previous controller
    await previousCameraController?.dispose();

    // Replace with the new controller
    if (mounted) {
      setState(() {
        _controller = cameraController;
      });
    }

    // Update UI if controller updated
    cameraController.addListener(() {
      if (mounted) setState(() {});
    });

    // _currentFlashMode = _controller!.value.flashMode;
    _currentFlashMode = FlashMode.off;
    // Initialize controller
    try {
      await cameraController.initialize();
    } on CameraException catch (e) {
      print('Error initializing camera: $e');
    }

    // Update the Boolean
    if (mounted) {
      setState(() {
        _isCameraInitialized = _controller!.value.isInitialized;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    onNewCameraSelected(CameraManager.instance.cameras[0]);
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final CameraController? cameraController = _controller;

    // App state changed before we got the chance to initialize.
    if (cameraController == null || !cameraController.value.isInitialized) {
      return;
    }

    if (state == AppLifecycleState.inactive) {
      cameraController.dispose();
    } else if (state == AppLifecycleState.resumed) {
      onNewCameraSelected(cameraController.description);
    }
  }

  Future<XFile?> takePicture() async {
    final CameraController? cameraController = _controller;
    if (cameraController!.value.isTakingPicture) {
      // A capture is already pending, do nothing.
      return null;
    }
    try {
      XFile file = await cameraController.takePicture();
      cameraController.setFlashMode(FlashMode.off);
      return file;
    } on CameraException catch (e) {
      print('Error occured while taking picture: $e');
      return null;
    }
  }

  void _showCameraException(CameraException e) {
    showInSnackBar('Error: ${e.code}\n${e.description}');
  }

  void showInSnackBar(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

Future<void> setFlashMode(FlashMode mode) async {
    if (_controller == null) {
      return;
    }

    try {
      await _controller!.setFlashMode(mode);
    } on CameraException catch (e) {
      _showCameraException(e);
      rethrow;
    }
  }

  void onSetFlashModeButtonPressed(FlashMode mode) {
    setFlashMode(mode).then((_) {
      if (mounted) {
        setState(() {});
      }
      showInSnackBar('Flash mode set to ${mode.toString().split('.').last}');
    });
  }




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(title: const Text('Take a Picture')),
      backgroundColor: Colors.black,
      // You must wait until the controller is initialized before displaying the
      // camera preview. Use a FutureBuilder to display a loading spinner until the
      // controller has finished initializing.
      body: _isCameraInitialized
          ? Column(
          crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              AspectRatio(
                aspectRatio: 1 / _controller!.value.aspectRatio,
                child: Stack(children: [
                  Center(
                    child: CameraPreview(
                      _controller!,
                    ),
                  ),
                  cameraOverlay(padding: 0, aspectRatio: 1, color: Colors.black.withOpacity(0.8)),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(5.0, 5.0, 5.0, 5.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(child: Container()),
                        Align(
                          alignment: Alignment.bottomCenter,
                          child: InkWell(
                            onTap: () async {
                              _controller!.setFocusMode(FocusMode.locked);
                              _controller!.setExposureMode(ExposureMode.locked);
                              XFile? rawImage = await takePicture();
                              // if (rawImage != null) {
                              //   await _controller?.setFlashMode(FlashMode.off);
                              // }
                              _controller!.setFocusMode(FocusMode.auto);
                              _controller!.setExposureMode(ExposureMode.auto);
                              File imageFile = File(rawImage!.path);
                              if (!mounted) return;
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      DisplayPictureScreen(imagePath: imageFile.path, controller: _controller),
                                ),
                              );
                            },
                            child: const Stack(
                              alignment: Alignment.center,
                              children: [
                                Icon(Icons.circle, color: Colors.white38, size: 80),
                                Icon(Icons.circle, color: Colors.white, size: 65),
                              ],
                            ),
                          ),
                        ),
                                      Row(
                children: <Widget>[
                  IconButton(
                    icon: const Icon(Icons.flash_off),
                    color: _controller?.value.flashMode == FlashMode.off
                        ? Colors.orange
                        : Colors.blue,
                    onPressed: _controller != null
                        ? () => onSetFlashModeButtonPressed(FlashMode.off)
                        : null,
                  ),
                  IconButton(
                    icon: const Icon(Icons.flash_auto),
                    color: _controller?.value.flashMode == FlashMode.auto
                        ? Colors.orange
                        : Colors.blue,
                    onPressed: _controller != null
                        ? () => onSetFlashModeButtonPressed(FlashMode.auto)
                        : null,
                  ),
                  IconButton(
                    icon: const Icon(Icons.flash_on),
                    color: _controller?.value.flashMode == FlashMode.always
                        ? Colors.orange
                        : Colors.blue,
                    onPressed: _controller != null
                        ? () => onSetFlashModeButtonPressed(FlashMode.always)
                        : null,
                  ),
                  IconButton(
                    icon: const Icon(Icons.highlight),
                    color: _controller?.value.flashMode == FlashMode.torch
                        ? Colors.orange
                        : Colors.blue,
                    onPressed: _controller != null
                        ? () => onSetFlashModeButtonPressed(FlashMode.torch)
                        : null,
                  ),
                ],
              ),

                      ],
                    ),
                  )
                ]),
              ),
            ])
          : const Center(
              child: Text(
                'LOADING',
                style: TextStyle(color: Colors.white),
              ),
            ),
    );
  }
}

// A widget that displays the picture taken by the user.
class DisplayPictureScreen extends StatefulWidget {
  final String imagePath;
  final CameraController? controller;

  const DisplayPictureScreen({Key? key, required this.imagePath, required this.controller})
      : super(key: key);

  @override
  DisplayPictureScreenState createState() => DisplayPictureScreenState();
}

class DisplayPictureScreenState extends State<DisplayPictureScreen> {
  late Future<void> _cropImageFuture;

  @override
  void initState() {
    super.initState();
    widget.controller!.setFlashMode(FlashMode.off);
    _cropImageFuture = cropToAspect1(widget.imagePath);
  }

  Future<Uint8List> cropToAspect1(String imagePath) async {
    var decodedImage =
        await decodeImageFromList(File(imagePath).readAsBytesSync());

    var cropSize = min(decodedImage.width, decodedImage.height);
    int offsetX =
        (decodedImage.width - min(decodedImage.width, decodedImage.height)) ~/
            2;
    int offsetY =
        (decodedImage.height - min(decodedImage.width, decodedImage.height)) ~/
            2;

    final imageBytes = img.decodeImage(File(imagePath).readAsBytesSync())!;

    img.Image cropOne = img.copyCrop(
      imageBytes,
      x: offsetX,
      y: offsetY,
      width: cropSize,
      height: cropSize,
    );
    img.Image sendImage = img.copyResize(cropOne, width: 600, height: 600);
    return Uint8List.fromList(img.encodeJpg(sendImage));
    // File(imagePath).writeAsBytes(img.encodeJpg(cropOne));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Display the Picture')),
      // The image is stored as a file on the device. Use the `Image.file`
      // constructor with the given path to display the image.
      body: FutureBuilder(
        future: _cropImageFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done &&
              snapshot.hasData) {
            // Once the future is complete, display the image
            final data = snapshot.data as Uint8List;
            return Column(
              children: [
                Image.memory(data),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context, data);
                    Navigator.pop(context, data);
                  },
                  child: const Text('OK'),
                )
              ],
            );
          } else {
            // While the future is still running, show a loading spinner
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}
