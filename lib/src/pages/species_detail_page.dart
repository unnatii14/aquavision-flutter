import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:animate_do/animate_do.dart';
import 'dart:convert';

class SpeciesDetailPage extends StatefulWidget {
  final String speciesName;
  final String? imageUrl;

  const SpeciesDetailPage({
    super.key,
    required this.speciesName,
    this.imageUrl,
  });

  @override
  State<SpeciesDetailPage> createState() => _SpeciesDetailPageState();
}

class _SpeciesDetailPageState extends State<SpeciesDetailPage> {
  Map<String, dynamic>? speciesData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSpeciesData();
  }

  Future<void> _loadSpeciesData() async {
    try {
      final String jsonString =
          await rootBundle.loadString('assets/data/fish_species.json');
      final Map<String, dynamic> data = json.decode(jsonString);

      // Try to find species data by name (case insensitive)
      final fishSpecies = data['fish_species'] as Map<String, dynamic>;
      String? matchedKey;

      final searchName = widget.speciesName.toLowerCase().trim();
      print('Searching for species: "$searchName"');
      print('Available keys: ${fishSpecies.keys.toList()}');

      // First try exact match
      for (String key in fishSpecies.keys) {
        if (key.toLowerCase() == searchName) {
          matchedKey = key;
          print('Found exact match: $key');
          break;
        }
      }

      // If no exact match, try contains match
      if (matchedKey == null) {
        for (String key in fishSpecies.keys) {
          if (key.toLowerCase().contains(searchName) ||
              searchName.contains(key.toLowerCase())) {
            matchedKey = key;
            print('Found contains match: $key');
            break;
          }
        }
      }

      // If still no match, try matching with common_name
      if (matchedKey == null) {
        for (String key in fishSpecies.keys) {
          final species = fishSpecies[key] as Map<String, dynamic>;
          final commonName =
              (species['common_name'] as String? ?? '').toLowerCase();
          if (commonName.contains(searchName) ||
              searchName.contains(commonName)) {
            matchedKey = key;
            print('Found common name match: $key');
            break;
          }
        }
      }

      setState(() {
        if (matchedKey != null) {
          speciesData = fishSpecies[matchedKey];
          print('Successfully loaded species data for: $matchedKey');
        } else {
          print('No match found for species: "${widget.speciesName}"');
        }
        isLoading = false;
      });
    } catch (e) {
      print('Error loading species data: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            title: Text(
              widget.speciesName,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF0D47A1),
                      Color(0xFF1565C0),
                      Color(0xFF1976D2),
                      Color(0xFF0277BD),
                    ],
                  ),
                ),
                child: const Center(
                  child: Icon(
                    Icons.pets,
                    size: 80,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: isLoading
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(50),
                      child: CircularProgressIndicator(),
                    ),
                  )
                : speciesData != null
                    ? _buildSpeciesInfo()
                    : _buildNoDataMessage(),
          ),
        ],
      ),
    );
  }

  Widget _buildSpeciesInfo() {
    // Additional safety check
    if (speciesData == null) {
      return _buildNoDataMessage();
    }

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FadeInUp(
            duration: const Duration(milliseconds: 600),
            child: _buildInfoCard(
              'Basic Information',
              Icons.info_outline,
              [
                _buildInfoRow('Scientific Name',
                    speciesData!['scientific_name'] as String?),
                _buildInfoRow('Size', speciesData!['size'] as String?),
                _buildInfoRow('Lifespan', speciesData!['lifespan'] as String?),
                _buildInfoRow('Conservation Status',
                    speciesData!['conservation_status'] as String?),
              ],
            ),
          ),
          const SizedBox(height: 20),
          FadeInUp(
            duration: const Duration(milliseconds: 600),
            delay: const Duration(milliseconds: 200),
            child: _buildInfoCard(
              'Habitat & Range',
              Icons.place_outlined,
              [
                _buildInfoRow('Habitat', speciesData!['habitat'] as String?),
                _buildInfoRow('Range', speciesData!['range'] as String?),
              ],
            ),
          ),
          const SizedBox(height: 20),
          FadeInUp(
            duration: const Duration(milliseconds: 600),
            delay: const Duration(milliseconds: 400),
            child: _buildInfoCard(
              'Diet & Behavior',
              Icons.restaurant_outlined,
              [
                _buildInfoRow('Diet', speciesData!['diet'] as String?),
                _buildInfoRow('Interesting Fact',
                    speciesData!['interesting_fact'] as String?),
              ],
            ),
          ),
          const SizedBox(height: 20),
          if (speciesData != null && speciesData!['fun_facts'] != null)
            FadeInUp(
              duration: const Duration(milliseconds: 600),
              delay: const Duration(milliseconds: 600),
              child: _buildFunFactsCard(),
            ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(String title, IconData icon, List<Widget> children) {
    return Card(
      elevation: 8,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  icon,
                  color: Theme.of(context).colorScheme.primary,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value ?? 'Not available',
            style: TextStyle(
              fontSize: 16,
              height: 1.4,
              color: value != null ? null : Colors.grey.shade600,
              fontStyle: value != null ? null : FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFunFactsCard() {
    final funFactsData = speciesData!['fun_facts'];
    if (funFactsData == null) {
      return const SizedBox(); // Return empty widget if no fun facts
    }

    final funFacts = List<String>.from(funFactsData);

    return Card(
      elevation: 8,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.lightbulb_outline,
                  color: Theme.of(context).colorScheme.primary,
                  size: 24,
                ),
                const SizedBox(width: 12),
                const Text(
                  'Fun Facts',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...funFacts.asMap().entries.map((entry) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          '${entry.key + 1}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        entry.value,
                        style: const TextStyle(
                          fontSize: 16,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildNoDataMessage() {
    return Padding(
      padding: const EdgeInsets.all(40),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.search_off,
              size: 80,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'Species information not available',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'We don\'t have detailed information for "${widget.speciesName}" yet.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
