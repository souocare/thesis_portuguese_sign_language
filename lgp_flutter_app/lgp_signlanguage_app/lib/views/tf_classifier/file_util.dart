// lib/tf_classifier/file_util.dart
import 'dart:convert';
import 'package:flutter/services.dart';

class FileUtil {
  static Future<List<String>> loadLabels(String labelsFileName) async {
    final labelsData = await rootBundle.loadString(labelsFileName);
    return LineSplitter.split(labelsData).toList();
  }
}
