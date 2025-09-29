/// Fish classification prediction model
class Prediction {
  final String species;
  final double confidence;
  final String? imageUrl;

  const Prediction({
    required this.species,
    required this.confidence,
    this.imageUrl,
  });

  factory Prediction.fromJson(Map<String, dynamic> json) {
    return Prediction(
      species: json['species'] ?? json['class'] ?? 'Unknown',
      confidence: (json['confidence'] ?? 0.0).toDouble(),
      imageUrl: json['imageUrl'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'species': species,
      'confidence': confidence,
      if (imageUrl != null) 'imageUrl': imageUrl,
    };
  }
}

/// Classification result containing multiple predictions
class ClassificationResult {
  final List<Prediction> predictions;
  final DateTime timestamp;
  final String? imagePath;

  const ClassificationResult({
    required this.predictions,
    required this.timestamp,
    this.imagePath,
  });

  factory ClassificationResult.fromJson(Map<String, dynamic> json) {
    final predsList = (json['predictions'] as List? ?? [])
        .map((p) => Prediction.fromJson(p as Map<String, dynamic>))
        .toList();

    return ClassificationResult(
      predictions: predsList,
      timestamp:
          DateTime.parse(json['timestamp'] ?? DateTime.now().toIso8601String()),
      imagePath: json['imagePath'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'predictions': predictions.map((p) => p.toJson()).toList(),
      'timestamp': timestamp.toIso8601String(),
      if (imagePath != null) 'imagePath': imagePath,
    };
  }

  Prediction? get topPrediction =>
      predictions.isNotEmpty ? predictions.first : null;
}

/// Similar fish image result model
class SimilarImage {
  final String imageUrl;
  final String species;
  final double similarity;
  final String? description;

  const SimilarImage({
    required this.imageUrl,
    required this.species,
    required this.similarity,
    this.description,
  });

  factory SimilarImage.fromJson(Map<String, dynamic> json) {
    return SimilarImage(
      imageUrl: json['image_url'] ?? json['imageUrl'] ?? '',
      species: json['species'] ?? json['class'] ?? 'Unknown',
      similarity: (json['similarity'] ?? json['score'] ?? 0.0).toDouble(),
      description: json['description'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'imageUrl': imageUrl,
      'species': species,
      'similarity': similarity,
      if (description != null) 'description': description,
    };
  }
}

/// Similarity search result containing multiple similar images
class SimilarityResult {
  final List<SimilarImage> similarImages;
  final DateTime timestamp;
  final String? queryImagePath;

  const SimilarityResult({
    required this.similarImages,
    required this.timestamp,
    this.queryImagePath,
  });

  factory SimilarityResult.fromJson(Map<String, dynamic> json) {
    final imagesList = (json['similar_images'] as List? ?? [])
        .map((img) => SimilarImage.fromJson(img as Map<String, dynamic>))
        .toList();

    return SimilarityResult(
      similarImages: imagesList,
      timestamp:
          DateTime.parse(json['timestamp'] ?? DateTime.now().toIso8601String()),
      queryImagePath: json['queryImagePath'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'similar_images': similarImages.map((img) => img.toJson()).toList(),
      'timestamp': timestamp.toIso8601String(),
      if (queryImagePath != null) 'queryImagePath': queryImagePath,
    };
  }
}
