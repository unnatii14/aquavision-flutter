import 'package:flutter/material.dart';
import 'package:aquavision_mobile/src/utils/confidence.dart';
import 'package:aquavision_mobile/src/constants/app_constants.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:animate_do/animate_do.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import 'dart:typed_data';
import 'dart:convert';
import '../../services/api_service.dart';
import '../../services/auth_service.dart';

class FishClassifierScreen extends StatefulWidget {
  const FishClassifierScreen({super.key});

  @override
  State<FishClassifierScreen> createState() => _FishClassifierScreenState();
}

class _FishClassifierScreenState extends State<FishClassifierScreen> {
  File? _selectedImage;
  Uint8List? _webImage;
  XFile? _pickedFile;
  final ImagePicker _picker = ImagePicker();
  Map<String, dynamic>? _similarityValidation;

  @override
  void initState() {
    super.initState();
    if (!kIsWeb) {
      _requestPermissions();
    }
  }

  Future<void> _requestPermissions() async {
    if (!kIsWeb) {
      try {
        // Handle permissions gracefully
      } catch (e) {
        // Ignore permission errors on web
      }
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 80,
      );

      if (image != null) {
        _pickedFile = image;
        if (kIsWeb) {
          _webImage = await image.readAsBytes();
        } else {
          _selectedImage = File(image.path);
        }
        setState(() {
          // Image selected successfully
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error picking image: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _classifyImage() async {
    if (_pickedFile == null) return;

    final apiService = context.read<ApiService>();

    try {
      // Show loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: const Color(0xFF001122),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                ),
                const SizedBox(height: 16),
                Text(
                  'Classifying your fish...',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          );
        },
      );

      bool result;

      if (kIsWeb) {
        // For web, use base64 approach
        Uint8List imageBytes = _webImage!;
        final base64Image = base64Encode(imageBytes);
        print('Web - Base64 image length: ${base64Image.length}'); // Debug log
        result = await apiService.classifyFishBase64(base64Image);
      } else {
        // For mobile, use file upload approach which is more reliable
        File imageFile = _selectedImage!;
        print('Mobile - Image file path: ${imageFile.path}'); // Debug log
        print(
            'Mobile - Image file size: ${await imageFile.length()} bytes'); // Debug log
        result = await apiService.classifyFish(imageFile);
      }

      // Close loading dialog
      if (mounted) {
        Navigator.pop(context);
      }

      if (mounted) {
        if (result &&
            apiService.predictions != null &&
            apiService.predictions!.isNotEmpty) {
          // Perform automatic similarity validation for low confidence results
          final confidence = apiService.predictions![0]['confidence'] ?? 0.0;
          if (confidence < 0.7) {
            await _performSimilarityValidation();
          }

          _showClassificationResult({'success': true});
        } else {
          // Show error message
          String errorMessage = apiService.errorMessage ??
              'Failed to classify image. Please try again.';

          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                backgroundColor: const Color(0xFF001122),
                title: const Row(
                  children: [
                    Icon(Icons.error_outline, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Classification Failed',
                        style: TextStyle(color: Colors.white)),
                  ],
                ),
                content: Text(
                  errorMessage,
                  style: const TextStyle(color: Colors.white70),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child:
                        const Text('OK', style: TextStyle(color: Colors.blue)),
                  ),
                ],
              );
            },
          );
        }
      }
    } catch (e) {
      // Close loading dialog if still open
      if (mounted) {
        Navigator.pop(context);
      }

      if (mounted) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              backgroundColor: const Color(0xFF001122),
              title: const Row(
                children: [
                  Icon(Icons.error_outline, color: Colors.red),
                  SizedBox(width: 8),
                  Text('Error', style: TextStyle(color: Colors.white)),
                ],
              ),
              content: Text(
                'An error occurred while classifying the image: $e',
                style: const TextStyle(color: Colors.white70),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('OK', style: TextStyle(color: Colors.blue)),
                ),
              ],
            );
          },
        );
      }
    }
  }

  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Container(
          decoration: const BoxDecoration(
            color: Color(0xFF003366),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    height: 4,
                    width: 40,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Select Image Source',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: _buildSourceOption(
                          icon: Icons.camera_alt,
                          title: 'Camera',
                          onTap: () {
                            Navigator.pop(context);
                            _pickImage(ImageSource.camera);
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildSourceOption(
                          icon: Icons.photo_library,
                          title: 'Gallery',
                          onTap: () {
                            Navigator.pop(context);
                            _pickImage(ImageSource.gallery);
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSourceOption({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withOpacity(0.2),
            Colors.white.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF001122), // Deep dark ocean
              Color(0xFF003366), // Deep ocean
              Color(0xFF005588), // Ocean blue
            ],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Section
                FadeInDown(
                  duration: const Duration(milliseconds: 800),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.white.withOpacity(0.15),
                          Colors.white.withOpacity(0.05),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.waves,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Consumer<AuthService>(
                                builder: (context, authService, child) {
                                  return Text(
                                    'Welcome, ${authService.user?.displayName?.split(' ').first ?? 'Explorer'}!',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  );
                                },
                              ),
                              const Text(
                                'Ready to identify fish?',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFFCCE7FF),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Main Classification Card
                Expanded(
                  child: FadeInUp(
                    duration: const Duration(milliseconds: 800),
                    delay: const Duration(milliseconds: 200),
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Colors.white.withOpacity(0.2),
                            Colors.white.withOpacity(0.1),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(25),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.3),
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 20,
                            spreadRadius: 0,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: [
                            // Image Display Area
                            Expanded(
                              flex: 3,
                              child: Container(
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.3),
                                    width: 2,
                                  ),
                                  gradient: _pickedFile != null
                                      ? null
                                      : LinearGradient(
                                          begin: Alignment.topCenter,
                                          end: Alignment.bottomCenter,
                                          colors: [
                                            Colors.white.withOpacity(0.1),
                                            Colors.white.withOpacity(0.05),
                                          ],
                                        ),
                                ),
                                child: _pickedFile != null
                                    ? ClipRRect(
                                        borderRadius: BorderRadius.circular(18),
                                        child: kIsWeb
                                            ? Image.memory(
                                                _webImage!,
                                                fit: BoxFit.cover,
                                                width: double.infinity,
                                                height: double.infinity,
                                              )
                                            : Image.file(
                                                _selectedImage!,
                                                fit: BoxFit.cover,
                                                width: double.infinity,
                                                height: double.infinity,
                                              ),
                                      )
                                    : Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(15),
                                            decoration: BoxDecoration(
                                              color:
                                                  Colors.white.withOpacity(0.1),
                                              shape: BoxShape.circle,
                                              border: Border.all(
                                                color: Colors.white
                                                    .withOpacity(0.3),
                                                width: 2,
                                              ),
                                            ),
                                            child: Icon(
                                              Icons.camera_alt_outlined,
                                              size: 30,
                                              color:
                                                  Colors.white.withOpacity(0.8),
                                            ),
                                          ),
                                          const SizedBox(height: 12),
                                          const Text(
                                            'Upload Fish Image',
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.white,
                                            ),
                                          ),
                                          const SizedBox(height: 6),
                                          Text(
                                            'Take a photo or select from gallery',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color:
                                                  Colors.white.withOpacity(0.7),
                                            ),
                                          ),
                                        ],
                                      ),
                              ),
                            ),

                            const SizedBox(height: 20),

                            // Action Buttons
                            Row(
                              children: [
                                Expanded(
                                  child: Container(
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                        colors: [
                                          Colors.white.withOpacity(0.2),
                                          Colors.white.withOpacity(0.1),
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(15),
                                      border: Border.all(
                                        color: Colors.white.withOpacity(0.3),
                                        width: 1,
                                      ),
                                    ),
                                    child: Material(
                                      color: Colors.transparent,
                                      child: InkWell(
                                        onTap: _showImageSourceDialog,
                                        borderRadius: BorderRadius.circular(15),
                                        child: const Padding(
                                          padding: EdgeInsets.symmetric(
                                              vertical: 14),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Icon(
                                                Icons.add_photo_alternate,
                                                color: Colors.white,
                                                size: 18,
                                              ),
                                              SizedBox(width: 8),
                                              Text(
                                                'Select Image',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                if (_pickedFile != null) ...[
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Consumer<ApiService>(
                                      builder: (context, apiService, child) {
                                        return Container(
                                          decoration: BoxDecoration(
                                            gradient: const LinearGradient(
                                              begin: Alignment.topLeft,
                                              end: Alignment.bottomRight,
                                              colors: [
                                                Color(0xFF00BCD4),
                                                Color(0xFF0097A7),
                                              ],
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(15),
                                            boxShadow: [
                                              BoxShadow(
                                                color: const Color(0xFF00BCD4)
                                                    .withOpacity(0.3),
                                                blurRadius: 10,
                                                spreadRadius: 0,
                                                offset: const Offset(0, 4),
                                              ),
                                            ],
                                          ),
                                          child: Material(
                                            color: Colors.transparent,
                                            child: InkWell(
                                              onTap: apiService.isLoading
                                                  ? null
                                                  : _classifyImage,
                                              borderRadius:
                                                  BorderRadius.circular(15),
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 14),
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    if (apiService.isLoading)
                                                      const SizedBox(
                                                        width: 18,
                                                        height: 18,
                                                        child:
                                                            CircularProgressIndicator(
                                                          strokeWidth: 2,
                                                          valueColor:
                                                              AlwaysStoppedAnimation<
                                                                      Color>(
                                                                  Colors.white),
                                                        ),
                                                      )
                                                    else
                                                      const Icon(
                                                        Icons.psychology,
                                                        color: Colors.white,
                                                        size: 18,
                                                      ),
                                                    const SizedBox(width: 8),
                                                    Text(
                                                      apiService.isLoading
                                                          ? 'Analyzing...'
                                                          : 'Classify',
                                                      style: const TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 14,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showClassificationResult(Map<String, dynamic> result) {
    final apiService = context.read<ApiService>();

    print('=== SHOWING CLASSIFICATION RESULTS ==='); // Debug log
    print(
        'Predictions available: ${apiService.predictions != null}'); // Debug log
    print(
        'Predictions count: ${apiService.predictions?.length ?? 0}'); // Debug log
    print('Full predictions: ${apiService.predictions}'); // Debug log

    if (apiService.predictions != null && apiService.predictions!.isNotEmpty) {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) => DraggableScrollableSheet(
          initialChildSize: 0.7,
          maxChildSize: 0.95,
          minChildSize: 0.5,
          builder: (context, scrollController) => Container(
            decoration: const BoxDecoration(
              color: Color(0xFF001122),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Column(
              children: [
                // Handle bar
                Container(
                  margin: const EdgeInsets.only(top: 8),
                  height: 4,
                  width: 40,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),

                // Header
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      const Icon(Icons.psychology,
                          color: Colors.blue, size: 24),
                      const SizedBox(width: 8),
                      const Text(
                        'Classification Results',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close, color: Colors.white),
                      ),
                    ],
                  ),
                ),

                // Results list
                Expanded(
                  child: ListView.builder(
                    controller: scrollController,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: apiService.predictions!.length,
                    itemBuilder: (context, index) {
                      final prediction = apiService.predictions![index];
                      print('Prediction $index: $prediction'); // Debug log

                      // Try different possible field names for species - YOUR API USES 'species'
                      final speciesName = prediction['species'] ??
                          prediction['class'] ??
                          prediction['label'] ??
                          prediction['name'] ??
                          'Unknown';

                      // Try different possible field names for confidence
                      final confidenceValue = prediction['confidence'] ??
                          prediction['score'] ??
                          prediction['probability'] ??
                          0.0;

                      // Convert to double and handle YOUR model's confidence format
                      double confidenceDouble = confidenceValue is double
                          ? confidenceValue
                          : double.tryParse(confidenceValue.toString()) ?? 0.0;

                      // Apply reliability-aware confidence calculation with penalties
                      final reliableConfidence =
                          ConfidenceUtils.getReliableConfidence(
                              confidenceDouble, apiService.predictions!);
                      final clampedConfidence =
                          reliableConfidence.clamp(0.0, 100.0);

                      print(
                          'DEBUG: Raw confidence: $confidenceDouble, Reliable: ${reliableConfidence.toStringAsFixed(1)}%, Clamped: $clampedConfidence');
                      print(
                          'Species: $speciesName, Confidence: ${clampedConfidence.toStringAsFixed(1)}%'); // Debug log

                      // Check if this needs uncertainty warning
                      bool needsWarning =
                          ConfidenceUtils.needsUncertaintyWarning(
                              clampedConfidence, apiService.predictions!);
                      bool isLowConfidence =
                          clampedConfidence < ConfidenceThresholds.medium ||
                              needsWarning;

                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: isLowConfidence
                                ? [
                                    Colors.orange.withOpacity(0.1),
                                    Colors.orange.withOpacity(0.05),
                                  ]
                                : [
                                    Colors.blue.withOpacity(0.1),
                                    Colors.blue.withOpacity(0.05),
                                  ],
                          ),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isLowConfidence
                                ? Colors.orange.withOpacity(0.3)
                                : Colors.blue.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.blue.withOpacity(0.2),
                            child: Text(
                              '${index + 1}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          title: Text(
                            speciesName,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                          subtitle: Text(
                            '${clampedConfidence.toStringAsFixed(1)}% confidence',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.7),
                              fontSize: 14,
                            ),
                          ),
                          trailing: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: _getConfidenceColor(clampedConfidence),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              _getConfidenceLabel(clampedConfidence),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),

                // Uncertainty warning (improved algorithm)
                if (apiService.predictions!.isNotEmpty) ...[
                  Builder(
                    builder: (context) {
                      final topPrediction = apiService.predictions!.first;
                      final reliableConfidence =
                          ConfidenceUtils.getReliableConfidence(
                                  (topPrediction['confidence'] ?? 0.0)
                                      .toDouble(),
                                  apiService.predictions!)
                              .clamp(0.0, 100.0);

                      bool needsWarning =
                          ConfidenceUtils.needsUncertaintyWarning(
                              reliableConfidence, apiService.predictions!);

                      if (needsWarning) {
                        return Container(
                          margin: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 10),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.orange.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.orange.withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.warning_amber,
                                  color: Colors.orange),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      reliableConfidence < 60
                                          ? 'Uncertain Classification'
                                          : 'Multiple Possibilities',
                                      style: const TextStyle(
                                        color: Colors.orange,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      reliableConfidence < 60
                                          ? 'The AI is not confident about this identification (${reliableConfidence.toStringAsFixed(0)}%). Consider taking a clearer photo or trying a different angle.'
                                          : 'Multiple fish species have similar features. Compare the top results and use "Find Similar" for verification.',
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.8),
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                ],

                // Similarity validation display
                if (_similarityValidation != null &&
                    _similarityValidation!['performed'] == true)
                  Container(
                    margin: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: _getSimilarityValidationColor().withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _getSimilarityValidationColor().withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(_getSimilarityValidationIcon(),
                            color: _getSimilarityValidationColor()),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _getSimilarityValidationTitle(),
                                style: TextStyle(
                                  color: _getSimilarityValidationColor(),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _getSimilarityValidationMessage(),
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.8),
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                // Action buttons
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      // First row: Find Similar, Save, Report
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () => _findSimilarImages(),
                              icon: const Icon(Icons.search),
                              label: const Text('Find Similar'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF1976D2),
                                foregroundColor: Colors.white,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () => _saveToHistory(),
                              icon: const Icon(Icons.save),
                              label: const Text('Save'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF388E3C),
                                foregroundColor: Colors.white,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () => _reportWrongClassification(),
                              icon: const Icon(Icons.flag),
                              label: const Text('Report'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFFF6B35),
                                foregroundColor: Colors.white,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                      // Second row: "I'm Not Sure" button for very uncertain cases
                      Builder(
                        builder: (context) {
                          if (apiService.predictions!.isNotEmpty) {
                            final topPrediction = apiService.predictions!.first;
                            final reliableConfidence =
                                ConfidenceUtils.getReliableConfidence(
                                        (topPrediction['confidence'] ?? 0.0)
                                            .toDouble(),
                                        apiService.predictions!)
                                    .clamp(0.0, 100.0);

                            if (reliableConfidence < 50) {
                              return Column(
                                children: [
                                  const SizedBox(height: 12),
                                  SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton.icon(
                                      onPressed: () =>
                                          _showUncertaintyOptions(),
                                      icon: const Icon(Icons.help_outline),
                                      label: const Text(
                                          'I\'m Not Sure - Show Other Options'),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                            const Color(0xFF7B1FA2),
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 14),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            }
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    } else {
      // Show error if no predictions
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No classification results found'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  Color _getConfidenceColor(double confidence) {
    if (confidence >= ConfidenceThresholds.high) return Colors.green;
    if (confidence >= ConfidenceThresholds.medium) return Colors.orange;
    return Colors.red;
  }

  String _getConfidenceLabel(double confidence) {
    if (confidence >= ConfidenceThresholds.high) return 'High';
    if (confidence >= ConfidenceThresholds.medium) return 'Medium';
    return 'Low';
  }

  Future<void> _findSimilarImages() async {
    if (_pickedFile == null) {
      print('Debug: No picked file available for similarity search');
      return;
    }

    print('Debug: Starting similarity search with file: ${_pickedFile!.path}');
    final apiService = context.read<ApiService>();

    try {
      // Show loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: const Color(0xFF001122),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                ),
                const SizedBox(height: 16),
                Text(
                  'Finding similar fish images...',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          );
        },
      );

      bool result;
      if (kIsWeb) {
        // For web, use base64 similarity search
        if (_webImage != null) {
          final base64Image = base64Encode(_webImage!);
          print('🌐 Using base64 similarity search for web');
          result = await apiService.findSimilarFishBase64(base64Image);
        } else {
          // Close loading dialog first
          if (mounted) {
            Navigator.pop(context);
          }

          // Show information dialog for web users
          if (mounted) {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  backgroundColor: const Color(0xFF001122),
                  title: const Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.blue),
                      SizedBox(width: 8),
                      Text('No Image Available',
                          style: TextStyle(color: Colors.white)),
                    ],
                  ),
                  content: const Text(
                    'No image available for similarity search. Please select an image first.',
                    style: TextStyle(color: Colors.white70),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('OK',
                          style: TextStyle(color: Colors.blue)),
                    ),
                  ],
                );
              },
            );
          }
          return;
        }
      } else {
        // For mobile, use file upload approach
        File imageFile = File(_pickedFile!.path);
        result = await apiService.findSimilarFish(imageFile);
      }
      print('Debug: Similarity search result: $result');
      print(
          'Debug: Similar images count: ${apiService.similarImages?.length ?? 0}');

      // Close loading dialog
      if (mounted) {
        Navigator.pop(context);
      }

      if (mounted) {
        if (result &&
            apiService.similarImages != null &&
            apiService.similarImages!.isNotEmpty) {
          _showSimilarImages();
        } else {
          String errorMessage =
              apiService.errorMessage ?? 'No similar images found';

          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                backgroundColor: const Color(0xFF001122),
                title: const Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.orange),
                    SizedBox(width: 8),
                    Text('No Results', style: TextStyle(color: Colors.white)),
                  ],
                ),
                content: Text(
                  errorMessage,
                  style: const TextStyle(color: Colors.white70),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child:
                        const Text('OK', style: TextStyle(color: Colors.blue)),
                  ),
                ],
              );
            },
          );
        }
      }
    } catch (e) {
      // Close loading dialog if still open
      if (mounted) {
        Navigator.pop(context);
      }

      if (mounted) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              backgroundColor: const Color(0xFF001122),
              title: const Row(
                children: [
                  Icon(Icons.error_outline, color: Colors.red),
                  SizedBox(width: 8),
                  Text('Error', style: TextStyle(color: Colors.white)),
                ],
              ),
              content: Text(
                'Error finding similar images: $e',
                style: const TextStyle(color: Colors.white70),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('OK', style: TextStyle(color: Colors.blue)),
                ),
              ],
            );
          },
        );
      }
    }
  }

  void _showSimilarImages() {
    final apiService = context.read<ApiService>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.8,
        maxChildSize: 0.95,
        minChildSize: 0.5,
        builder: (context, scrollController) => Container(
          decoration: const BoxDecoration(
            color: Color(0xFF001122),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Column(
            children: [
              // Handle bar
              Container(
                margin: const EdgeInsets.only(top: 8),
                height: 4,
                width: 40,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Header
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    const Icon(Icons.image_search,
                        color: Colors.blue, size: 24),
                    const SizedBox(width: 8),
                    const Text(
                      'Similar Fish Images',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close, color: Colors.white),
                    ),
                  ],
                ),
              ),

              // Similar images grid
              Expanded(
                child: GridView.builder(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.8,
                  ),
                  itemCount: apiService.similarImages!.length,
                  itemBuilder: (context, index) {
                    final similarImage = apiService.similarImages![index];
                    final imagePath = similarImage['image_path'] ?? '';
                    final similarity =
                        (similarImage['similarity'] ?? 0.0) * 100;

                    return Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.blue.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Column(
                          children: [
                            Expanded(
                              child: Container(
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: Colors.grey.withOpacity(0.2),
                                ),
                                child: imagePath.isNotEmpty
                                    ? Image.network(
                                        '${ApiService.baseUrl}/$imagePath',
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (context, error, stackTrace) =>
                                                const Icon(
                                          Icons.broken_image,
                                          color: Colors.white,
                                          size: 40,
                                        ),
                                      )
                                    : const Icon(
                                        Icons.image_not_supported,
                                        color: Colors.white,
                                        size: 40,
                                      ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.blue.withOpacity(0.1),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    '${similarity.toStringAsFixed(1)}%',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 12,
                                    ),
                                  ),
                                  Text(
                                    'Similar',
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.7),
                                      fontSize: 10,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _saveToHistory() async {
    try {
      final apiService = context.read<ApiService>();

      if (apiService.predictions != null && _pickedFile != null) {
        final prefs = await SharedPreferences.getInstance();
        final historyJson = prefs.getString('classification_history') ?? '[]';
        final List<dynamic> historyData = json.decode(historyJson);

        final newEntry = {
          'timestamp': DateTime.now().toIso8601String(),
          'predictions': apiService.predictions,
          'imagePath': _pickedFile!.path,
        };

        historyData.add(newEntry);

        // Keep only last 50 entries
        if (historyData.length > AppConstants.maxHistoryItems) {
          historyData.removeRange(
              0, historyData.length - AppConstants.maxHistoryItems);
        }

        await prefs.setString(
            'classification_history', json.encode(historyData));

        if (mounted) {
          Navigator.pop(context); // Close the results modal
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Results saved to history'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving to history: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _reportWrongClassification() async {
    try {
      final apiService = context.read<ApiService>();

      if (apiService.predictions == null || _pickedFile == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No classification to report'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      // Show dialog to confirm and get feedback
      final result = await showDialog<Map<String, dynamic>>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Report Wrong Classification'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Was this classification incorrect?'),
              const SizedBox(height: 16),
              Text(
                'Current result: ${apiService.predictions![0]['species']}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              const Text(
                  'This will help improve our AI model. Thank you for your feedback!'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, {
                'reported': true,
                'classification': apiService.predictions![0],
                'timestamp': DateTime.now().toIso8601String(),
              }),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF6B35),
              ),
              child: const Text('Report Issue'),
            ),
          ],
        ),
      );

      if (result != null && result['reported'] == true) {
        // Save feedback locally (in a real app, this would be sent to a server)
        final prefs = await SharedPreferences.getInstance();
        final feedbackJson = prefs.getString('classification_feedback') ?? '[]';
        final List<dynamic> feedbackData = json.decode(feedbackJson);

        feedbackData.add({
          'timestamp': result['timestamp'],
          'reported_classification': result['classification'],
          'image_path': _pickedFile!.path,
        });

        // Keep only last 100 feedback entries
        if (feedbackData.length > 100) {
          feedbackData.removeRange(0, feedbackData.length - 100);
        }

        await prefs.setString(
            'classification_feedback', json.encode(feedbackData));

        if (mounted) {
          Navigator.pop(context); // Close the results modal
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                  'Thank you for your feedback! This helps improve our AI.'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 3),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error reporting classification: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _performSimilarityValidation() async {
    try {
      print(
          '🔍 Starting automatic similarity validation for low confidence result');

      final apiService = context.read<ApiService>();
      if (apiService.predictions == null || _pickedFile == null) return;

      final predictedSpecies = apiService.predictions![0]['species'];
      print('🎯 Predicted species: $predictedSpecies');

      // Find similar images to validate the classification
      bool similarityResult = false;
      if (kIsWeb) {
        // For web, use base64 similarity search
        if (_webImage != null) {
          final base64Image = base64Encode(_webImage!);
          print('🌐 Using base64 similarity search for web');
          similarityResult =
              await apiService.findSimilarFishBase64(base64Image);
        } else {
          print('⚠️ No web image available for similarity validation');
          setState(() {
            _similarityValidation = {
              'performed': true,
              'web_limitation': true,
            };
          });
          return;
        }
      } else {
        File imageFile = _selectedImage!;
        similarityResult = await apiService.findSimilarFish(imageFile);
      }

      if (similarityResult && apiService.similarImages != null) {
        print(
            '✅ Similarity search completed, found ${apiService.similarImages!.length} similar images');

        // Check if similar images support the classification
        int matchingSpeciesCount = 0;
        for (var similar in apiService.similarImages!) {
          if (similar['species'] == predictedSpecies) {
            matchingSpeciesCount++;
          }
        }

        final validationRatio = apiService.similarImages!.isNotEmpty
            ? matchingSpeciesCount / apiService.similarImages!.length
            : 0.0;

        print(
            '📊 Validation ratio: $validationRatio ($matchingSpeciesCount/${apiService.similarImages!.length})');

        // Store validation result for display
        setState(() {
          _similarityValidation = {
            'performed': true,
            'matching_count': matchingSpeciesCount,
            'total_count': apiService.similarImages!.length,
            'validation_ratio': validationRatio,
            'is_supported': validationRatio >= 0.5, // 50% threshold
          };
        });

        if (validationRatio < 0.3) {
          print(
              '⚠️ Low similarity validation - classification may be incorrect');
        } else if (validationRatio >= 0.7) {
          print('✅ High similarity validation - classification likely correct');
        }
      } else {
        print('❌ Similarity validation failed');
        setState(() {
          _similarityValidation = {
            'performed': true,
            'failed': true,
          };
        });
      }
    } catch (e) {
      print('❌ Error during similarity validation: $e');
      setState(() {
        _similarityValidation = {
          'performed': true,
          'error': e.toString(),
        };
      });
    }
  }

  Color _getSimilarityValidationColor() {
    if (_similarityValidation == null) return Colors.grey;

    if (_similarityValidation!['web_limitation'] == true) return Colors.blue;
    if (_similarityValidation!['failed'] == true ||
        _similarityValidation!['error'] != null) return Colors.red;

    final isSupported = _similarityValidation!['is_supported'] == true;
    final validationRatio = _similarityValidation!['validation_ratio'] ?? 0.0;

    if (validationRatio >= 0.7) return Colors.green;
    if (validationRatio >= 0.5 || isSupported) return Colors.orange;
    return Colors.red;
  }

  IconData _getSimilarityValidationIcon() {
    if (_similarityValidation == null) return Icons.help;

    if (_similarityValidation!['web_limitation'] == true) return Icons.info;
    if (_similarityValidation!['failed'] == true ||
        _similarityValidation!['error'] != null) return Icons.error;

    final isSupported = _similarityValidation!['is_supported'] == true;
    final validationRatio = _similarityValidation!['validation_ratio'] ?? 0.0;

    if (validationRatio >= 0.7) return Icons.verified;
    if (validationRatio >= 0.5 || isSupported) return Icons.warning;
    return Icons.cancel;
  }

  String _getSimilarityValidationTitle() {
    if (_similarityValidation == null) return 'Validation Status';

    if (_similarityValidation!['web_limitation'] == true) return 'Web Platform';
    if (_similarityValidation!['failed'] == true) return 'Validation Failed';
    if (_similarityValidation!['error'] != null) return 'Validation Error';

    final isSupported = _similarityValidation!['is_supported'] == true;
    final validationRatio = _similarityValidation!['validation_ratio'] ?? 0.0;

    if (validationRatio >= 0.7) return 'High Validation';
    if (validationRatio >= 0.5 || isSupported) return 'Moderate Validation';
    return 'Low Validation';
  }

  String _getSimilarityValidationMessage() {
    if (_similarityValidation == null) return 'No validation performed';

    if (_similarityValidation!['web_limitation'] == true) {
      return 'Similarity validation not available on web platform';
    }

    if (_similarityValidation!['failed'] == true) {
      return 'Unable to find similar images for validation';
    }

    if (_similarityValidation!['error'] != null) {
      return 'Error during validation: ${_similarityValidation!['error']}';
    }

    final matchingCount = _similarityValidation!['matching_count'] ?? 0;
    final totalCount = _similarityValidation!['total_count'] ?? 0;
    final validationRatio = _similarityValidation!['validation_ratio'] ?? 0.0;

    final percentage = (validationRatio * 100).round();

    if (validationRatio >= 0.7) {
      return 'Strong validation: $matchingCount/$totalCount similar images match ($percentage%)';
    } else if (validationRatio >= 0.5) {
      return 'Moderate validation: $matchingCount/$totalCount similar images match ($percentage%)';
    } else {
      return 'Weak validation: Only $matchingCount/$totalCount similar images match ($percentage%)';
    }
  }

  Future<void> _showUncertaintyOptions() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF001122),
        title: const Row(
          children: [
            Icon(Icons.help_outline, color: Colors.purple),
            SizedBox(width: 8),
            Text('AI Uncertain - What to do?',
                style: TextStyle(color: Colors.white)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'The AI isn\'t confident about this identification. Here are your options:',
              style: TextStyle(color: Colors.white70, fontSize: 16),
            ),
            const SizedBox(height: 16),
            _buildUncertaintyOption(
              icon: Icons.camera_alt,
              title: 'Take a better photo',
              description: 'Clear, well-lit, close-up photo works best',
              onTap: () {
                Navigator.pop(context); // Close dialog
                Navigator.pop(context); // Close results
                _showImageSourceDialog(); // Show camera options
              },
            ),
            _buildUncertaintyOption(
              icon: Icons.search,
              title: 'Find similar fish',
              description: 'Compare with database images',
              onTap: () {
                Navigator.pop(context);
                _findSimilarImages();
              },
            ),
            _buildUncertaintyOption(
              icon: Icons.list,
              title: 'Browse all species',
              description: 'Look through the fish catalog',
              onTap: () {
                Navigator.pop(context);
                _showAllSpecies();
              },
            ),
            _buildUncertaintyOption(
              icon: Icons.person_add,
              title: 'Ask an expert',
              description: 'Get help from fish identification experts',
              onTap: () {
                Navigator.pop(context);
                _showExpertHelp();
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child:
                const Text('Cancel', style: TextStyle(color: Colors.white70)),
          ),
        ],
      ),
    );
  }

  Widget _buildUncertaintyOption({
    required IconData icon,
    required String title,
    required String description,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(12),
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.purple, size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    description,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios,
                color: Colors.white54, size: 16),
          ],
        ),
      ),
    );
  }

  Future<void> _showAllSpecies() async {
    // TODO: Implement species browser
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Species browser coming soon!'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  Future<void> _showExpertHelp() async {
    // TODO: Implement expert help system
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Expert help system coming soon!'),
        backgroundColor: Colors.green,
      ),
    );
  }
}
