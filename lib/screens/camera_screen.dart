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

  Future<void> initializeCamera() async {
    cameras = await availableCameras();
    _controller = CameraController(cameras[1], ResolutionPreset.medium);
    await _controller.initialize();
  }

  Future<void> requestCameraPermission() async {
    final status = await Permission.camera.request();
    if (status.isGranted) {
      // Permission granted
    } else {
      // Permission denied
    }
  }

  Future<void> takePhoto() async {
    final photo = await _controller.takePicture();
    await saveImage(photo);
  }

  Future<void> saveImage(XFile photo) async {
    try {
      final bool result = await GallerySaver.saveImage(photo.path) as bool;
      if (result) {
        // Image saved successfully
        print('Image saved to gallery');
      } else {
        // Saving failed
        print('Failed to save image to gallery');
      }
    } catch (e) {
      print('Error saving image: $e');
    }
  }

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
