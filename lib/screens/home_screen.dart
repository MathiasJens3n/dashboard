import 'dart:async';
import 'dart:typed_data';

import 'package:dashboard/Widgets/drawer.dart';
import 'package:flutter/material.dart';
import 'package:matrix_gesture_detector/matrix_gesture_detector.dart';
import 'package:photo_manager/photo_manager.dart';

//Creates state for the home screen
class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  HomeScreenState createState() => HomeScreenState();
}

//Home screen state
class HomeScreenState extends State<HomeScreen> {
  final List<Uint8List> _images = [];
  final List<Matrix4> _imageTransforms = [];

  //Sets the scale for the images in the matrix
  double _currentScale = 1.0;

  //Gets all images from the gallery
  Future<void> _getAllImages() async {
    //Request permission to the gallery
    final PermissionState permission =
        await PhotoManager.requestPermissionExtend();

    //Reads all images from the gallery, if permission is granted
    if (permission.isAuth) {
      List<AssetPathEntity> albums = await PhotoManager.getAssetPathList(
        type: RequestType.image,
        hasAll: true,
      );

      List<AssetEntity> images =
          await albums[0].getAssetListPaged(page: 0, size: 10000);

      List<Uint8List> availableImages = await _convertToU8List(images);

      _showImageDialog(availableImages);
    } else {
      print("Permission to gallery denied");
    }
  }

  //Takes a list of the type AssetEntity and converts it to a list of Uint8
  Future<List<Uint8List>> _convertToU8List(
      List<AssetEntity> availableImages) async {
    List<Uint8List> uint8List = [];

    for (AssetEntity asset in availableImages) {
      Uint8List data = await asset.originBytes as Uint8List;
      uint8List.add(data);
    }

    return uint8List;
  }

  //Opens a dialog where the user can select images to add to their screen.
  Future<void> _showImageDialog(List<Uint8List> images) async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Container(
            width: MediaQuery.of(context).size.width * 0.8,
            height: MediaQuery.of(context).size.height * 0.5,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: images.length,
              itemBuilder: (BuildContext context, int index) {
                //Registers if an image is tapped and adds it to the list shown on the home screen.
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _images.add(images[index]);
                      _imageTransforms.add(Matrix4.identity());
                    });
                  },
                  child: Image.memory(images[index], width: 100, height: 100),
                );
              },
            ),
          ),
        );
      },
    );
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
      body: Center(
        child: Column(
          children: [
            ElevatedButton(
              child: const Text("Add Images"),
              onPressed: () {
                _getAllImages();
              },
            ),
            ElevatedButton(
              child: const Text("Remove Images"),
              onPressed: () {
                setState(() {
                  _images.clear();
                  _imageTransforms.clear();
                });
              },
            ),
            Expanded(
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _images.length,
                itemBuilder: (BuildContext context, int index) {
                  return MatrixGestureDetector(
                    //rotation is not being used
                    onMatrixUpdate: (Matrix4 matrix, Matrix4? translationMatrix,
                        Matrix4? scaleMatrix, Matrix4 rotation) {
                      if (scaleMatrix != null) {
                        final double newScale = matrix.getMaxScaleOnAxis();
                        setState(() {
                          _currentScale = newScale;
                          _imageTransforms[index] = matrix;
                        });
                      }
                    },
                    shouldRotate: false,
                    shouldScale: true,
                    shouldTranslate: true,
                    child: Transform(
                      transform: _imageTransforms[index],
                      child: Image.memory(
                        _images[index],
                        width: 200 * _currentScale,
                        height: 200 * _currentScale,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
