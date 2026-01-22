import 'package:flutter/material.dart';

/// Resources Library Screen - Helpful articles, videos, and Bible study materials
class ResourcesScreen extends StatefulWidget {
  const ResourcesScreen({super.key});

  @override
  State<ResourcesScreen> createState() => _ResourcesScreenState();
}

class _ResourcesScreenState extends State<ResourcesScreen> {
  String _selectedCategory = 'All';

  final List<Map<String, dynamic>> _resources = [
    {
      'title': 'Understanding Addiction from a Biblical Perspective',
      'category': 'Bible Study',
      'type': 'Article',
      'description': 'Learn how Scripture addresses addiction and recovery',
      'icon': Icons.menu_book,
      'color': const Color(0xFF6366F1),
    },
    {
      'title': 'Daily Devotional: Strength in Weakness',
      'category': 'Devotional',
      'type': 'Reading',
      'description': '2 Corinthians 12:9 - Finding strength through God\'s grace',
      'icon': Icons.favorite,
      'color': const Color(0xFFEF4444),
    },
    {
      'title': 'Prayer Guide for Recovery',
      'category': 'Prayer',
      'type': 'Guide',
      'description': 'Structured prayers for each stage of recovery',
      'icon': Icons.prayer,
      'color': const Color(0xFF10B981),
    },
    {
      'title': 'Overcoming Temptation: Practical Steps',
      'category': 'Practical',
      'type': 'Guide',
      'description': 'Biblical strategies for resisting temptation',
      'icon': Icons.shield,
      'color': const Color(0xFFF59E0B),
    },
    {
      'title': 'Building Healthy Habits',
      'category': 'Practical',
      'type': 'Article',
      'description': 'Scripture-based approach to forming good habits',
      'icon': Icons.trending_up,
      'color': const Color(0xFF8B5CF6),
    },
    {
      'title': 'Forgiveness and Self-Compassion',
      'category': 'Bible Study',
      'type': 'Study',
      'description': 'Understanding God\'s forgiveness and extending it to yourself',
      'icon': Icons.self_improvement,
      'color': const Color(0xFF6366F1),
    },
    {
      'title': 'Accountability: Finding Support',
      'category': 'Practical',
      'type': 'Guide',
      'description': 'How to build and maintain accountability relationships',
      'icon': Icons.people,
      'color': const Color(0xFF10B981),
    },
    {
      'title': 'Scripture Memory Verses for Recovery',
      'category': 'Bible Study',
      'type': 'Memory',
      'description': 'Key verses to memorize for strength and encouragement',
      'icon': Icons.psychology,
      'color': const Color(0xFF8B5CF6),
    },
  ];

  final List<String> _categories = ['All', 'Bible Study', 'Devotional', 'Prayer', 'Practical'];

  List<Map<String, dynamic>> get _filteredResources {
    if (_selectedCategory == 'All') {
      return _resources;
    }
    return _resources.where((r) => r['category'] == _selectedCategory).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Resources Library'),
        backgroundColor: const Color(0xFF6366F1),
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Category Filter
          Container(
            height: 50,
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final category = _categories[index];
                final isSelected = category == _selectedCategory;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: FilterChip(
                    label: Text(category),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() => _selectedCategory = category);
                    },
                    selectedColor: const Color(0xFF6366F1).withOpacity(0.2),
                  ),
                );
              },
            ),
          ),

          // Resources List
          Expanded(
            child: _filteredResources.isEmpty
                ? const Center(
                    child: Text('No resources in this category'),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _filteredResources.length,
                    itemBuilder: (context, index) {
                      final resource = _filteredResources[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(16),
                          leading: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: (resource['color'] as Color).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              resource['icon'] as IconData,
                              color: resource['color'] as Color,
                              size: 24,
                            ),
                          ),
                          title: Text(
                            resource['title'] as String,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),
                              Text(resource['description'] as String),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Chip(
                                    label: Text(
                                      resource['category'] as String,
                                      style: const TextStyle(fontSize: 11),
                                    ),
                                    backgroundColor: Colors.grey.shade200,
                                  ),
                                  const SizedBox(width: 8),
                                  Chip(
                                    label: Text(
                                      resource['type'] as String,
                                      style: const TextStyle(fontSize: 11),
                                    ),
                                    backgroundColor: (resource['color'] as Color).withOpacity(0.1),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                          onTap: () {
                            _showResourceDetails(resource);
                          },
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  void _showResourceDetails(Map<String, dynamic> resource) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(resource['icon'] as IconData, color: resource['color'] as Color),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                resource['title'] as String,
                style: const TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                resource['description'] as String,
                style: const TextStyle(fontSize: 16, height: 1.5),
              ),
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 16),
              const Text(
                'This resource is available in the full version of the app. For now, use the Chat feature to get personalized guidance and Bible verses.',
                style: TextStyle(fontSize: 14, fontStyle: FontStyle.italic),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pushNamed('/chat');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6366F1),
              foregroundColor: Colors.white,
            ),
            child: const Text('Go to Chat'),
          ),
        ],
      ),
    );
  }
}
