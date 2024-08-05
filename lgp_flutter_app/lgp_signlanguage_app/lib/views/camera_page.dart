import 'dart:isolate';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:lgp_signlanguage_app/views/tf_classifier/classes.dart';
import 'package:lgp_signlanguage_app/views/tf_classifier/classifier.dart';
import 'package:lgp_signlanguage_app/views/tf_classifier/image_utils.dart';
import 'package:tflite_flutter/tflite_flutter.dart';

final client = http.Client();

class CameraScreen extends StatefulWidget {
  CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  late CameraController cameraController;
  late Interpreter interpreter;
  final classifier = Classifier();

  bool initialized = false;
  DetectionClasses detected = DetectionClasses.nothing;
  DateTime lastShot = DateTime.now();
  String detectedText = "";

  @override
  void initState() {
    super.initState();
    initialize();
  }

  Future<void> initialize() async {
    await classifier.loadModel();

    final cameras = await availableCameras();
    cameraController = CameraController(
      cameras[0],
      ResolutionPreset.medium,
    );

    await cameraController.initialize();
    await cameraController.startImageStream((image) {
      if (DateTime.now().difference(lastShot).inSeconds > 1) {
        processCameraImage(image);
      }
    });

    setState(() {
      initialized = true;
    });
  }

  Future<void> processCameraImage(CameraImage cameraImage) async {
    try {
      final convertedImage = ImageUtils.convertCameraImageToImage(cameraImage);
      final result = await classifier.predict(convertedImage);

      if (detected != result) {
        setState(() {
          detected = result;
          updateDetectedText(result.label);
        });
      }

      lastShot = DateTime.now();
    } catch (e) {
      print('Error processing camera image: $e');
    }
  }

  void updateDetectedText(String letter) {
    if (letter != "nothing") {
      setState(() {
        detectedText += letter;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: initialized
          ? Column(
              children: [
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.8,
                  width: MediaQuery.of(context).size.width,
                  child: CameraPreview(cameraController),
                ),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Current: ${detected.label}",
                        style: const TextStyle(
                          fontSize: 24,
                          color: Colors.blue,
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        "Detected: $detectedText",
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            )
          : const Center(child: CircularProgressIndicator()),
    );
  }

  @override
  void dispose() {
    cameraController.dispose();
    super.dispose();
  }
}
