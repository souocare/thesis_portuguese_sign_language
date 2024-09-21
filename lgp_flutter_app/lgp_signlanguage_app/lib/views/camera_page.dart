import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as imageLib;
import 'package:lgp_signlanguage_app/views/tf_classifier/image_utils.dart';
import 'package:lgp_signlanguage_app/views/tf_classifier/predict.dart';
import 'package:lgp_signlanguage_app/views/tf_classifier/classes.dart'; // Import DetectionClasses

class CameraScreen extends StatefulWidget {
  CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  CameraController? cameraController;
  late List<CameraDescription> cameras;
  int selectedCameraIndex = 0; // Default to rear camera
  bool initialized = false;
  DetectionClasses detectedLabel =
      DetectionClasses.nothing; // Stores the detected label as DetectionClasses
  DateTime lastShot = DateTime.now();
  String detectedText = "";
  bool useMediaPipeModel =
      false; // Control switch state, default is offline model (tflite)

  final Predictor predictor = Predictor();

  @override
  void initState() {
    super.initState();
    initialize();
  }

  Future<void> initialize() async {
    try {
      await predictor.initialize(); // Initialize the models

      cameras = await availableCameras();
      selectedCameraIndex = 0; // Use the rear camera by default

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
      await cameraController?.dispose();
    }

    cameraController = CameraController(
      cameras[cameraIndex],
      ResolutionPreset.medium,
    );

    await cameraController?.initialize();
    await cameraController?.startImageStream((image) {
      if (DateTime.now().difference(lastShot).inSeconds > 1) {
        processCameraImage(image);
      }
    });
  }

  Future<void> processCameraImage(CameraImage cameraImage) async {
    try {
      // Convert the camera image to the required format
      final convertedImage = ImageUtils.convertCameraImageToImage(cameraImage);

      // Set the model type based on switch state
      predictor.setUseMediaPipeModel(useMediaPipeModel);

      // Get the prediction using fallback or chosen model
      final resultLabel = await predictor.predictWithFallback(convertedImage);

      if (resultLabel != null && detectedLabel != resultLabel) {
        setState(() {
          detectedLabel = resultLabel; // Assign the DetectionClasses enum
          updateDetectedText(resultLabel);
        });
      }

      lastShot = DateTime.now();
    } catch (e) {
      print('Error processing camera image: $e');
    }
  }

  void updateDetectedText(DetectionClasses label) {
    if (label != DetectionClasses.nothing) {
      setState(() {
        detectedText +=
            label.label + " "; // Use .label to convert enum to string
      });
    } else {
      print("Nothing detected");
    }
  }

  void switchCamera() async {
    // Toggle between front and rear cameras
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
                    Center(
                      child: AspectRatio(
                        aspectRatio:
                            1, // Set the aspect ratio to 1:1 for square
                        child: ClipRect(
                          child: SizedBox(
                            width: MediaQuery.of(context).size.width,
                            height: MediaQuery.of(context)
                                .size
                                .width, // Square dimensions
                            child: cameraController != null &&
                                    cameraController!.value.isInitialized
                                ? CameraPreview(cameraController!)
                                : Container(
                                    color: Colors.black,
                                    child: const Center(
                                        child: CircularProgressIndicator()),
                                  ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Detected: ${detectedLabel.label}", // Display the label using the .label getter
                            style: const TextStyle(
                              fontSize: 24,
                              color: Colors.blue,
                            ),
                          ),
                          SizedBox(height: 10),
                          Text(
                            "Text: $detectedText",
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                          SizedBox(height: 20),
                          // Add Switch here
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "Offline Model",
                                style: TextStyle(fontSize: 18),
                              ),
                              Switch(
                                value: useMediaPipeModel,
                                onChanged: (value) {
                                  setState(() {
                                    useMediaPipeModel = value;
                                  });
                                },
                              ),
                              Text(
                                "MediaPipe Model",
                                style: TextStyle(fontSize: 18),
                              ),
                            ],
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
    cameraController?.dispose();
    super.dispose();
  }
}
