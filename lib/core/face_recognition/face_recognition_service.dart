import 'dart:math';
import 'face_embedding_service.dart';

class FaceMatchResult {
  final bool isMatched;
  final double distance;
  final double threshold;

  const FaceMatchResult({
    required this.isMatched,
    required this.distance,
    required this.threshold,
  });
}

class FaceRecognitionService {
  static const double defaultThreshold = 0.75;
  final FaceEmbeddingService _embeddingService;

  FaceRecognitionService({FaceEmbeddingService? embeddingService})
      : _embeddingService = embeddingService ?? FaceEmbeddingService();

  Future<void> initialize() async {
    await _embeddingService.loadModel();
  }

  /// Calculates L2 normalized Euclidean distance between two 192-dimensional embeddings.
  /// Distance ranges roughly from 0.0 (identical) to 2.0 (completely different).
  double calculateDistance(List<double> emb1, List<double> emb2) {
    if (emb1.isEmpty || emb2.isEmpty || emb1.length != emb2.length) {
      return double.infinity;
    }

    final a = _l2Normalize(emb1);
    final b = _l2Normalize(emb2);

    double sum = 0.0;
    for (int i = 0; i < a.length; i++) {
      final diff = a[i] - b[i];
      sum += diff * diff;
    }
    return sqrt(sum);
  }

  List<double> _l2Normalize(List<double> embedding) {
    double normSq = 0.0;
    for (final v in embedding) {
      normSq += v * v;
    }
    final norm = sqrt(normSq);
    if (norm == 0) return embedding;
    return embedding.map((v) => v / norm).toList();
  }

  FaceMatchResult compareFaces(
    List<double> liveEmbedding,
    List<double> registeredEmbedding, {
    double threshold = defaultThreshold,
  }) {
    final distance = calculateDistance(liveEmbedding, registeredEmbedding);
    final isMatched = distance < threshold;

    return FaceMatchResult(
      isMatched: isMatched,
      distance: distance,
      threshold: threshold,
    );
  }

  void dispose() {
    _embeddingService.dispose();
  }
}

