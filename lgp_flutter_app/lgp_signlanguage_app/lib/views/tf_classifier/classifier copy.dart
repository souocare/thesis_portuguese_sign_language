import 'dart:typed_data';
import 'package:image/image.dart' as img;
import 'package:lgp_signlanguage_app/views/tf_classifier/classes.dart';
import 'package:lgp_signlanguage_app/views/tf_classifier/image_utils.dart';
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

  /// Gets the interpreter instance
  Interpreter get interpreter => _interpreter;

  Future<String> predict(img.Image image) async {
    if (_interpreter == null) {
      throw StateError("Interpreter is not initialized.");
    }

    // Resize the image to the input size of the model (128x128)
    img.Image resizedImage = img.copyResize(image, width: 128, height: 128);

    // Convert the resized image to a 1D Float32List for RGB input
    Float32List inputBytes = Float32List(1 * 128 * 128 * 3);
    int pixelIndex = 0;
    for (int y = 0; y < resizedImage.height; y++) {
      for (int x = 0; x < resizedImage.width; x++) {
        int pixel = resizedImage.getPixel(x, y);

        // Normalize RGB values to [-1.0, 1.0]
        double red = img.getRed(pixel) / 127.5 - 1.0;
        double green = img.getGreen(pixel) / 127.5 - 1.0;
        double blue = img.getBlue(pixel) / 127.5 - 1.0;

        inputBytes[pixelIndex++] = red;
        inputBytes[pixelIndex++] = green;
        inputBytes[pixelIndex++] = blue;
      }
    }

    // Prepare the output buffer
    final output =
        Float32List(1 * 27).reshape([1, 27]); // Update to 27 classes if needed

    // Reshape the input to match the model's input dimensions (for RGB)
    final input = inputBytes.reshape([1, 128, 128, 3]);

    // Run the model
    _interpreter!.run(input, output);

    // Process the model output
    print(output);
    final predictionResult = output[0] as List<double>;

    // Check for any prediction with a confidence greater than 0.5
    for (int i = 0; i < predictionResult.length; i++) {
      double confidence = predictionResult[i];

      // Only print or return if confidence is more than 50%
      if (confidence > 0.5) {
        print(
            "Predicted class: ${classLabels[i]} with confidence: ${confidence * 100}%");
        return classLabels[i]; // Return the label if it's more than 50%
      }
    }

    // If no class exceeds 50%, you can return 'nothing' or an empty string
    print("No prediction above 50%");
    return "nothing";
  }
}
