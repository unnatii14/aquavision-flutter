import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
// import removed since first-run CTA is no longer used
import '../services/auth_service.dart';
import '../components/fish_background.dart';
import '../services/demo_auth.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AquaVision'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        elevation: 0.5,
        actions: [
          IconButton(
            tooltip: 'Sign out',
            icon: const Icon(Icons.logout),
            onPressed: () async {
              final service = context.read<AuthService>();
              await service.signOut();
              DemoAuthState.signOut();
              if (context.mounted) context.go('/');
            },
          ),
        ],
      ),
      body: FishBackground(
        opacity: 0.12,
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            // Hero header with quick actions
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Container(
                decoration: BoxDecoration(
                  image: const DecorationImage(
                    image: AssetImage('assets/header_bg.jpg'),
                    fit: BoxFit.cover,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  color: Colors.black.withOpacity(0.30),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'AquaVision',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Fish species classification and similarity search',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.white.withOpacity(0.95),
                              fontWeight: FontWeight.w500,
                            ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _HeaderAction(
                              icon: Icons.upload,
                              label: 'Upload for Prediction',
                              onTap: () => context.go('/upload'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _HeaderAction(
                              icon: Icons.assessment_outlined,
                              label: 'View Metrics',
                              onTap: () => context.go('/history'),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _HeaderAction(
                              icon: Icons.info_outline,
                              label: 'About Project',
                              onTap: () => context.go('/about-project'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Expanded(child: SizedBox.shrink()),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Main heading
            const Text(
              'Marine Biodiversity Monitoring using Deep Learning-Based Fish Species Detection',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2D3748),
                height: 1.3,
              ),
            ),
            const SizedBox(height: 16),
            
            // Description paragraphs
            Text(
              'An AI-powered approach to identify fish species for conservation and research.',
              style: TextStyle(
                fontSize: 16,
                color: const Color(0xFF4A5568),
                height: 1.5,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Manual fish monitoring is time-consuming and error-prone. This app uses ConvNeXt-based transfer learning to automate fish classification from images.',
              style: TextStyle(
                fontSize: 16,
                color: const Color(0xFF4A5568),
                height: 1.5,
              ),
            ),
            const SizedBox(height: 32),
            
            // Main action CTA removed; use header quick actions and FAB
            
            // Secondary buttons
            SizedBox(
              width: double.infinity,
              height: 48,
              child: OutlinedButton.icon(
                onPressed: () => context.go('/history'),
                icon: const Icon(Icons.assessment_outlined, size: 20),
                label: const Text(
                  'View Results & Metrics',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            
            SizedBox(
              width: double.infinity,
              height: 48,
              child: OutlinedButton.icon(
                onPressed: () => context.go('/about-project'),
                icon: const Icon(Icons.info_outline, size: 20),
                label: const Text(
                  'About Project',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
            
            // Stats cards
            Row(
              children: const [
                _StatCard(title: 'Fish Scanned', value: '—'),
                SizedBox(width: 16),
                _StatCard(title: 'Accuracy', value: '—'),
              ],
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.go('/upload'),
        icon: const Icon(Icons.upload),
        label: const Text('Upload'),
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
            icon: Icon(Icons.history, color: Color(0xFF2D3748)),
            selectedIcon: Icon(Icons.history, color: Color(0xFF2B6CB0)),
            label: 'History',
          ),
        ],
        onDestinationSelected: (i) {
          if (i == 1) context.go('/history');
        },
        selectedIndex: 0,
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  const _StatCard({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: const Color(0xFFF7FAFC),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2D3748),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Color(0xFF4A5568),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeaderAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _HeaderAction({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withOpacity(0.96),
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              Icon(icon, color: Theme.of(context).colorScheme.primary),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const Icon(Icons.chevron_right, color: Color(0xFF4A5568)),
            ],
          ),
        ),
      ),
    );
  }
}

// Removed overflow menu to avoid duplication with header actions and FAB

