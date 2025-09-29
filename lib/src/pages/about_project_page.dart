import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../components/fish_background.dart';

class AboutProjectPage extends StatelessWidget {
  const AboutProjectPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'About Project',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2D3748),
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/home'),
        ),
      ),
      body: FishBackground(
        opacity: 0.12,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Project Overview
              _buildSection(
                'Project Overview',
                Icons.visibility,
                'AquaVision is an AI-powered marine biodiversity monitoring system that uses deep learning to automatically identify and classify fish species from underwater images. Our goal is to support marine biology research, conservation efforts, and biodiversity studies.',
              ),
              
              const SizedBox(height: 24),
              
              // Technical Approach
              _buildSection(
                'Technical Approach',
                Icons.psychology,
                'We employ state-of-the-art deep learning techniques, specifically ConvNeXt-based transfer learning, to achieve high accuracy in fish species classification. Our approach combines computer vision with marine biology expertise.',
              ),
              
              const SizedBox(height: 24),
              
              // Dataset Information
              _buildSection(
                'Dataset & Training',
                Icons.storage,
                'Our model is trained on the Fish4Knowledge dataset, which contains approximately 4,434 images of 484 fish species. After data cleaning and filtering, we work with 342 balanced classes to ensure robust performance.',
              ),
              
              const SizedBox(height: 24),
              
              // Methodology Details
              _buildMethodologySection(),
              
              const SizedBox(height: 24),
              
              // Performance Metrics
              _buildPerformanceSection(),
              
              const SizedBox(height: 24),
              
              // Applications
              _buildSection(
                'Applications',
                Icons.apps,
                'AquaVision can be used for marine research, environmental monitoring, fisheries management, educational purposes, and citizen science initiatives. It provides a scalable solution for underwater biodiversity assessment.',
              ),
              
              const SizedBox(height: 24),
              
              // Future Work
              _buildSection(
                'Future Work',
                Icons.trending_up,
                'We plan to expand the dataset, implement real-time video processing, add more species, improve accuracy through ensemble methods, and develop mobile applications for field researchers.',
              ),
              
              const SizedBox(height: 32),
              
              // Contact & Links
              _buildContactSection(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection(String title, IconData icon, String content) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: const Color(0xFF2B6CB0),
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2D3748),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            content,
            style: const TextStyle(
              fontSize: 16,
              color: Color(0xFF4A5568),
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMethodologySection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.science,
                color: Color(0xFF2B6CB0),
                size: 24,
              ),
              const SizedBox(width: 12),
              const Text(
                'Methodology',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2D3748),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildMethodologyItem('Data Preprocessing', 'Image resizing, augmentation, and normalization for optimal model training'),
          _buildMethodologyItem('Transfer Learning', 'ConvNeXt-Tiny pretrained on ImageNet, fine-tuned for fish classification'),
          _buildMethodologyItem('Training Strategy', 'CrossEntropyLoss with Adam optimizer and StepLR scheduler'),
          _buildMethodologyItem('Class Balancing', 'Weighted sampling to handle imbalanced species distribution'),
        ],
      ),
    );
  }

  Widget _buildMethodologyItem(String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 8,
            height: 8,
            margin: const EdgeInsets.only(top: 8, right: 12),
            decoration: const BoxDecoration(
              color: Color(0xFF2B6CB0),
              shape: BoxShape.circle,
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2D3748),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF4A5568),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPerformanceSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.analytics,
                color: Color(0xFF2B6CB0),
                size: 24,
              ),
              const SizedBox(width: 12),
              const Text(
                'Performance Metrics',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2D3748),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildMetricCard('Overall Accuracy', '80.5%', Icons.check_circle),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildMetricCard('Species Coverage', '342', Icons.category),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildMetricCard('Training Time', '~4 hours', Icons.timer),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildMetricCard('Inference Speed', '<1s', Icons.speed),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard(String title, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF7FAFC),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: const Color(0xFF2B6CB0),
            size: 24,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2D3748),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF4A5568),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildContactSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.contact_support,
                color: Color(0xFF2B6CB0),
                size: 24,
              ),
              const SizedBox(width: 12),
              const Text(
                'Contact & Resources',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2D3748),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildContactItem(context, 'GitHub Repository', 'View source code and documentation'),
          _buildContactItem(context, 'Research Paper', 'Read our detailed methodology and results'),
          _buildContactItem(context, 'Dataset Access', 'Request access to Fish4Knowledge dataset'),
          _buildContactItem(context, 'Support', 'Get help with AquaVision implementation'),
        ],
      ),
    );
  }

  Widget _buildContactItem(BuildContext context, String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Opening $title...')),
          );
        },
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFF7FAFC),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF2B6CB0),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF4A5568),
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios,
                color: Color(0xFF2B6CB0),
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
