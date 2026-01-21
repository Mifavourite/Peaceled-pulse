import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/auth_service.dart';
import '../services/database_service.dart';
import '../services/schedule_service.dart';

/// Schedule/Timetable Screen - Create and track daily schedules
class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  final _scheduleService = ScheduleService();
  final _authService = AuthService();
  final _databaseService = DatabaseService();
  
  Map<String, Map<String, String>> _schedule = {};
  Map<String, Map<String, bool>> _completions = {};
  String _selectedDay = 'Monday';
  bool _isLoading = true;
  double _todayPercentage = 0.0;
  int _todayPoints = 0;
  
  final List<String> _days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
  final List<String> _timeSlots = [
    '1:00 AM', '2:00 AM', '3:00 AM', '4:00 AM', '5:00 AM', '6:00 AM',
    '7:00 AM', '8:00 AM', '9:00 AM', '10:00 AM', '11:00 AM', '12:00 PM',
    '1:00 PM', '2:00 PM', '3:00 PM', '4:00 PM', '5:00 PM', '6:00 PM',
    '7:00 PM', '8:00 PM', '9:00 PM', '10:00 PM', '11:00 PM', '12:00 AM'
  ];

  @override
  void initState() {
    super.initState();
    _selectedDay = _getCurrentDay();
    _loadSchedule();
  }

  String _getCurrentDay() {
    final now = DateTime.now();
    return _days[now.weekday - 1];
  }

  Future<void> _loadSchedule() async {
    setState(() => _isLoading = true);
    try {
      final userId = await _authService.getCurrentUserId();
      if (userId != null) {
        final schedule = await _scheduleService.getSchedule(userId);
        final completions = await _scheduleService.getTodayCompletions(userId);
        final stats = await _scheduleService.getTodayStats(userId);
        
        setState(() {
          _schedule = schedule;
          _completions = completions;
          _todayPercentage = stats['percentage'] ?? 0.0;
          _todayPoints = stats['points'] ?? 0;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _saveActivity(String day, String timeSlot, String activity) async {
    try {
      final userId = await _authService.getCurrentUserId();
      if (userId != null) {
        await _scheduleService.saveActivity(userId, day, timeSlot, activity);
        await _loadSchedule();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving: $e')),
        );
      }
    }
  }

  Future<void> _toggleCompletion(String day, String timeSlot) async {
    try {
      final userId = await _authService.getCurrentUserId();
      if (userId != null) {
        final isCompleted = _completions[day]?[timeSlot] ?? false;
        await _scheduleService.markCompletion(userId, day, timeSlot, !isCompleted);
        await _loadSchedule();
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(!isCompleted ? '✓ Activity completed! +10 points' : 'Activity unchecked'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Schedule'),
        backgroundColor: const Color(0xFF6366F1),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.emoji_events),
            onPressed: () => _showTrophies(),
            tooltip: 'View Trophies',
          ),
          IconButton(
            icon: const Icon(Icons.bar_chart),
            onPressed: () => _showStats(),
            tooltip: 'View Stats',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Stats Card
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFF6366F1).withOpacity(0.1),
                        const Color(0xFF8B5CF6).withOpacity(0.05),
                      ],
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatItem('Today', '${_todayPercentage.toStringAsFixed(1)}%', Icons.today),
                      _buildStatItem('Points', '$_todayPoints', Icons.star),
                      _buildStatItem('Completed', '${_getCompletedCount()}/${_getTotalCount()}', Icons.check_circle),
                    ],
                  ),
                ),
                
                // Day Selector
                Container(
                  height: 50,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _days.length,
                    itemBuilder: (context, index) {
                      final day = _days[index];
                      final isSelected = day == _selectedDay;
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: FilterChip(
                          label: Text(day.substring(0, 3)),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() => _selectedDay = day);
                          },
                          selectedColor: const Color(0xFF6366F1).withOpacity(0.2),
                        ),
                      );
                    },
                  ),
                ),
                
                // Schedule List
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(8),
                    itemCount: _timeSlots.length,
                    itemBuilder: (context, index) {
                      final timeSlot = _timeSlots[index];
                      final activity = _schedule[_selectedDay]?[timeSlot] ?? '';
                      final isCompleted = _completions[_selectedDay]?[timeSlot] ?? false;
                      
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        color: isCompleted ? Colors.green.shade50 : Colors.white,
                        child: ListTile(
                          leading: Checkbox(
                            value: isCompleted,
                            onChanged: (value) => _toggleCompletion(_selectedDay, timeSlot),
                          ),
                          title: Text(
                            timeSlot,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: isCompleted 
                                  ? const Color(0xFF10B981) 
                                  : const Color(0xFF6366F1),
                            ),
                          ),
                          subtitle: activity.isEmpty
                              ? const Text(
                                  'Tap to add activity',
                                  style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey),
                                )
                              : Text(activity),
                          trailing: IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () => _editActivity(timeSlot, activity),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: const Color(0xFF6366F1)),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF6366F1),
          ),
        ),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
        ),
      ],
    );
  }

  int _getCompletedCount() {
    final dayCompletions = _completions[_selectedDay] ?? {};
    return dayCompletions.values.where((v) => v).length;
  }

  int _getTotalCount() {
    final daySchedule = _schedule[_selectedDay] ?? {};
    return daySchedule.values.where((v) => v.isNotEmpty).length;
  }

  Future<void> _editActivity(String timeSlot, String currentActivity) async {
    final controller = TextEditingController(text: currentActivity);
    
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Activity for $timeSlot'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'Enter activity...',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(controller.text),
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (result != null) {
      await _saveActivity(_selectedDay, timeSlot, result);
    }
  }

  Future<void> _showTrophies() async {
    final userId = await _authService.getCurrentUserId();
    if (userId == null) return;

    final trophies = await _scheduleService.getTrophies(userId);
    
    if (mounted) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('🏆 Monthly Trophies'),
          content: SizedBox(
            width: double.maxFinite,
            child: trophies.isEmpty
                ? const Text('No trophies yet. Maintain 90%+ schedule excellence to earn trophies!')
                : ListView.builder(
                    shrinkWrap: true,
                    itemCount: trophies.length,
                    itemBuilder: (context, index) {
                      final trophy = trophies[index];
                      return ListTile(
                        leading: const Icon(Icons.emoji_events, color: Colors.amber, size: 32),
                        title: Text(trophy['month'] as String),
                        subtitle: Text('${trophy['percentage']}% completion'),
                        trailing: Text('${trophy['points']} pts'),
                      );
                    },
                  ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        ),
      );
    }
  }

  Future<void> _showStats() async {
    final userId = await _authService.getCurrentUserId();
    if (userId == null) return;

    final monthlyStats = await _scheduleService.getMonthlyStats(userId);
    
    if (mounted) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('📊 Schedule Statistics'),
          content: SizedBox(
            width: double.maxFinite,
            child: monthlyStats.isEmpty
                ? const Text('No statistics yet. Start tracking your schedule!')
                : ListView.builder(
                    shrinkWrap: true,
                    itemCount: monthlyStats.length,
                    itemBuilder: (context, index) {
                      final stat = monthlyStats[index];
                      return Card(
                        child: ListTile(
                          title: Text(stat['month'] as String),
                          subtitle: Text('${stat['percentage']}% average'),
                          trailing: Text('${stat['points']} pts'),
                        ),
                      );
                    },
                  ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        ),
      );
    }
  }
}
