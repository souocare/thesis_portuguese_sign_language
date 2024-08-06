import 'dart:typed_data';
import 'package:image/image.dart' as img;
import 'package:lgp_signlanguage_app/views/tf_classifier/classes.dart';
import 'package:lgp_signlanguage_app/views/tf_classifier/image_utils.dart';
import 'package:tflite_flutter/tflite_flutter.dart';

class Classifier {
  late Interpreter _interpreter;

  static const String modelFile = "assets/tf_model/model_final_pt.tflite";

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

  Future<int> predict(img.Image image) async {
    if (_interpreter == null) {
      throw StateError("Interpreter is not initialized.");
    }

    // Convert the image to grayscale
    img.Image grayscaleImage = ImageUtils.convertRGBToGrayscale(image);

    // Resize the grayscale image to the input size of the model (128x128)
    img.Image resizedImage =
        img.copyResize(grayscaleImage, width: 128, height: 128);

    // Convert the resized grayscale image to a 1D Float32List
    Float32List inputBytes = Float32List(1 * 128 * 128 * 1);
    int pixelIndex = 0;
    for (int y = 0; y < resizedImage.height; y++) {
      for (int x = 0; x < resizedImage.width; x++) {
        int pixel = resizedImage.getPixel(x, y);
        double grayValue = img.getRed(pixel) / 127.5 - 1.0;
        inputBytes[pixelIndex++] = grayValue; // Only one channel for grayscale
      }
    }

    // Prepare the output buffer
    final output =
        Float32List(1 * 27).reshape([1, 27]); // Update to 27 classes if needed

    // Reshape the input to match the model's input dimensions
    final input = inputBytes.reshape([1, 128, 128, 1]);

    // Run the model
    interpreter.run(input, output);

    // Process the model output
    final predictionResult = output[0] as List<double>;
    double maxElement = predictionResult.reduce(
      (double maxElement, double element) =>
          element > maxElement ? element : maxElement,
    );
    return predictionResult.indexOf(maxElement);
  }
}
