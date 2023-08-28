import 'package:dashboard/Widgets/drawer.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:camera/camera.dart';
import 'package:gallery_saver/gallery_saver.dart';

//Creates state for the camera screen
class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  CameraScreenState createState() => CameraScreenState();
}

//Camera state
class CameraScreenState extends State<CameraScreen> {
  late CameraController _controller;

  //Initialises the back camera of the phone
  Future<void> initializeCamera() async {
    List<CameraDescription> cameras = [];

    cameras = await availableCameras();
    //Assigns the phones back camera as the controller
    _controller = CameraController(cameras[1], ResolutionPreset.medium);

    await _controller.initialize();
  }

  //Asks the user for acces to the camera, if acces hasn't been granted before
  Future<void> requestCameraPermission() async {
    await Permission.camera.request();
  }

  //Caputures a photo, when the take photo button is pressed
  Future<XFile> takePhoto() async {
    final photo = await _controller.takePicture();
    return photo;
  }

  //Saves the photo in gallery and disposes the cameracontroller
  Future<void> saveImage(XFile photo) async {
    try {
      await GallerySaver.saveImage(photo.path) as bool;
    } catch (e) {
      print('Error saving image: $e');
    }
  }

  //Gets rids of the cameracontroller object
  void disposeCamera() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'Dashboard',
          textAlign: TextAlign.center,
        ),
      ),
      drawer: const AppMenu(),
      body: FutureBuilder<void>(
        initialData: requestCameraPermission(),
        future: initializeCamera(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return CameraPreview(_controller);
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          XFile photo = await takePhoto();
          await saveImage(photo);
          disposeCamera();
        },
        child: const Icon(Icons.camera),
      ),
    );
  }
}
