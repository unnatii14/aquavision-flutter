import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import 'package:provider/provider.dart';
import 'package:aquavision_mobile/src/services/api_service.dart';
import 'package:aquavision_mobile/src/utils/confidence.dart';
import '../components/fish_background.dart';

class UploadPage extends StatefulWidget {
  const UploadPage({super.key});

  @override
  State<UploadPage> createState() => _UploadPageState();
}

class _UploadPageState extends State<UploadPage> {
  bool _uploading = false;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickAndUpload(ImageSource source) async {
    final picked = await _picker.pickImage(source: source, imageQuality: 90);
    if (picked == null) return;
    final file = File(picked.path);
    if (!mounted) return;
    setState(() => _uploading = true);
    try {
      final api = context.read<ApiService>();
      final ok = await api.classifyFish(file);
      if (!mounted) return;
      if (ok && api.predictions != null && api.predictions!.isNotEmpty) {
        final preds = api.predictions!;
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text('Classification Results'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: preds.take(3).map<Widget>((p) {
                  final species = p['species'] ?? p['class'] ?? 'Unknown';
                  final pct = ConfidenceUtils.toPercent(p['confidence']);
                  return ListTile(
                    dense: true,
                    title: Text(species.toString()),
                    subtitle: Text('${pct.toStringAsFixed(1)}% confidence'),
                  );
                }).toList(),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Close'),
                )
              ],
            );
          },
        );
      } else {
        final msg = api.errorMessage ?? 'Classification failed';
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(msg)));
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Upload failed: $e')));
    } finally {
      if (mounted) setState(() => _uploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Scan Fish',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2D3748),
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: FishBackground(
        opacity: 0.12,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Expanded(
                child: InkWell(
                  onTap: _uploading
                      ? null
                      : () => _pickAndUpload(ImageSource.gallery),
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                          color: Theme.of(context).colorScheme.outline),
                      color: Colors.white.withOpacity(0.9),
                    ),
                    child: _uploading
                        ? const CircularProgressIndicator()
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Icon(Icons.upload_file,
                                  size: 48, color: Color(0xFF2B6CB0)),
                              SizedBox(height: 8),
                              Text(
                                'Tap to choose image',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Color(0xFF4A5568),
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: FilledButton.icon(
                  onPressed: _uploading
                      ? null
                      : () => _pickAndUpload(ImageSource.camera),
                  icon: const Icon(Icons.photo_camera),
                  label: const Text('Take Photo'),
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF2B6CB0),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: NavigationBar(
        backgroundColor: const Color(0xFFF7FAFC),
        elevation: 0,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined, color: Color(0xFF2D3748)),
            selectedIcon: Icon(Icons.home, color: Color(0xFF2B6CB0)),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.upload, color: Color(0xFF2D3748)),
            selectedIcon: Icon(Icons.upload, color: Color(0xFF2B6CB0)),
            label: 'Upload',
          ),
          NavigationDestination(
            icon: Icon(Icons.history, color: Color(0xFF2D3748)),
            selectedIcon: Icon(Icons.history, color: Color(0xFF2B6CB0)),
            label: 'History',
          ),
        ],
        onDestinationSelected: (i) {
          if (i == 0) context.go('/home');
          if (i == 2) context.go('/history');
        },
        selectedIndex: 1,
      ),
    );
  }
}
