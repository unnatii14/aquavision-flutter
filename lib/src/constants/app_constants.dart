/// API endpoint constants
class ApiEndpoints {
  static const String predict = '/predict';
  static const String findSimilar = '/find-similar';
  static const String health = '/health';
}

/// App constants
class AppConstants {
  static const String appName = 'AquaVision';
  static const String appVersion = '1.0.0';
  static const int maxHistoryItems = 50;
  static const int maxSimilarImages = 5;
}

/// Confidence thresholds for classification quality
class ConfidenceThresholds {
  static const double high = 80.0;
  static const double medium = 60.0;
  static const double low = 0.0;
}
