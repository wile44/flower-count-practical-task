
import 'dart:async';
import 'dart:io';
import 'package:flower_count_android/services/api_services.dart';
import 'package:path/path.dart' as path;

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class CaptureScreen extends StatefulWidget {
  final CameraDescription camera;

  const CaptureScreen({Key? key, required this.camera}) : super(key: key);

  @override
  _CaptureScreenState createState() => _CaptureScreenState();
}

class _CaptureScreenState extends State<CaptureScreen> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;
  Timer? timer;
  List<File> capturedImages = [];
  String metadata = '';
  bool isCapturing = false;
  bool isUploading = false;

  @override
  void initState() {
    super.initState();
    _controller = CameraController(
      widget.camera,
      ResolutionPreset.high,
    );
    _initializeControllerFuture = _controller.initialize();
  }

  @override
  void dispose() {
    _controller.dispose();
    timer?.cancel();
    super.dispose();
  }

  Future<void> captureImage() async {
    try {
      await _initializeControllerFuture;
      final image = await _controller.takePicture();

      final directory = await getApplicationDocumentsDirectory();
      final imagePath = path.join(directory.path, '${DateTime.now()}.png');
      final imageFile = File(imagePath);
      await imageFile.writeAsBytes(await image.readAsBytes());

      setState(() {
        capturedImages.add(imageFile);
      });
    } catch (e) {
      print('Error capturing image: $e');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to capture image.')));
    }
  }

  void startCapturing() {
    if (metadata.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Please enter metadata before starting.')));
      return;
    }

    setState(() {
      isCapturing = true;
    });

    timer = Timer.periodic(Duration(seconds: 1), (Timer t) {
      captureImage();
    });

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Image capture started.')));
  }

  void stopCapturing() {
    setState(() {
      isCapturing = false;
    });
    timer?.cancel();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Image capture stopped.')));
  }

  

  Future<void> uploadImages() async {
    if (capturedImages.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('No images to upload.')));
      return;
    }

    setState(() {
      isUploading = true;
    });

      await ApiServices().uploadImages(capturedImages, metadata, context);


    setState(() {
      isUploading = false;
      capturedImages.clear();
    });

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('All images uploaded successfully.')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Flower Count App'),
      ),
      body: Column(
        children: [
          Expanded(
            child: FutureBuilder<void>(
              future: _initializeControllerFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  return CameraPreview(_controller);
                } else {
                  return Center(child: CircularProgressIndicator());
                }
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              onChanged: (value) {
                metadata = value;
              },
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Enter Metadata',
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton(
                  onPressed: isCapturing ? null : startCapturing,
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.green, // Green for start
                    padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  ),
                  child: Text('Start Capturing'),
                ),
                ElevatedButton(
                  onPressed: isCapturing ? stopCapturing : null,
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.red, // Red for stop
                    padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  ),
                  child: Text('Stop Capturing'),
                ),
              ],
            ),
          ),
          SizedBox(height: 20),
          OutlinedButton(
            onPressed: isUploading ? null : uploadImages,
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.blue, // Blue for upload
              padding: EdgeInsets.symmetric(horizontal: 40, vertical: 20),
            ),
            child: isUploading ? CircularProgressIndicator() : Text('Upload Images'),
          ),
          SizedBox(height: 20),
        ],
      ),
    );
  }
}
