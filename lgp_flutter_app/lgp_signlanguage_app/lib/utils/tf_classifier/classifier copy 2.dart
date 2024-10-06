import 'dart:typed_data';
import 'package:image/image.dart' as img;
import 'package:lgp_signlanguage_app/utils/tf_classifier/classes.dart';
import 'package:tflite_flutter/tflite_flutter.dart';

class Classifier {
  late Interpreter _interpreter;

  static const String modelFile =
      "assets/tf_model/model_cnn_pretrained_20240919.tflite";
  static const List<String> classLabels = [
    'A',
    'B',
    'C',
    'D',
    'E',
    'F',
    'G',
    'H',
    'I',
    'J',
    'K',
    'L',
    'M',
    'N',
    'O',
    'P',
    'Q',
    'R',
    'S',
    'T',
    'U',
    'V',
    'W',
    'X',
    'Y',
    'Z',
    'nothing'
  ];

  /// Loads interpreter from asset
  Future<void> loadModel({Interpreter? interpreter}) async {
    try {
      _interpreter = interpreter ??
          await Interpreter.fromAsset(
            modelFile,
            options: InterpreterOptions()..threads = 4,
          );
      _interpreter.allocateTensors();
    } catch (e) {
      print("Error while creating interpreter: $e");
    }
  }

  Interpreter get interpreter => _interpreter;

  Future<String> predict(img.Image image) async {
    if (_interpreter == null) {
      throw StateError("Interpreter is not initialized.");
    }

    // Apply resizing and use bilinear interpolation
    img.Image resizedImage = img.copyResize(image,
        width: 128, height: 128, interpolation: img.Interpolation.nearest);

    // Convert image to a Float32List with normalized values [0.0, 1.0]
    Float32List inputBytes = Float32List(1 * 128 * 128 * 3);
    int pixelIndex = 0;
    for (int y = 0; y < resizedImage.height; y++) {
      for (int x = 0; x < resizedImage.width; x++) {
        int pixel = resizedImage.getPixel(x, y);

        // Normalize RGB values to [0, 1]
        double red = img.getRed(pixel) / 255.0;
        double green = img.getGreen(pixel) / 255.0;
        double blue = img.getBlue(pixel) / 255.0;

        inputBytes[pixelIndex++] = red;
        inputBytes[pixelIndex++] = green;
        inputBytes[pixelIndex++] = blue;
      }
    }

    // Prepare the output buffer
    final output = Float32List(1 * 27).reshape([1, 27]);

    // Reshape the input to match the model's input dimensions
    final input = inputBytes.reshape([1, 128, 128, 3]);

    // Run the model
    _interpreter.run(input, output);

    // Process the output and get the prediction with the highest confidence
    final predictionResult = output[0] as List<double>;
    for (int i = 0; i < predictionResult.length; i++) {
      double confidence = predictionResult[i];
      if (confidence > 0.5) {
        // Lower threshold to 0.3 for better prediction
        print(
            "Predicted class: ${classLabels[i]} with confidence: ${confidence * 100}%");
        return classLabels[i];
      }
    }

    // If no class exceeds the confidence threshold
    return "nothing";
  }
}
