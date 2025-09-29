import 'package:flutter/material.dart';

class FishBackground extends StatelessWidget {
  final Widget child;
  final double opacity;
  
  const FishBackground({
    super.key,
    required this.child,
    this.opacity = 0.08,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Fish image background
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFFE6F3FF), // Light blue fallback color
            ),
            child: Opacity(
              opacity: opacity,
              child: Image.asset(
                'assets/fish_sample.jpeg',
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
                errorBuilder: (context, error, stackTrace) {
                  // Fallback if image fails to load
                  return Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFE6F3FF),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          const Color(0xFFE6F3FF).withOpacity(0.3),
                          const Color(0xFFB3D9FF).withOpacity(0.2),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
        // Content
        child,
      ],
    );
  }
}
