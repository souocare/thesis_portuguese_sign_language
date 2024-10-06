// import 'dart:async';
// import 'dart:convert';
// import 'dart:typed_data';
// import 'dart:io'; // Import for handling SocketException
// import 'package:http/http.dart' as http;
// import 'package:lgp_signlanguage_app/views/tf_classifier/classifier.dart';
// import 'package:image/image.dart' as imageLib;
// import 'package:lgp_signlanguage_app/views/tf_classifier/image_utils.dart';

// enum ModelType { mediapipe, tflite }

// class Predictor {
//   ModelType _currentModel =
//       ModelType.tflite; // Default to Offline Model (tflite)
//   final Classifier _tfliteClassifier = Classifier();
//   final String apiUrl = 'http://192.168.1.67:2468/predict';
//   bool _useMediaPipe = false; // Initially, use tflite

//   Future<void> initialize() async {
//     await _tfliteClassifier.loadModel();
//   }

//   // Function to set the model choice (Offline or MediaPipe)
//   void setUseMediaPipeModel(bool useMediaPipe) {
//     _useMediaPipe = useMediaPipe;
//     _currentModel = useMediaPipe ? ModelType.mediapipe : ModelType.tflite;
//   }

//   Future<String?> predictWithFallback(imageLib.Image convertedImage) async {
//     if (_currentModel == ModelType.tflite) {
//       // Use TensorFlow Lite (Offline)
//       return _predictWithTflite(convertedImage);
//     } else {
//       // Try MediaPipe model and fallback to tflite after 5 seconds if no response
//       try {
//         final pngBytes = imageLib.encodePng(convertedImage);
//         return await _predictWithMediaPipeWithTimeout(
//             pngBytes, Duration(seconds: 5));
//       } catch (e) {
//         print('MediaPipe API failed, switching to tflite: $e');
//         return _predictWithTflite(convertedImage); // Fallback to tflite
//       }
//     }
//   }

//   Future<String?> _predictWithMediaPipeWithTimeout(
//       List<int> pngBytes, Duration timeout) async {
//     final uri = Uri.parse(apiUrl);

//     // Using a timeout for the HTTP request
//     final response = await http
//         .post(
//       uri,
//       headers: {'Content-Type': 'application/octet-stream'},
//       body: pngBytes,
//     )
//         .timeout(timeout, onTimeout: () {
//       throw TimeoutException("MediaPipe API timeout after $timeout");
//     });

//     if (response.statusCode == 200) {
//       final result = json.decode(response.body);
//       return result['prediction'];
//     } else if (response.statusCode == 404) {
//       throw http.ClientException("404 Not Found");
//     }
//     return null;
//   }

//   Future<String?> _predictWithTflite(imageLib.Image image) async {
//     // Use TensorFlow Lite model to make the prediction
//     return await _tfliteClassifier.predict(image);
//   }
// }
