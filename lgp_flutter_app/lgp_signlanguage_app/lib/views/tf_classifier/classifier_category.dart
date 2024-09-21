// lib/tf_classifier/classifier_category.dart
class ClassifierCategory {
  final String label;
  final double score;

  ClassifierCategory(this.label, this.score);

  @override
  String toString() {
    return 'Category: $label, Confidence: ${(score * 100).toStringAsFixed(2)}%';
  }
}
