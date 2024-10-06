// lib/tf_classifier/predict.dart
import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'dart:io'; // Import for handling SocketException
import 'package:http/http.dart' as http;
import 'classifier.dart';
import 'classes.dart'; // Import the DetectionClasses enum
import 'package:image/image.dart' as imageLib;

enum ModelType { mediapipe, tflite }

double _previousScore = 0;
String? _previousLabel;
int _validPredictionCount = 0;

class Predictor {
  ModelType _currentModel =
      ModelType.tflite; // Default to Offline Model (tflite)
  Classifier? _tfliteClassifier;
  final String apiUrl = 'http://192.168.1.67:2468/predict';
  bool _useMediaPipe = false; // Initially, use tflite

  Future<void> initialize() async {
    // Initialize TFLite Classifier
    _tfliteClassifier = await Classifier.load(
        modelFile: 'assets/tf_model/model_cnn_pretrained_20240919.tflite');

    if (_tfliteClassifier == null) {
      throw Exception('Failed to load TFLite classifier');
    }
  }

  // Function to set the model choice (Offline or MediaPipe)
  void setUseMediaPipeModel(bool useMediaPipe) {
    _useMediaPipe = useMediaPipe;
    _currentModel = useMediaPipe ? ModelType.mediapipe : ModelType.tflite;
  }

  Future<DetectionClasses?> predictWithFallback(
      imageLib.Image convertedImage) async {
    if (_currentModel == ModelType.tflite) {
      // Use TensorFlow Lite (Offline)
      return _predictWithTflite(convertedImage);
    } else {
      // Try MediaPipe model and fallback to tflite after 5 seconds if no response
      try {
        final pngBytes = imageLib.encodePng(convertedImage);
        return await _predictWithMediaPipeWithTimeout(
            pngBytes, Duration(seconds: 5));
      } catch (e) {
        print('MediaPipe API failed, switching to tflite: $e');
        return _predictWithTflite(convertedImage); // Fallback to tflite
      }
    }
  }

  Future<DetectionClasses?> _predictWithMediaPipeWithTimeout(
      List<int> pngBytes, Duration timeout) async {
    final uri = Uri.parse(apiUrl);

    // Using a timeout for the HTTP request
    final response = await http
        .post(
      uri,
      headers: {'Content-Type': 'application/octet-stream'},
      body: pngBytes,
    )
        .timeout(timeout, onTimeout: () {
      throw TimeoutException("MediaPipe API timeout after $timeout");
    });

    if (response.statusCode == 200) {
      final result = json.decode(response.body);
      String? predictedLabel = result['prediction'];
      return _getDetectionClassFromLabel(predictedLabel);
    } else if (response.statusCode == 404) {
      throw http.ClientException("404 Not Found");
    }
    return null;
  }

  Future<DetectionClasses?> _predictWithTflite(imageLib.Image image) async {
    // Ensure the classifier is loaded
    if (_tfliteClassifier == null) {
      throw Exception('TFLite classifier is not initialized');
    }

    // Use TensorFlow Lite model to make the prediction
    final category = _tfliteClassifier!.predict(image);

    if (category != null) {
      final currentLabel = category.label;
      final currentScore = category.score; // Assuming score is between 0 and 1

      print(
          'Category: $currentLabel, Confidence: ${(currentScore * 100).toStringAsFixed(2)}%');

      // Check if the current prediction is over 70%
      if (currentScore > 0.70) {
        // If it's the same label as the previous valid one, increment the counter
        if (_previousLabel == currentLabel) {
          _validPredictionCount++;
        } else {
          // Reset the counter if the label changes
          _validPredictionCount =
              1; // First valid prediction for this new label
        }

        // Update the previous prediction details
        _previousLabel = currentLabel;
        _previousScore = currentScore;

        // If this is the second valid prediction, take action
        if (_validPredictionCount == 2) {
          print("Second valid prediction! Letter: $currentLabel");

          // Reset state after the action
          _previousLabel = null;
          _previousScore = 0;
          _validPredictionCount = 0;

          return _getDetectionClassFromLabel(
              currentLabel); // Return detected class
        }
      } else {
        // If the confidence is below 70%, reset the previous predictions
        _previousLabel = null;
        _previousScore = 0;
        _validPredictionCount = 0;
      }
    }

    return null; // Return null if no valid prediction
  }

  DetectionClasses? _getDetectionClassFromLabel(String? label) {
    if (label == null || label.isEmpty) {
      return DetectionClasses.nothing;
    }

    // Use the label to enum mapping
    for (var detectionClass in DetectionClasses.values) {
      if (detectionClass.label == label) {
        return detectionClass;
      }
    }

    // Return nothing if label does not match
    return DetectionClasses.nothing;
  }
}
