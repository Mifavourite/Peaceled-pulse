import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/database_service.dart';
import 'dart:math' as math;
import 'daily_checkin_screen.dart';
import 'emergency_support_screen.dart';
import 'values_screen.dart';

/// Motivational Dashboard Screen - Shows progress, streak, and encouragement
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> with SingleTickerProviderStateMixin {
  final _authService = AuthService();
  final _databaseService = DatabaseService();
  
  int _streakDays = 0;
  int _totalVictories = 0;
  bool _isLoading = true;
  late AnimationController _animationController;
  
  final List<Map<String, dynamic>> _motivationalQuotes = [
    {
      'quote': 'Every day is a new opportunity to be better',
      'icon': Icons.wb_sunny,
      'color': Colors.orange,
    },
    {
      'quote': 'Your strength is greater than any struggle',
      'icon': Icons.fitness_center,
      'color': Colors.blue,
    },
    {
      'quote': 'Progress, not perfection',
      'icon': Icons.trending_up,
      'color': Colors.green,
    },
    {
      'quote': 'You are worthy of recovery',
      'icon': Icons.favorite,
      'color': Colors.pink,
    },
    {
      'quote': 'One day at a time, one moment at a time',
      'icon': Icons.access_time,
      'color': Colors.purple,
    },
  ];
  
  late Map<String, dynamic> _currentQuote;

  @override
  void initState() {
    super.initState();
    _currentQuote = _motivationalQuotes[math.Random().nextInt(_motivationalQuotes.length)];
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
    _loadDashboardData();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadDashboardData() async {
    setState(() => _isLoading = true);

    try {
      final userId = await _authService.getCurrentUserId();
      if (userId != null) {
        final logs = await _databaseService.getVictoryLogs(userId);
        final streak = _calculateStreak(logs);
        
        setState(() {
          _totalVictories = logs.length;
          _streakDays = streak;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading dashboard: $e')),
        );
      }
    }
  }

  int _calculateStreak(List<Map<String, dynamic>> logs) {
    if (logs.isEmpty) return 0;

    // Sort logs by date (newest first)
    logs.sort((a, b) => (b['date'] as int).compareTo(a['date'] as int));

    int streak = 0;
    DateTime now = DateTime.now();
    DateTime today = DateTime(now.year, now.month, now.day);

    for (var log in logs) {
      DateTime logDate = DateTime.fromMillisecondsSinceEpoch(log['date'] as int);
      DateTime logDay = DateTime(logDate.year, logDate.month, logDate.day);

      // Check if this log is for today or the expected streak day
      DateTime expectedDate = today.subtract(Duration(days: streak));
      
      if (logDay.isAtSameMomentAs(expectedDate)) {
        streak++;
      } else if (logDay.isBefore(expectedDate)) {
        // Gap in the streak
        break;
      }
    }

    return streak;
  }

  String _getStreakMessage() {
    if (_streakDays == 0) return 'Start your journey today!';
    if (_streakDays == 1) return 'Great start! Keep going!';
    if (_streakDays < 7) return 'Building momentum!';
    if (_streakDays < 30) return 'Strong progress!';
    if (_streakDays < 90) return 'Incredible dedication!';
    return 'You\'re unstoppable!';
  }

  Color _getStreakColor() {
    if (_streakDays == 0) return Colors.grey;
    if (_streakDays < 7) return Colors.blue;
    if (_streakDays < 30) return Colors.green;
    if (_streakDays < 90) return Colors.orange;
    return Colors.purple;
  }

  Widget _buildMilestoneCard(int milestone, String title, IconData icon) {
    final achieved = _streakDays >= milestone;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: achieved ? Colors.amber.shade50 : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: achieved ? Colors.amber.shade400 : Colors.grey.shade300,
          width: 2,
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            size: 32,
            color: achieved ? Colors.amber.shade700 : Colors.grey.shade400,
          ),
          const SizedBox(height: 8),
          Text(
            '$milestone\ndays',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: achieved ? Colors.amber.shade900 : Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11,
              color: achieved ? Colors.amber.shade800 : Colors.grey.shade500,
            ),
          ),
          if (achieved)
            const Icon(
              Icons.check_circle,
              color: Colors.green,
              size: 20,
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadDashboardData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Welcome Header
                    const Text(
                      'Your Recovery Journey',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      DateTime.now().toString().split(' ')[0],
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey.shade600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    
                    const SizedBox(height: 24),

                    // Streak Counter - Main Feature
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            _getStreakColor().withOpacity(0.8),
                            _getStreakColor(),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: _getStreakColor().withOpacity(0.3),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          AnimatedBuilder(
                            animation: _animationController,
                            builder: (context, child) {
                              return Transform.scale(
                                scale: 1.0 + (math.sin(_animationController.value * 2 * math.pi) * 0.05),
                                child: child,
                              );
                            },
                            child: Text(
                              '$_streakDays',
                              style: const TextStyle(
                                fontSize: 72,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                shadows: [
                                  Shadow(
                                    color: Colors.black26,
                                    offset: Offset(2, 2),
                                    blurRadius: 4,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const Text(
                            'Day Streak',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _getStreakMessage(),
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                              fontStyle: FontStyle.italic,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Quick Stats Row
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            'Total\nVictories',
                            '$_totalVictories',
                            Icons.emoji_events,
                            Colors.amber,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildStatCard(
                            'This\nWeek',
                            '${_getThisWeekCount()}',
                            Icons.calendar_today,
                            Colors.blue,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Motivational Quote Card
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: _currentQuote['color'].withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: _currentQuote['color'].withOpacity(0.3),
                          width: 2,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            _currentQuote['icon'],
                            size: 40,
                            color: _currentQuote['color'],
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Text(
                              _currentQuote['quote'],
                              style: TextStyle(
                                fontSize: 16,
                                fontStyle: FontStyle.italic,
                                color: Colors.grey.shade800,
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Milestone Progress
                    const Text(
                      'Milestones',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _buildMilestoneCard(
                            7,
                            'First\nWeek',
                            Icons.looks_one,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _buildMilestoneCard(
                            30,
                            'One\nMonth',
                            Icons.star,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _buildMilestoneCard(
                            90,
                            'Three\nMonths',
                            Icons.military_tech,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _buildMilestoneCard(
                            365,
                            'One\nYear',
                            Icons.diamond,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Quick Actions
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => const DailyCheckInScreen(),
                                ),
                              );
                            },
                            icon: const Icon(Icons.check_circle_outline),
                            label: const Text('Check-In'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue.shade600,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => const EmergencySupportScreen(),
                                ),
                              );
                            },
                            icon: const Icon(Icons.phone_in_talk),
                            label: const Text('Support'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red.shade600,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // Values Quick Action
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const ValuesScreen(),
                          ),
                        );
                      },
                      icon: const Icon(Icons.favorite),
                      label: const Text('Save My Values'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.purple.shade600,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: Column(
        children: [
          Icon(icon, size: 32, color: color),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade700,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }

  int _getThisWeekCount() {
    final now = DateTime.now();
    final weekStart = DateTime(now.year, now.month, now.day).subtract(Duration(days: now.weekday - 1));
    final weekStartMs = weekStart.millisecondsSinceEpoch;
    
    // Count logs from this week
    int count = 0;
    for (var log in _victoryLogs) {
      final logDate = log['date'] as int;
      if (logDate >= weekStartMs) {
        count++;
      }
    }
    return count;
  }
}
