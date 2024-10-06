// classifier.dart

import 'dart:typed_data';
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';
import 'classifier_model.dart'; // Import your ClassifierModel class
import 'classifier_category.dart'; // Import your ClassifierCategory class
import 'classes.dart'; // Import the DetectionClasses enum and extension

class Classifier {
  final ClassifierModel model;

  Classifier._({
    required this.model,
  });

  static Future<Classifier?> load({
    required String modelFile,
  }) async {
    try {
      final model = await ClassifierModel.loadModel(modelFile);
      return Classifier._(model: model);
    } catch (e) {
      print('Error loading classifier: $e');
      return null;
    }
  }

  // Preprocess input image (Resizing and normalizing)
  Float32List _preProcessImage(img.Image image) {
    // Resize the image to the model input size
    int inputHeight = model.inputShape[1];
    int inputWidth = model.inputShape[2];

    img.Image resizedImage = img.copyResize(
      image,
      width: inputWidth,
      height: inputHeight,
    );

    // Allocate a Float32List for input
    int inputSize = inputHeight * inputWidth * 3; // 3 channels (RGB)
    Float32List input = Float32List(inputSize);

    // Normalize the image and fill the input buffer
    int pixelIndex = 0;
    for (int y = 0; y < resizedImage.height; y++) {
      for (int x = 0; x < resizedImage.width; x++) {
        int pixel = resizedImage.getPixel(x, y);
        input[pixelIndex++] = img.getRed(pixel) / 255.0; // Normalize to [0, 1]
        input[pixelIndex++] =
            img.getGreen(pixel) / 255.0; // Normalize to [0, 1]
        input[pixelIndex++] = img.getBlue(pixel) / 255.0; // Normalize to [0, 1]
      }
    }

    return input;
  }

  // Run inference without tflite_flutter_helper
  List<double> _runInference(Float32List inputImage) {
    Interpreter interpreter = model.interpreter;

    // Get input tensor information
    var inputTensor = interpreter.getInputTensor(0);
    var inputShape =
        inputTensor.shape; // Should be [1, height, width, channels]

    // Ensure that the input data length matches the tensor size
    int expectedSize = inputShape.reduce((a, b) => a * b);
    if (inputImage.length != expectedSize) {
      throw Exception(
          'Input data size (${inputImage.length}) does not match expected size ($expectedSize).');
    }

    // Reshape inputImage into 4D List
    int height = inputShape[1];
    int width = inputShape[2];
    int channels = inputShape[3];

    var inputAs4DList = [
      List.generate(
          height,
          (y) => List.generate(
              width,
              (x) => List.generate(channels, (c) {
                    int index = y * width * channels + x * channels + c;
                    return inputImage[index];
                  })))
    ];

    // Prepare output buffer
    var outputTensor = interpreter.getOutputTensor(0);
    var outputShape = outputTensor.shape; // Should be [1, num_classes]
    int batchSize = outputShape[0];
    int numClasses = outputShape[1];

    // Create output buffer matching the output tensor shape
    var outputAsList =
        List.generate(batchSize, (_) => List.filled(numClasses, 0.0));

    // Run inference
    interpreter.run(inputAs4DList, outputAsList);

    // Extract output
    List<double> output = outputAsList[0];

    return output;
  }

  // Post-process output (Map probabilities to DetectionClasses)
  List<ClassifierCategory> _postProcessOutput(List<double> output) {
    List<ClassifierCategory> categoryList = [];

    for (int i = 0; i < output.length; i++) {
      final label =
          DetectionClasses.values[i]; // Map index to DetectionClasses enum
      categoryList.add(ClassifierCategory(label.label, output[i]));
    }

    // Sort categories by score in descending order
    categoryList.sort((a, b) => b.score.compareTo(a.score));
    return categoryList;
  }

  // Full prediction flow
  ClassifierCategory predict(img.Image image) {
    final preprocessedImage =
        _preProcessImage(image); // Resize and normalize the image
    final output = _runInference(
        preprocessedImage); // Run inference on the processed image
    final categories = _postProcessOutput(
        output); // Process the model output to get prediction results

    // Output the top predicted category
    print(categories.first);
    return categories.first; // Return the top predicted category
  }
}
