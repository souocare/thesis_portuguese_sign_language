// lib/tf_classifier/classifier_model.dart
import 'package:tflite_flutter/tflite_flutter.dart';

class ClassifierModel {
  final Interpreter interpreter;
  final List<int> inputShape;
  final List<int> outputShape;
  final TfLiteType inputType;
  final TfLiteType outputType;

  ClassifierModel({
    required this.interpreter,
    required this.inputShape,
    required this.outputShape,
    required this.inputType,
    required this.outputType,
  });

  static Future<ClassifierModel> loadModel(String modelFile) async {
    final interpreter = await Interpreter.fromAsset(modelFile);
    final inputShape = interpreter.getInputTensor(0).shape;
    final outputShape = interpreter.getOutputTensor(0).shape;
    final inputType = interpreter.getInputTensor(0).type;
    final outputType = interpreter.getOutputTensor(0).type;

    return ClassifierModel(
      interpreter: interpreter,
      inputShape: inputShape,
      outputShape: outputShape,
      inputType: inputType,
      outputType: outputType,
    );
  }
}
