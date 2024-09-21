import 'dart:math';
import 'package:image/image.dart' as img;
import 'package:tflite_flutter_helper/tflite_flutter_helper.dart';
import 'classifier_model.dart';
import 'classifier_category.dart';
import 'classes.dart'; // Import the DetectionClasses enum

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

  // Preprocess input image
  TensorImage _preProcessImage(img.Image image) {
    final tensorImage = TensorImage(model.inputType);
    tensorImage.loadImage(image);

    final minLength = min(tensorImage.width, tensorImage.height);
    final cropOp = ResizeWithCropOrPadOp(minLength, minLength);
    final resizeOp = ResizeOp(
        model.inputShape[1], model.inputShape[1], ResizeMethod.BILINEAR);
    final normalizeOp = NormalizeOp(127.5, 127.5);

    final imageProcessor = ImageProcessorBuilder()
        .add(cropOp)
        .add(resizeOp)
        .add(normalizeOp)
        .build();

    imageProcessor.process(tensorImage);
    return tensorImage;
  }

  // Run inference
  TensorBuffer _runInference(TensorImage inputImage) {
    final outputBuffer =
        TensorBuffer.createFixedSize(model.outputShape, model.outputType);
    model.interpreter.run(inputImage.buffer, outputBuffer.buffer);
    return outputBuffer;
  }

  // Post-process output
  List<ClassifierCategory> _postProcessOutput(TensorBuffer outputBuffer) {
    final probabilityProcessor = TensorProcessorBuilder().build();
    probabilityProcessor.process(outputBuffer);

    // Map the probabilities to DetectionClasses
    final List<double> probabilities = outputBuffer.getDoubleList();
    List<ClassifierCategory> categoryList = [];

    for (int i = 0; i < probabilities.length; i++) {
      final label =
          DetectionClasses.values[i]; // Map index to DetectionClasses enum
      categoryList.add(ClassifierCategory(label.label, probabilities[i]));
    }

    categoryList.sort((a, b) => b.score.compareTo(a.score));
    return categoryList;
  }

  // Full prediction flow
  ClassifierCategory predict(img.Image image) {
    final preprocessedImage = _preProcessImage(image);
    final outputBuffer = _runInference(preprocessedImage);
    final categories = _postProcessOutput(outputBuffer);
    return categories.first; // Return the top predicted category
  }
}
