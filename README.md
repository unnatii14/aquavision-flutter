# 🐠 AquaVision - Fish Species Classifier

A Flutter mobile and web application for AI-powered fish species classification using deep learning. This app integrates with a FastAPI backend powered by EfficientNet-B0 for accurate fish identification and similarity search.

![Flutter](https://img.shields.io/badge/Flutter-%2302569B.svg?style=for-the-badge&logo=Flutter&logoColor=white)
![Dart](https://img.shields.io/badge/dart-%230175C2.svg?style=for-the-badge&logo=dart&logoColor=white)
![API](https://img.shields.io/badge/API-FastAPI-009688?style=for-the-badge)

## ✨ Features

- **🎯 Fish Species Classification**: AI-powered identification using EfficientNet-B0
- **🔍 Similarity Search**: Find similar fish images in the database
- **📱 Cross-Platform**: Works on Android, iOS, and Web
- **📸 Camera Integration**: Capture or upload fish images
- **🎨 Modern UI**: Beautiful, responsive design with animations
- **🔄 Real-time Processing**: Fast classification with confidence scores
- **📊 Confidence Validation**: Automatic similarity validation for low-confidence results

## 🏗️ Architecture

- **Frontend**: Flutter (Dart)
- **Backend API**: FastAPI with EfficientNet-B0
- **Image Processing**: Camera and gallery integration
- **State Management**: Provider pattern
- **HTTP Client**: Dio with robust error handling
- **UI Framework**: Material Design with custom components

## 🚀 Getting Started

### Prerequisites

- Flutter SDK (>=3.3.0)
- Dart SDK
- Android Studio / VS Code
- Git

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/aquavision-flutter.git
   cd aquavision-flutter
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Configure API URL** (optional):
   ```bash
   # Use custom API server
   flutter run -d chrome --dart-define=API_BASE_URL=https://your-api-server.com
   
   # Default uses: https://fish-api-md7q.onrender.com
   flutter run -d chrome
   ```

4. **Platform Setup**:

   **Android**: Add to `android/app/src/main/AndroidManifest.xml`:
   ```xml
   <uses-permission android:name="android.permission.CAMERA" />
   <uses-permission android:name="android.permission.READ_MEDIA_IMAGES" />
   ```

   **iOS**: Add to `ios/Runner/Info.plist`:
   ```xml
   <key>NSCameraUsageDescription</key>
   <string>Allow camera access to capture fish images</string>
   <key>NSPhotoLibraryUsageDescription</key>
   <string>Allow photo library access to pick images</string>
   ```

### Running the App

```bash
# Web (Chrome)
flutter run -d chrome

# Android
flutter run -d android

# iOS
flutter run -d ios
```
└── src/
    ├── components/              # Reusable UI components
    │   └── fish_background.dart
    ├── constants/               # App constants and configurations
    │   └── app_constants.dart
    ├── models/                  # Data models
    │   └── prediction.dart
    ├── pages/                   # Application screens
    │   ├── auth/               # Authentication screens
    │   ├── home/               # Main app screens
    │   │   ├── fish_classifier_screen.dart
    │   │   └── navigation_screen.dart
    │   ├── history_page.dart
    │   ├── upload_page.dart
    │   └── ...
    ├── services/               # Business logic and API
    │   ├── api_service.dart    # Classification API client
    │   └── auth_service.dart   # Authentication service
    └── utils/                  # Utility functions
        └── confidence.dart     # Confidence normalization
```

## Quick Start

### Prerequisites
- Flutter SDK (>=3.3.0)
- API server running (Render deployment or local)
- Device/emulator for testing

### Installation

1. **Clone and setup**:
   ```bash
   git clone <repository>
   cd flutter_app
   flutter pub get
   ```

2. **Configure API URL** (optional):
   ```bash
   # For custom API server
   flutter run -d chrome --dart-define=API_BASE_URL=https://your-api-server.com
   
   # Default uses: https://fish-api-md7q.onrender.com
   flutter run -d chrome
   ```

3. **Platform Setup**:

   **Android**: Add to `android/app/src/main/AndroidManifest.xml`:
   ```xml
   <uses-permission android:name="android.permission.CAMERA" />
   <uses-permission android:name="android.permission.READ_MEDIA_IMAGES" />
   ```

   **iOS**: Add to `ios/Runner/Info.plist`:
   ```xml
   <key>NSCameraUsageDescription</key>
   <string>Allow camera access to capture fish images</string>
   <key>NSPhotoLibraryUsageDescription</key>
   <string>Allow photo library access to pick images</string>
   ```

### Running the App

```bash
# Web (Chrome)
flutter run -d chrome

# Android
flutter run -d android

# iOS
flutter run -d ios

# With custom API URL
flutter run -d chrome --dart-define=API_BASE_URL=https://fish-api-md7q.onrender.com
```

## API Integration

The app communicates with a fish classification API:

- **Base URL**: Configurable via `--dart-define=API_BASE_URL`
- **Endpoints**:
  - `POST /predict` - File upload classification
  - `POST /find-similar` - Find similar fish images
  - `GET /health` - Health check

### Response Format
```json
{
  "success": true,
  "predictions": [
    {
      "species": "Gourami",
      "confidence": 4.5
    }
  ],
  "top_prediction": "Gourami",
  "confidence": 4.5
}
```

## Confidence Normalization

The app normalizes different confidence formats to 0-100%:

- **0..1 range**: Probability (×100) → `0.85 → 85%`
- **0..5 range**: Score out of 5 (÷5×100) → `4.5 → 90%`  
- **0..100 range**: Already percentage → `75 → 75%`
- **>100**: Downscale fallback → `450 → 45%`

## Development

### Code Quality
```bash
# Run static analysis
flutter analyze

# Run tests
flutter test

# Format code
flutter format lib/
```

### Building for Production
```bash
# Android APK
flutter build apk --release

# iOS
flutter build ios --release

# Web
flutter build web --release
```

## Troubleshooting

### Common Issues

1. **"Unsupported operation: _Namespace" on web**
   - Fixed: All `dart:io` usage is web-guarded

2. **Low confidence scores (4% instead of 90%)**
   - Fixed: Confidence normalization in `ConfidenceUtils.toPercent()`

3. **Classification modal not appearing**
   - Fixed: Added `notifyListeners()` in `ApiService`

4. **API connection issues**
   - Check API URL configuration
   - Verify network connectivity
   - Check CORS settings (web only)

### Debug Mode
The app includes comprehensive debug logging:
- API request/response details
- Confidence calculation steps  
- UI state changes
- File upload progress

## License

This project is part of the AquaVision fish classification system.