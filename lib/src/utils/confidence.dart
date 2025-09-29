/// Utilities to normalize model confidence scores to 0-100%.
class ConfidenceUtils {
  /// Normalize a confidence-like value to [0,100].
  /// Supported inputs:
  /// - 0..1 (probability) -> *100
  /// - 0..5 (score out of 5) -> (v/5)*100
  /// - 0..100 (already %) -> v
  /// - >100 (scaled) -> v/10 fallback
  static double toPercent(dynamic value) {
    double raw = 0.0;
    if (value is num)
      raw = value.toDouble();
    else if (value != null) raw = double.tryParse(value.toString()) ?? 0.0;

    double pct;
    if (raw <= 1.0)
      pct = raw * 100.0;
    else if (raw <= 5.0)
      pct = (raw / 5.0) * 100.0;
    else if (raw <= 100.0)
      pct = raw;
    else
      pct = raw / 10.0;

    if (pct < 0) pct = 0;
    if (pct > 100) pct = 100;
    return pct;
  }

  /// Apply very light confidence adjustment to prevent extreme overconfidence
  /// This is much more conservative now to avoid hurting correct predictions
  static double applyReliabilityPenalty(
      double rawConfidence, List<dynamic> predictions) {
    double adjustedConfidence = rawConfidence;

    // Only apply a small penalty if ALL predictions are suspiciously close
    if (predictions.length >= 2) {
      double topScore = toPercent(predictions[0]['confidence']);
      double secondScore = toPercent(predictions[1]['confidence']);
      double gap = topScore - secondScore;

      // Only apply penalty if gap is less than 3% (extremely close)
      if (gap < 3) {
        double penalty = 0.02; // Fixed 2% penalty for very close predictions
        adjustedConfidence *= (1 - penalty);
        print(
            '🔍 Extremely close predictions detected. Gap: ${gap.toStringAsFixed(1)}%, Penalty: 2%');
      }
    }

    // Very light cap at 98% to allow high confidence for correct predictions
    if (adjustedConfidence > 98) {
      adjustedConfidence = 98;
      print('🛑 Confidence lightly capped at 98%');
    }

    return adjustedConfidence;
  }

  /// Determine if a classification needs a warning
  static bool needsUncertaintyWarning(
      double adjustedConfidence, List<dynamic> predictions) {
    // Show warning if confidence is below 50% (much lower threshold)
    if (adjustedConfidence < 50) return true;

    if (predictions.length >= 2) {
      double topScore = toPercent(predictions[0]['confidence']);
      double secondScore = toPercent(predictions[1]['confidence']);
      double gap = topScore - secondScore;

      // Show warning only if top 2 are within 5% of each other (very close)
      if (gap < 5) return true;
    }

    return false;
  }

  /// Get a more reliable confidence score with built-in uncertainty detection
  static double getReliableConfidence(
      dynamic rawValue, List<dynamic> predictions) {
    double baseConfidence = toPercent(rawValue);
    return applyReliabilityPenalty(baseConfidence, predictions);
  }
}
