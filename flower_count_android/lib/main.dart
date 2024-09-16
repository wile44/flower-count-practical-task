import 'package:flutter/material.dart';

import 'package:camera/camera.dart';

import 'package:flower_count_android/screen/capture_screen.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final cameras = await availableCameras();
  final firstCamera = cameras.first;

  runApp(MyApp(camera: firstCamera));
}

class MyApp extends StatelessWidget {
  final CameraDescription camera;

  const MyApp({Key? key, required this.camera}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flower Count App',
      home: CaptureScreen(camera: camera),
    );
  }
}