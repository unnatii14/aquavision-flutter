import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:animate_do/animate_do.dart';
import 'dart:convert';
import 'dart:io' show File; // Guarded usage; avoid on web-sensitive paths
import 'package:flutter/foundation.dart' show kIsWeb;
import 'species_detail_page.dart';
import 'package:aquavision_mobile/src/utils/confidence.dart';
import 'package:aquavision_mobile/src/constants/app_constants.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  List<Map<String, dynamic>> _history = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final historyJson = prefs.getString('classification_history') ?? '[]';
      final List<dynamic> historyData = json.decode(historyJson);

      setState(() {
        _history =
            historyData.map((item) => Map<String, dynamic>.from(item)).toList();
        _history.sort((a, b) => DateTime.parse(b['timestamp'])
            .compareTo(DateTime.parse(a['timestamp'])));
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _clearHistory() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear History'),
        content: const Text(
            'Are you sure you want to clear all classification history?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Clear'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('classification_history');
      setState(() {
        _history.clear();
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('History cleared successfully')),
        );
      }
    }
  }

  void _viewSpeciesDetail(String speciesName) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SpeciesDetailPage(speciesName: speciesName),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Classification History'),
        actions: [
          if (_history.isNotEmpty)
            IconButton(
              onPressed: _clearHistory,
              icon: const Icon(Icons.delete_outline),
              tooltip: 'Clear History',
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _history.isEmpty
              ? _buildEmptyState()
              : _buildHistoryList(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: FadeInUp(
        duration: const Duration(milliseconds: 600),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.history,
              size: 80,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'No Classification History',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Start classifying fish to see your history here',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade500,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.camera_alt),
              label: const Text('Start Classifying'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _history.length,
      itemBuilder: (context, index) {
        final item = _history[index];
        final timestamp = DateTime.parse(item['timestamp']);
        final predictions =
            List<Map<String, dynamic>>.from(item['predictions'] ?? []);

        return FadeInUp(
          duration: const Duration(milliseconds: 400),
          delay: Duration(milliseconds: index * 100),
          child: Card(
            margin: const EdgeInsets.only(bottom: 16),
            elevation: 4,
            child: InkWell(
              onTap: predictions.isNotEmpty
                  ? () => _viewSpeciesDetail(predictions.first['species'] ??
                      predictions.first['class'] ??
                      'Unknown')
                  : null,
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: Theme.of(context)
                                .colorScheme
                                .primary
                                .withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: item['imagePath'] != null &&
                                  !kIsWeb &&
                                  File(item['imagePath']).existsSync()
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.file(
                                    File(item['imagePath']),
                                    fit: BoxFit.cover,
                                  ),
                                )
                              : Icon(
                                  Icons.pets,
                                  size: 30,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (predictions.isNotEmpty) ...[
                                Text(
                                  // Try 'species' first, then fall back to 'class'
                                  (predictions.first['species'] ??
                                      predictions.first['class'] ??
                                      'Unknown') as String,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Confidence: ${_formatConfidence(predictions.first['confidence'])}',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ] else ...[
                                const Text(
                                  'Classification Failed',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                              const SizedBox(height: 4),
                              Text(
                                _formatTimestamp(timestamp),
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (predictions.isNotEmpty)
                          Icon(
                            Icons.arrow_forward_ios,
                            size: 16,
                            color: Colors.grey.shade400,
                          ),
                      ],
                    ),
                    if (predictions.length > 1) ...[
                      const SizedBox(height: 12),
                      const Divider(),
                      const SizedBox(height: 8),
                      Text(
                        'Other Predictions:',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ...predictions.skip(1).take(2).map((prediction) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  prediction['species'] ??
                                      prediction['class'] ??
                                      'Unknown Species',
                                  style: const TextStyle(fontSize: 14),
                                ),
                              ),
                              Text(
                                _formatConfidence(prediction['confidence']),
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ],
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  String _formatConfidence(dynamic value) {
    final pct = ConfidenceUtils.toPercent(value);
    return '${pct.toStringAsFixed(1)}%';
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays == 1 ? '' : 's'} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours == 1 ? '' : 's'} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes == 1 ? '' : 's'} ago';
    } else {
      return 'Just now';
    }
  }
}

// Helper class to save classification history
class HistoryHelper {
  static Future<void> saveClassification({
    required List<Map<String, dynamic>> predictions,
    String? imagePath,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final historyJson = prefs.getString('classification_history') ?? '[]';
      final List<dynamic> historyData = json.decode(historyJson);

      final newEntry = {
        'timestamp': DateTime.now().toIso8601String(),
        'predictions': predictions,
        'imagePath': imagePath,
      };

      historyData.add(newEntry);

      // Keep only last 50 entries
      if (historyData.length > AppConstants.maxHistoryItems) {
        historyData.removeRange(
            0, historyData.length - AppConstants.maxHistoryItems);
      }

      await prefs.setString('classification_history', json.encode(historyData));
    } catch (e) {
      print('Error saving classification history: $e');
    }
  }
}
