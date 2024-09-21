import 'dart:async';
import 'dart:typed_data';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:image/image.dart' as img;
import 'package:image/image.dart' as imageLib;
import 'package:lgp_signlanguage_app/views/tf_classifier/image_utils.dart';
import 'package:flutter/foundation.dart'; // Import compute function

final client = http.Client();

class CameraScreen extends StatefulWidget {
  CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  late CameraController cameraController;
  late List<CameraDescription> cameras;
  int selectedCameraIndex = 0; // Rear camera by default

  bool initialized = false;
  String detectedIndex = "";
  String wholetext = "";
  DateTime lastShot = DateTime.now();
  String detectedText = "";

  @override
  void initState() {
    super.initState();
    initialize();
  }

  Future<void> initialize() async {
    try {
      cameras = await availableCameras();
      selectedCameraIndex = 0; // Initialize with the rear camera (index 0)

      await _initializeCamera(selectedCameraIndex);

      setState(() {
        initialized = true;
      });
    } catch (e) {
      print("Error during initialization: $e");
    }
  }

  Future<void> _initializeCamera(int cameraIndex) async {
    if (cameraController != null) {
      await cameraController.dispose();
    }

    cameraController = CameraController(
      cameras[cameraIndex],
      ResolutionPreset.medium,
    );

    await cameraController.initialize();
    await cameraController.startImageStream((image) {
      if (DateTime.now().difference(lastShot).inSeconds > 1) {
        // Run the image processing in a separate isolate
        compute(processAndSendImage, image).then((prediction) {
          handlePrediction(prediction);
        });
      }
    });
  }

  int consecutivePredictionCount = 0;
  int predictionThreshold = 5;
  String lastPrediction = '';

  static Future<String?> processAndSendImage(CameraImage cameraImage) async {
    try {
      final convertedImage = ImageUtils.convertCameraImageToImage(cameraImage);

      // Convert the grayscale image to PNG
      final pngBytes = imageLib.encodePng(convertedImage);

      final uri = Uri.parse(
          'http://192.168.1.67:2468/predict'); // Update with your IP address
      final response = await http
          .post(
            uri,
            headers: {
              'Content-Type': 'application/octet-stream',
            },
            body: pngBytes,
          )
          .timeout(const Duration(seconds: 40)); // Adjust timeout as needed;

      if (response.statusCode == 200) {
        final result = json.decode(response.body);
        final prediction = result['prediction'];

        return prediction;
      } else {
        print('Error: ${response.reasonPhrase}');
        return null;
      }
    } catch (e) {
      print('Error processing camera image: $e');
      return null;
    }
  }

  void handlePrediction(String? prediction) {
    if (prediction != null) {
      if (lastPrediction == prediction) {
        consecutivePredictionCount++;
      } else {
        consecutivePredictionCount = 1;
      }

      lastPrediction = prediction;

      if (consecutivePredictionCount >= predictionThreshold &&
          detectedIndex != prediction) {
        setState(() {
          detectedIndex = prediction;
          wholetext += prediction;
          updateDetectedText(prediction);
        });
      }
    }
    lastShot = DateTime.now();
  }

  void updateDetectedText(String prediction) {
    setState(() {
      detectedText = prediction;
    });
  }

  void switchCamera() async {
    // Toggle between front and rear camera
    selectedCameraIndex = selectedCameraIndex == 0 ? 1 : 0;
    await _initializeCamera(selectedCameraIndex);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: initialized
          ? Stack(
              children: [
                Column(
                  children: [
                    SizedBox(height: 40),
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.5,
                      width: MediaQuery.of(context).size.width,
                      child: CameraPreview(cameraController),
                    ),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Current: $wholetext",
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
                ),
                Positioned(
                  top: 50, // Adjust this value as needed
                  right: 20,
                  child: IconButton(
                    icon: Icon(
                      Icons.cameraswitch,
                      color: Colors.white,
                      size: 40,
                    ),
                    onPressed: switchCamera,
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
