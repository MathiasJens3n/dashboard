import 'package:dashboard/Widgets/drawer.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:camera/camera.dart';
import 'package:gallery_saver/gallery_saver.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  CameraScreenState createState() => CameraScreenState();
}

class CameraScreenState extends State<CameraScreen> {
  late CameraController _controller;
  List<CameraDescription> cameras = [];

  //Initialises the back camera of the phone
  Future<void> initializeCamera() async {
    requestCameraPermission();
    cameras = await availableCameras();
    //Assigns the back camera as the controller
    _controller = CameraController(cameras[1], ResolutionPreset.medium);

    await _controller.initialize();
  }

  //Asks the user for acces to the camera, if acces hasn't been granted before
  Future<void> requestCameraPermission() async {
    await Permission.camera.request();
  }

  //When the take photo button is pressed, and calls saveImage() to save the photo in the gallery
  Future<void> takePhoto() async {
    final photo = await _controller.takePicture();
    await saveImage(photo);
  }

  //Saves the photo in gallery and disposes the cameracontroller
  Future<void> saveImage(XFile photo) async {
    try {
      await GallerySaver.saveImage(photo.path) as bool;
    } catch (e) {
      print('Error saving image: $e');
    }
    dispose();
  }

  //Gets rids of the cameracontroller object
  @override
  void dispose() {
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
        onPressed: takePhoto,
        child: const Icon(Icons.camera),
      ),
    );
  }
}
