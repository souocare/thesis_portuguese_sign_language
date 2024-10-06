// import 'dart:typed_data';
// import 'package:image/image.dart' as img;
// import 'package:tflite_flutter/tflite_flutter.dart';
// import 'classifier_model.dart';
// import 'classifier_category.dart';
// import 'classes.dart'; // Import the DetectionClasses enum

// class Classifier {
//   final ClassifierModel model;

//   Classifier._({
//     required this.model,
//   });

//   static Future<Classifier?> load({
//     required String modelFile,
//   }) async {
//     try {
//       final model = await ClassifierModel.loadModel(modelFile);
//       return Classifier._(model: model);
//     } catch (e) {
//       print('Error loading classifier: $e');
//       return null;
//     }
//   }

//   // Preprocess input image (Resizing and normalizing)
//   Float32List _preProcessImage(img.Image image) {
//     // Resize the image to the model input size (e.g., 128x128)
//     img.Image resizedImage = img.copyResize(image,
//         width: model.inputShape[1], height: model.inputShape[1]);

//     // Allocate a Float32List for input (1 * height * width * channels)
//     Float32List input = Float32List(
//         1 * model.inputShape[1] * model.inputShape[2] * model.inputShape[3]);

//     // Normalize the image and fill the input buffer
//     int pixelIndex = 0;
//     for (int y = 0; y < resizedImage.height; y++) {
//       for (int x = 0; x < resizedImage.width; x++) {
//         int pixel = resizedImage.getPixel(x, y);
//         input[pixelIndex++] =
//             (img.getRed(pixel) / 255.0 - 0.5) * 2; // Normalize between [-1, 1]
//         input[pixelIndex++] = (img.getGreen(pixel) / 255.0 - 0.5) * 2;
//         input[pixelIndex++] = (img.getBlue(pixel) / 255.0 - 0.5) * 2;
//       }
//     }

//     return input;
//   }

//   // Run inference
//   List<double> _runInference(Float32List inputImage) {
//     // Allocate output buffer (List<double> filled with 0.0, with output shape size)
//     var output = List.generate(1, (_) => List<double>.filled(27, 0.0));

//     // Convert the inputImage to a 4D tensor with shape [1, height, width, channels]
//     var input = inputImage.buffer.asFloat32List();

//     // Wrap input in 4D shape [1, height, width, channels]
//     List<List<List<List<double>>>> inputTensor = [
//       List.generate(
//         model.inputShape[1], // height
//         (y) => List.generate(
//           model.inputShape[2], // width
//           (x) => List.generate(
//             model.inputShape[3], // channels (3 for RGB)
//             (c) => input[y * model.inputShape[2] * model.inputShape[3] +
//                     x * model.inputShape[3] +
//                     c]
//                 .toDouble(),
//           ),
//         ),
//       ),
//     ];

//     // Run the model on the input and store results in output
//     model.interpreter.run(inputTensor, output);

//     return output[0]; // Extract the first element since batch size is 1
//   }

//   // Post-process output (Map probabilities to DetectionClasses)
//   List<ClassifierCategory> _postProcessOutput(List<double> output) {
//     List<ClassifierCategory> categoryList = [];

//     for (int i = 0; i < output.length; i++) {
//       final label =
//           DetectionClasses.values[i]; // Map index to DetectionClasses enum
//       categoryList.add(ClassifierCategory(label.label, output[i]));
//     }

//     categoryList.sort((a, b) => b.score.compareTo(a.score));
//     return categoryList;
//   }

//   // Full prediction flow
//   ClassifierCategory predict(img.Image image) {
//     final preprocessedImage =
//         _preProcessImage(image); // Resize and normalize the image
//     final output = _runInference(
//         preprocessedImage); // Run inference on the processed image
//     final categories = _postProcessOutput(
//         output); // Process the model output to get prediction results
//     // Convert categories to a readable string
//     // final categoriesString = categories
//     //    .map((c) =>
//     //        '${c.label}: ${c.score.toStringAsFixed(2)}') // Format label and score
//     //    .join(', '); // Join them into a single string

//     print(categories.first);
//     return categories.first; // Return the top predicted category
//   }
// }
