import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/database_service.dart';

/// Daily Check-in Screen - Track mood and triggers
class DailyCheckInScreen extends StatefulWidget {
  const DailyCheckInScreen({super.key});

  @override
  State<DailyCheckInScreen> createState() => _DailyCheckInScreenState();
}

class _DailyCheckInScreenState extends State<DailyCheckInScreen> {
  final _authService = AuthService();
  final _databaseService = DatabaseService();
  final _notesController = TextEditingController();
  
  String? _selectedMood;
  final List<String> _selectedTriggers = [];
  bool _isSubmitting = false;
  
  final Map<String, Map<String, dynamic>> _moods = {
    'great': {
      'emoji': '😊',
      'label': 'Great',
      'color': Colors.green,
    },
    'good': {
      'emoji': '🙂',
      'label': 'Good',
      'color': Colors.lightGreen,
    },
    'okay': {
      'emoji': '😐',
      'label': 'Okay',
      'color': Colors.amber,
    },
    'struggling': {
      'emoji': '😔',
      'label': 'Struggling',
      'color': Colors.orange,
    },
    'difficult': {
      'emoji': '😰',
      'label': 'Very Difficult',
      'color': Colors.red,
    },
  };
  
  final List<Map<String, dynamic>> _commonTriggers = [
    {'id': 'stress', 'label': 'Stress', 'icon': Icons.work},
    {'id': 'loneliness', 'label': 'Loneliness', 'icon': Icons.person_off},
    {'id': 'boredom', 'label': 'Boredom', 'icon': Icons.schedule},
    {'id': 'anxiety', 'label': 'Anxiety', 'icon': Icons.psychology},
    {'id': 'anger', 'label': 'Anger', 'icon': Icons.mood_bad},
    {'id': 'tiredness', 'label': 'Tiredness', 'icon': Icons.bedtime},
    {'id': 'social', 'label': 'Social Pressure', 'icon': Icons.people},
    {'id': 'environment', 'label': 'Environment', 'icon': Icons.location_on},
  ];

  Future<void> _submitCheckIn() async {
    if (_selectedMood == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select your mood')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final userId = await _authService.getCurrentUserId();
      if (userId != null) {
        // Store check-in in database
        final checkInData = {
          'user_id': userId,
          'mood': _selectedMood,
          'triggers': _selectedTriggers.join(','),
          'notes': _notesController.text.trim(),
          'timestamp': DateTime.now().millisecondsSinceEpoch,
        };
        
        await _databaseService.database.then((db) => db.insert('check_ins', checkInData));
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Check-in saved! Keep going!'),
              backgroundColor: Colors.green,
            ),
          );
          
          // Reset form
          setState(() {
            _selectedMood = null;
            _selectedTriggers.clear();
            _notesController.clear();
          });
          
          // Navigate back
          Navigator.of(context).pop();
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving check-in: $e')),
        );
      }
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daily Check-In'),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Encouraging header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue.shade100, Colors.blue.shade50],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Column(
                children: [
                  Icon(Icons.favorite, size: 40, color: Colors.pink),
                  SizedBox(height: 12),
                  Text(
                    'How are you doing today?',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Checking in with yourself is a powerful act of self-care',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.black54,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Mood Selection
            const Text(
              'How are you feeling?',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _moods.entries.map((mood) {
                final isSelected = _selectedMood == mood.key;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedMood = mood.key;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: isSelected 
                          ? mood.value['color'].withOpacity(0.2)
                          : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected 
                            ? mood.value['color']
                            : Colors.grey.shade300,
                        width: isSelected ? 3 : 1,
                      ),
                    ),
                    child: Column(
                      children: [
                        Text(
                          mood.value['emoji'],
                          style: const TextStyle(fontSize: 32),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          mood.value['label'],
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
            
            const SizedBox(height: 24),
            
            // Trigger Selection
            const Text(
              'Any triggers or challenges today?',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Identifying triggers helps build awareness',
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _commonTriggers.map((trigger) {
                final isSelected = _selectedTriggers.contains(trigger['id']);
                return FilterChip(
                  label: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        trigger['icon'],
                        size: 16,
                        color: isSelected ? Colors.white : Colors.black54,
                      ),
                      const SizedBox(width: 4),
                      Text(trigger['label']),
                    ],
                  ),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _selectedTriggers.add(trigger['id']);
                      } else {
                        _selectedTriggers.remove(trigger['id']);
                      }
                    });
                  },
                  selectedColor: Colors.blue.shade600,
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : Colors.black87,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                );
              }).toList(),
            ),
            
            const SizedBox(height: 24),
            
            // Notes
            const Text(
              'Additional notes (optional)',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _notesController,
              decoration: InputDecoration(
                hintText: 'How are you managing? What\'s on your mind?',
                border: const OutlineInputBorder(),
                filled: true,
                fillColor: Colors.grey.shade50,
              ),
              maxLines: 5,
            ),
            
            const SizedBox(height: 24),
            
            // Coping suggestions based on mood
            if (_selectedMood != null && 
                (_selectedMood == 'struggling' || _selectedMood == 'difficult'))
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.orange.shade300, width: 2),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.lightbulb, color: Colors.orange.shade700),
                        const SizedBox(width: 8),
                        const Text(
                          'Coping Strategies',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildCopingTip('Take 5 deep breaths', Icons.air),
                    _buildCopingTip('Call your support person', Icons.phone),
                    _buildCopingTip('Go for a walk', Icons.directions_walk),
                    _buildCopingTip('Use the emergency support screen', Icons.phone_in_talk),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.of(context).pushNamed('/emergency');
                      },
                      icon: const Icon(Icons.phone_in_talk),
                      label: const Text('Get Support Now'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red.shade600,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            
            const SizedBox(height: 24),
            
            // Submit button
            ElevatedButton.icon(
              onPressed: _isSubmitting ? null : _submitCheckIn,
              icon: _isSubmitting 
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Icon(Icons.check_circle),
              label: Text(_isSubmitting ? 'Saving...' : 'Complete Check-In'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green.shade700,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                textStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
  
  Widget _buildCopingTip(String tip, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.orange.shade700),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              tip,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }
}
