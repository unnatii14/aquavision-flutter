import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'dart:io';
import 'dart:convert';
import '../constants/app_constants.dart';

class ApiService extends ChangeNotifier {
  // Allow overriding via --dart-define=API_BASE_URL=...
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://fish-api-md7q.onrender.com',
  );
  late final Dio _dio;

  bool _isLoading = false;
  String? _errorMessage;
  List<dynamic>? _predictions;
  List<dynamic>? _similarImages;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<dynamic>? get predictions => _predictions;
  List<dynamic>? get similarImages => _similarImages;

  ApiService() {
    _dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'Accept': 'application/json',
      },
    ));

    // Add logging interceptor for debugging
    if (kDebugMode) {
      _dio.interceptors.add(LogInterceptor(
        requestBody: true,
        responseBody: true,
        error: true,
        requestHeader: false,
        responseHeader: false,
      ));
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? error) {
    _errorMessage = error;
    notifyListeners();
  }

  // Test API connection
  Future<bool> healthCheck() async {
    try {
      final response = await _dio.get(ApiEndpoints.health);
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Health check failed: $e');
      return false;
    }
  }

  // Get all fish species - Not available in new API, return hardcoded list
  Future<List<String>?> getFishSpecies() async {
    try {
      _setLoading(true);
      _setError(null);

      // Since the new API doesn't have a /classes endpoint,
      // return a predefined list of common fish species
      final List<String> species = [
        'Goldfish',
        'Betta',
        'Gourami',
        'Angelfish',
        'Tetra',
        'Guppy',
        'Molly',
        'Platy',
        'Catfish',
        'Cichlid',
        'Barb',
        'Danio',
        'Loach',
        'Shark',
        'Unknown'
      ];

      await Future.delayed(
          const Duration(milliseconds: 500)); // Simulate API delay
      return species;
    } catch (e) {
      _setError('Failed to fetch fish species: ${e.toString()}');
      return null;
    } finally {
      _setLoading(false);
    }
  }

  // Classify fish image
  Future<bool> classifyFish(File imageFile) async {
    try {
      _setLoading(true);
      _setError(null);
      _predictions = null;

      // Validate file exists and is readable
      if (!await imageFile.exists()) {
        throw Exception('Image file does not exist');
      }

      final fileSize = await imageFile.length();
      if (fileSize == 0) {
        throw Exception('Image file is empty');
      }

      if (fileSize > 10 * 1024 * 1024) {
        // 10MB limit
        throw Exception('Image file is too large (max 10MB)');
      }

      String fileName = imageFile.path.split('/').last;
      FormData formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          imageFile.path,
          filename: fileName,
        ),
      });

      debugPrint('Sending file: $fileName, size: ${fileSize} bytes');

      final response = await _dio.post(
        ApiEndpoints.predict,
        data: formData,
        options: Options(
          headers: {'Content-Type': 'multipart/form-data'},
        ),
      );

      if (response.statusCode == 200) {
        debugPrint('File-based API Response: ${response.data}');

        // Parse response based on new API format
        dynamic predictionsData;
        if (response.data is Map) {
          // New API returns predictions array directly
          predictionsData = response.data['predictions'] ?? [];
        } else {
          predictionsData = response.data ?? [];
        }

        _predictions = predictionsData;
        debugPrint('File-based Predictions: $_predictions');
        notifyListeners();
        return true;
      } else {
        throw Exception('Server returned status code: ${response.statusCode}');
      }
    } on DioException catch (e) {
      String errorMessage;
      if (e.response != null) {
        errorMessage =
            'Server error (${e.response!.statusCode}): ${e.response!.data}';
      } else if (e.type == DioExceptionType.connectionTimeout) {
        errorMessage =
            'Connection timeout - please check your internet connection';
      } else if (e.type == DioExceptionType.receiveTimeout) {
        errorMessage = 'Request timeout - server took too long to respond';
      } else {
        errorMessage = 'Network error: ${e.message}';
      }
      _setError('Classification failed: $errorMessage');
      return false;
    } catch (e) {
      _setError('Classification failed: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Find similar fish images
  Future<bool> findSimilarFish(File imageFile, {int topK = 5}) async {
    try {
      _setLoading(true);
      _setError(null);
      _similarImages = null;

      print(
          'Debug API: Starting similarity search for file: ${imageFile.path}');
      print('Debug API: File exists: ${await imageFile.exists()}');
      print('Debug API: File size: ${await imageFile.length()} bytes');

      String fileName = imageFile.path.split('/').last;
      FormData formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          imageFile.path,
          filename: fileName,
        ),
        'top_k': topK,
      });

      print('Debug API: Sending request to ${ApiEndpoints.findSimilar}');
      final response = await _dio.post(
        ApiEndpoints.findSimilar,
        data: formData,
        options: Options(
          headers: {'Content-Type': 'multipart/form-data'},
        ),
      );

      print('Debug API: Response status: ${response.statusCode}');
      print('Debug API: Response data: ${response.data}');

      if (response.statusCode == 200) {
        // Parse response based on new API format
        dynamic similarImagesData;
        if (response.data is Map) {
          // New API might return different field name
          similarImagesData = response.data['similar_images'] ??
              response.data['results'] ??
              response.data['similar'] ??
              [];
        } else {
          similarImagesData = response.data ?? [];
        }

        _similarImages = similarImagesData;
        print(
            'Debug API: Similar images found: ${_similarImages?.length ?? 0}');
        notifyListeners();
        return true;
      }
      return false;
    } on DioException catch (e) {
      String errorMessage;
      if (e.response != null) {
        errorMessage =
            'Server error (${e.response!.statusCode}): ${e.response!.data}';
      } else if (e.type == DioExceptionType.connectionTimeout) {
        errorMessage =
            'Connection timeout - please check your internet connection';
      } else if (e.type == DioExceptionType.receiveTimeout) {
        errorMessage = 'Request timeout - server took too long to respond';
      } else {
        errorMessage = 'Network error: ${e.message}';
      }
      debugPrint('Similarity search error: $errorMessage');
      _setError('Similarity search failed: $errorMessage');
      return false;
    } catch (e) {
      debugPrint('Similarity search error: $e');
      _setError('Similarity search failed: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Find similar fish images using base64 (for web)
  Future<bool> findSimilarFishBase64(String base64Image, {int topK = 5}) async {
    try {
      _setLoading(true);
      _setError(null);
      _similarImages = null;

      final bytes = base64Decode(base64Image);

      FormData formData = FormData.fromMap({
        'file': MultipartFile.fromBytes(
          bytes,
          filename: 'image.jpg',
        ),
        'top_k': topK,
      });

      debugPrint(
          'Sending base64 similarity request to ${ApiEndpoints.findSimilar}');
      final response = await _dio.post(
        ApiEndpoints.findSimilar,
        data: formData,
        options: Options(
          headers: {'Content-Type': 'multipart/form-data'},
        ),
      );

      debugPrint('Similarity response status: ${response.statusCode}');
      debugPrint('Similarity response data: ${response.data}');

      if (response.statusCode == 200) {
        // Parse response based on new API format
        dynamic similarImagesData;
        if (response.data is Map) {
          similarImagesData = response.data['similar_images'] ??
              response.data['results'] ??
              response.data['similar'] ??
              [];
        } else {
          similarImagesData = response.data ?? [];
        }

        _similarImages = similarImagesData;
        debugPrint('Similar images found: ${_similarImages?.length ?? 0}');
        notifyListeners();
        return true;
      } else {
        throw Exception('Server returned status code: ${response.statusCode}');
      }
    } on DioException catch (e) {
      String errorMessage;
      if (e.response != null) {
        errorMessage =
            'Server error (${e.response!.statusCode}): ${e.response!.data}';
      } else if (e.type == DioExceptionType.connectionTimeout) {
        errorMessage =
            'Connection timeout - please check your internet connection';
      } else if (e.type == DioExceptionType.receiveTimeout) {
        errorMessage = 'Request timeout - server took too long to respond';
      } else {
        errorMessage = 'Network error: ${e.message}';
      }
      debugPrint('Similarity search error: $errorMessage');
      _setError('Similarity search failed: $errorMessage');
      return false;
    } catch (e) {
      debugPrint('Similarity search error: $e');
      _setError('Similarity search failed: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Classify using base64 image - Handle web and mobile differently
  Future<bool> classifyFishBase64(String base64Image) async {
    try {
      _setLoading(true);
      _setError(null);
      _predictions = null;

      if (kIsWeb) {
        // For web, send base64 directly as multipart form data
        final bytes = base64Decode(base64Image);

        FormData formData = FormData.fromMap({
          'file': MultipartFile.fromBytes(
            bytes,
            filename: 'image.jpg',
          ),
        });

        final response = await _dio.post(
          ApiEndpoints.predict,
          data: formData,
          options: Options(
            headers: {'Content-Type': 'multipart/form-data'},
          ),
        );

        if (response.statusCode == 200) {
          debugPrint('Base64 API Response: ${response.data}');

          // Parse response based on new API format
          dynamic predictionsData;
          if (response.data is Map) {
            predictionsData = response.data['predictions'] ?? [];
          } else {
            predictionsData = response.data ?? [];
          }

          _predictions = predictionsData;
          debugPrint('Base64 Predictions: $_predictions');
          notifyListeners();
          return true;
        } else {
          throw Exception(
              'Server returned status code: ${response.statusCode}');
        }
      } else {
        // For mobile, convert to temporary file
        final bytes = base64Decode(base64Image);

        final tempDir = Directory.systemTemp;
        final tempFile = File(
            '${tempDir.path}/temp_fish_image_${DateTime.now().millisecondsSinceEpoch}.jpg');
        await tempFile.writeAsBytes(bytes);

        // Use the regular file-based classification
        final result = await classifyFish(tempFile);

        // Clean up temporary file
        try {
          await tempFile.delete();
        } catch (e) {
          debugPrint('Failed to delete temporary file: $e');
        }

        return result;
      }
    } on DioException catch (e) {
      String errorMessage;
      if (e.response != null) {
        errorMessage =
            'Server error (${e.response!.statusCode}): ${e.response!.data}';
      } else if (e.type == DioExceptionType.connectionTimeout) {
        errorMessage =
            'Connection timeout - please check your internet connection';
      } else if (e.type == DioExceptionType.receiveTimeout) {
        errorMessage = 'Request timeout - server took too long to respond';
      } else {
        errorMessage = 'Network error: ${e.message}';
      }
      _setError('Classification failed: $errorMessage');
      return false;
    } catch (e) {
      _setError('Classification failed: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  void clearError() {
    _setError(null);
  }

  void clearResults() {
    _predictions = null;
    _similarImages = null;
    notifyListeners();
  }
}
