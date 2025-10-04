# 🐠 AquaVision - Fish Species Classifier

A Flutter mobile and web application for AI-powered fish species classification using deep learning. This app integrates with a FastAPI backend powered by EfficientNet-B0 for accurate fish identification and similarity search.

![Flutter](https://img.shields.io/badge/Flutter-%2302569B.svg?style=for-the-badge&logo=Flutter&logoColor=white)
![Dart](https://img.shields.io/badge/dart-%230175C2.svg?style=for-the-badge&logo=dart&logoColor=white)
![API](https://img.shields.io/badge/API-FastAPI-009688?style=for-the-badge)

https://github.com/user-attachments/assets/183c3e62-9df2-440d-8439-56d0b42ec191

## ✨ Features

- **Fish Species Classification**: AI-powered identification using EfficientNet-B0
- **Similarity Search**: Find similar fish images in the database
- **Cross-Platform**: Works on Android, iOS, and Web
- **Camera Integration**: Capture or upload fish images
- **Modern UI**: Beautiful, responsive design with animations
- **Real-time Processing**: Fast classification with confidence scores
- **Confidence Validation**: Automatic similarity validation for low-confidence results

## 🏗️ Architecture

- **Frontend**: Flutter (Dart)
- **Backend API**: FastAPI with EfficientNet-B0
- **Image Processing**: Camera and gallery integration
- **State Management**: Provider pattern
- **HTTP Client**: Dio with robust error handling
- **UI Framework**: Material Design with custom components

## Project Ecosystem

This repository is part of a three-tier fish identification system:

- **[Deep Learning Model](https://github.com/Hetvi2211/Fish-Accuracy-Simulation)** - Core Deep learning model for fish species identification and Similarity Search.
- **[API Backend](https://github.com/unnatii14/fish-classifier-api)** - RESTful API serving the Deep learning model
- **[AquaVision Frontend](https://github.com/unnatii14/aquavision-flutter)** - Flutter Application for fish identification
