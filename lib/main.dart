// ignore_for_file: prefer_const_constructors

import 'dart:typed_data';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Shared Image',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Uint8List? sharedImage;
  Uint8List? importedImage;

  @override
  void initState() {
    super.initState();
    initSharingIntent();
  }

  @override
  void dispose() {
    super.dispose();
    ReceiveSharingIntent.reset();
  }

  Future<void> initSharingIntent() async {
    ReceiveSharingIntent.getInitialMedia().then((List<SharedMediaFile> value) {
      if (value != null && value.isNotEmpty) {
        _loadImage(value[0].path);
      }
    });

    ReceiveSharingIntent.getMediaStream().listen(
      (List<SharedMediaFile> value) {
        if (value != null && value.isNotEmpty) {
          _loadImage(value[0].path);
        }
      },
      onDone: () => print("Sharing Intent Stream done"),
      onError: (err) => print("Sharing Intent Stream error: $err"),
    );
  }

  Future<void> _loadImage(String path) async {
    File imageFile = File(path);
    if (imageFile.existsSync()) {
      List<int> imageBytes = await imageFile.readAsBytes();
      setState(() {
        sharedImage = Uint8List.fromList(imageBytes);
      });
    }
  }

  Future<void> _importImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      List<int> imageBytes = await File(pickedFile.path!).readAsBytes();
      setState(() {
        importedImage = Uint8List.fromList(imageBytes);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue[100],
        title: Text('Shared Image'),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: Center(
              child: sharedImage != null || importedImage != null
                  ? Image.memory(
                      sharedImage ?? importedImage!,
                      fit: BoxFit.cover,
                    )
                  : Text(
                      'No shared or imported image',
                      style: TextStyle(fontSize: 16),
                    ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: _importImage,
              child: Text('Import Image'),
            ),
          ),
        ],
      ),
    );
  }
}
