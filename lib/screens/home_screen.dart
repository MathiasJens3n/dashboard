import 'package:dashboard/Widgets/drawer.dart';
import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Future<void> _getAllImages() async {
    // Ensure that you have the necessary permissions to access photos
    final PermissionState permission =
        await PhotoManager.requestPermissionExtend();
    if (permission.isAuth) {
      // Fetch a list of all albums
      List<AssetPathEntity> albums =
          await PhotoManager.getAssetPathList(type: RequestType.image);

      // Fetch all images from the first album (you can loop through albums to access images from other albums)
      List<AssetEntity> images =
          await albums[0].getAssetListPaged(page: 0, size: 10000);

      // Do something with the list of images, e.g., display them
      for (AssetEntity image in images) {
        print('Image path: ${image.file}');
        // You can also use image.thumbData to get a thumbnail
      }
    } else {
      print("Error");
    }
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
          child: Column(children: [
            ElevatedButton(
              child: const Text("Show Images"),
              onPressed: () {
                _getAllImages();
              },
            )
          ]),
        ));
  }
}
