import 'dart:io';

// import 'package:custom_gallery/FullScreenImg.dart';
import 'package:cam_gallery/fullview.dart';
import 'package:flutter/material.dart';
import 'package:gallery_saver/gallery_saver.dart';

import 'package:image_picker/image_picker.dart';

ValueNotifier<List> database = ValueNotifier([]);

class Gallery extends StatefulWidget {
  const Gallery({Key? key}) : super(key: key);

  @override
  State<Gallery> createState() => _GalleryState();
}

class _GalleryState extends State<Gallery> {
  void initState() {
    Directory directory =
        Directory.fromUri(Uri.parse('/data/user/0/com.example.cam_gallery/'));
    getitems(directory);
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Gallery'),
        actions: [
          IconButton(
              onPressed: () async {
                final image =
                    await ImagePicker().pickImage(source: ImageSource.camera);
                if (image == null) {
                  return;
                } else {
                  File imagepath = File(image.path);
                  debugPrint(image.path);
                  GallerySaver.saveImage(image.path, albumName: 'images');
                  await imagepath.copy(
                      '/data/user/0/com.example.cam_gallery/image_(${DateTime.now()}).jpg');
                  Directory directory = Directory.fromUri(
                      Uri.parse('/data/user/0/com.example.cam_gallery/'));
                  getitems(directory);
                }
              },
              icon: const Icon(Icons.camera))
        ],
      ),
      body: ValueListenableBuilder(
          valueListenable: database,
          builder: (context, List data, _) {
            print(data);
            return Padding(
              padding: const EdgeInsets.only(left: 20, right: 20),
              child: GridView.extent(
                  maxCrossAxisExtent: 170,
                  mainAxisSpacing: 10,
                  // crossAxisSpacing: 50,
                  children: List.generate(data.length, (index) {
                    return InkWell(
                      onTap: () {
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (ctx) => FullScreenImg(
                                  image: data[index],
                                )));
                      },
                      child: Hero(
                          tag: data[index],
                          child: Image.file(File(data[index].toString()))),
                    );
                  })),
            );
          }),
    );
  }

  getitems(Directory directory) async {
    final listDir = await directory.list().toList();
    // print(listDir);
    database.value.clear();
    for (var i = 0; i < listDir.length; i++) {
      if (listDir[i].path.substring(
              (listDir[i].path.length - 4), (listDir[i].path.length)) ==
          '.jpg') {
        database.value.add(listDir[i].path);
        database.notifyListeners();
      }
    }
  }
}
