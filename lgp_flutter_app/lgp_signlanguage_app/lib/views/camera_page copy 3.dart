// import 'dart:isolate';

// import 'package:camera/camera.dart';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:lgp_signlanguage_app/views/tf_classifier/classes.dart';
// import 'package:lgp_signlanguage_app/views/tf_classifier/classifier.dart';
// import 'package:lgp_signlanguage_app/views/tf_classifier/image_utils.dart';
// import 'package:tflite_flutter/tflite_flutter.dart';

// final client = http.Client();

// class CameraScreen extends StatefulWidget {
//   CameraScreen({super.key});

//   @override
//   State<CameraScreen> createState() => _CameraScreenState();
// }

// class _CameraScreenState extends State<CameraScreen> {
//   CameraController? cameraController;
//   late List<CameraDescription> cameras;
//   int selectedCameraIndex = 0; // Start with the rear camera by default

//   final classifier = Classifier();

//   bool initialized = false;
//   String detectedLabel = "nothing"; // Holds the label
//   DateTime lastShot = DateTime.now();
//   String detectedText = "";

//   @override
//   void initState() {
//     super.initState();
//     initialize();
//   }

//   Future<void> initialize() async {
//     try {
//       await classifier.loadModel();

//       cameras = await availableCameras();
//       selectedCameraIndex = 0; // Rear camera by default

//       await _initializeCamera(selectedCameraIndex);

//       setState(() {
//         initialized = true;
//       });
//     } catch (e) {
//       print("Error during initialization: $e");
//     }
//   }

//   Future<void> _initializeCamera(int cameraIndex) async {
//     if (cameraController != null) {
//       await cameraController?.dispose();
//     }

//     cameraController = CameraController(
//       cameras[cameraIndex],
//       ResolutionPreset.medium,
//     );

//     await cameraController?.initialize();
//     await cameraController?.startImageStream((image) {
//       if (DateTime.now().difference(lastShot).inSeconds > 1) {
//         processCameraImage(image);
//       }
//     });
//   }

//   Future<void> processCameraImage(CameraImage cameraImage) async {
//     try {
//       final convertedImage = ImageUtils.convertCameraImageToImage(cameraImage);
//       final resultLabel = await classifier
//           .predict(convertedImage); // Get label instead of index

//       if (detectedLabel != resultLabel) {
//         setState(() {
//           detectedLabel = resultLabel;
//           updateDetectedText(resultLabel);
//         });
//       }

//       lastShot = DateTime.now();
//     } catch (e) {
//       print('Error processing camera image: $e');
//     }
//   }

//   void updateDetectedText(String label) {
//     if (label != "nothing") {
//       // Assuming "nothing" means no label detected
//       setState(() {
//         detectedText += label + " ";
//       });
//     } else {
//       print("Nothing detected");
//     }
//   }

//   void switchCamera() async {
//     // Toggle between front and rear camera
//     selectedCameraIndex = selectedCameraIndex == 0 ? 1 : 0;
//     await _initializeCamera(selectedCameraIndex);
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: initialized
//           ? Stack(
//               children: [
//                 Column(
//                   children: [
//                     SizedBox(
//                       height: MediaQuery.of(context).size.height * 0.5,
//                       width: MediaQuery.of(context).size.width,
//                       child: cameraController != null &&
//                               cameraController!.value.isInitialized
//                           ? CameraPreview(cameraController!)
//                           : Container(
//                               color: Colors.black,
//                               child: const Center(
//                                   child: CircularProgressIndicator()),
//                             ),
//                     ),
//                     Expanded(
//                       child: Column(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           Text(
//                             "Detected: $detectedLabel", // Display the current label
//                             style: const TextStyle(
//                               fontSize: 24,
//                               color: Colors.blue,
//                             ),
//                           ),
//                           SizedBox(height: 10),
//                           Text(
//                             "Text: $detectedText", // Display all detected labels
//                             style: const TextStyle(
//                               fontSize: 28,
//                               fontWeight: FontWeight.bold,
//                               color: Colors.green,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//                 Positioned(
//                   top: 50, // Adjust this value as needed
//                   right: 20,
//                   child: IconButton(
//                     icon: Icon(
//                       Icons.cameraswitch,
//                       color: Colors.white,
//                       size: 40,
//                     ),
//                     onPressed: switchCamera,
//                   ),
//                 ),
//               ],
//             )
//           : const Center(child: CircularProgressIndicator()),
//     );
//   }

//   @override
//   void dispose() {
//     cameraController?.dispose();
//     super.dispose();
//   }
// }
