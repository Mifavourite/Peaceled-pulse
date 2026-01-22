import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../services/auth_service.dart';
import '../services/database_service.dart';
import '../services/schedule_service.dart';

/// Progress Analytics Screen - Detailed charts and insights
class ProgressAnalyticsScreen extends StatefulWidget {
  const ProgressAnalyticsScreen({super.key});

  @override
  State<ProgressAnalyticsScreen> createState() => _ProgressAnalyticsScreenState();
}

class _ProgressAnalyticsScreenState extends State<ProgressAnalyticsScreen> {
  final _authService = AuthService();
  final _databaseService = DatabaseService();
  final _scheduleService = ScheduleService();
  
  bool _isLoading = true;
  Map<String, dynamic> _stats = {};

  @override
  void initState() {
    super.initState();
    _loadAnalytics();
  }

  Future<void> _loadAnalytics() async {
    setState(() => _isLoading = true);
    try {
      final userId = await _authService.getCurrentUserId();
      if (userId != null) {
        final victoryLogs = await _databaseService.getVictoryLogs(userId);
        final checkIns = await _databaseService.getCheckIns(userId);
        final scheduleStats = await _scheduleService.getMonthlyStats(userId);
        
        // Calculate mood distribution
        final moodCounts = <String, int>{};
        for (var checkIn in checkIns) {
          try {
            final mood = checkIn['mood'] as String? ?? 'Unknown';
            moodCounts[mood] = (moodCounts[mood] ?? 0) + 1;
          } catch (e) {
            // Skip invalid check-ins
          }
        }

        // Calculate weekly victory trend
        final weeklyVictories = <int, int>{};
        for (var log in victoryLogs) {
          try {
            final dateMs = log['date'] as int?;
            if (dateMs != null) {
              final date = DateTime.fromMillisecondsSinceEpoch(dateMs);
              final weekStart = date.subtract(Duration(days: date.weekday - 1));
              final weekKey = weekStart.millisecondsSinceEpoch ~/ (1000 * 60 * 60 * 24 * 7);
              weeklyVictories[weekKey] = (weeklyVictories[weekKey] ?? 0) + 1;
            }
          } catch (e) {
            // Skip invalid logs
          }
        }

        setState(() {
          _stats = {
            'victoryLogs': victoryLogs,
            'checkIns': checkIns,
            'moodCounts': moodCounts,
            'weeklyVictories': weeklyVictories,
            'scheduleStats': scheduleStats,
            'totalVictories': victoryLogs.length,
            'totalCheckIns': checkIns.length,
            'avgScheduleCompletion': scheduleStats.isNotEmpty
                ? scheduleStats.map((s) => double.parse(s['percentage'] as String)).reduce((a, b) => a + b) / scheduleStats.length
                : 0.0,
          };
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Progress Analytics'),
        backgroundColor: const Color(0xFF6366F1),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadAnalytics,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Summary Cards
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          'Total Victories',
                          '${_stats['totalVictories'] ?? 0}',
                          Icons.emoji_events,
                          const Color(0xFFF59E0B),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatCard(
                          'Check-Ins',
                          '${_stats['totalCheckIns'] ?? 0}',
                          Icons.check_circle,
                          const Color(0xFF10B981),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          'Schedule Avg',
                          '${(_stats['avgScheduleCompletion'] ?? 0.0).toStringAsFixed(1)}%',
                          Icons.schedule,
                          const Color(0xFF6366F1),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatCard(
                          'Active Days',
                          '${_calculateActiveDays()}',
                          Icons.calendar_today,
                          const Color(0xFF8B5CF6),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Mood Distribution Chart
                  if ((_stats['moodCounts'] as Map).isNotEmpty) ...[
                    const Text(
                      'Mood Distribution',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: SizedBox(
                          height: 200,
                          child: PieChart(
                            PieChartData(
                              sections: _buildMoodSections(),
                              sectionsSpace: 2,
                              centerSpaceRadius: 40,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Weekly Victory Trend
                  if ((_stats['weeklyVictories'] as Map).isNotEmpty) ...[
                    const Text(
                      'Weekly Victory Trend',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: SizedBox(
                          height: 200,
                          child: LineChart(
                            LineChartData(
                              gridData: FlGridData(show: true),
                              titlesData: FlTitlesData(show: true),
                              borderData: FlBorderData(show: true),
                              lineBarsData: [
                                LineChartBarData(
                                  spots: _buildWeeklySpots(),
                                  isCurved: true,
                                  color: const Color(0xFF6366F1),
                                  barWidth: 3,
                                  dotData: FlDotData(show: true),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Monthly Schedule Performance
                  if ((_stats['scheduleStats'] as List).isNotEmpty) ...[
                    const Text(
                      'Monthly Schedule Performance',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: SizedBox(
                          height: 200,
                          child: BarChart(
                            BarChartData(
                              alignment: BarChartAlignment.spaceAround,
                              maxY: 100,
                              barTouchData: BarTouchData(enabled: true),
                              titlesData: FlTitlesData(show: true),
                              gridData: FlGridData(show: true),
                              borderData: FlBorderData(show: false),
                              barGroups: _buildScheduleBarGroups(),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              label,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  List<PieChartSectionData> _buildMoodSections() {
    final moodCounts = _stats['moodCounts'] as Map<String, int>;
    if (moodCounts.isEmpty) return [];
    
    final total = moodCounts.values.reduce((a, b) => a + b);
    if (total == 0) return [];
    
    final colors = [
      const Color(0xFF10B981), // Great
      const Color(0xFF6366F1), // Good
      const Color(0xFFF59E0B), // Okay
      const Color(0xFFEF4444), // Difficult
      const Color(0xFF991B1B), // Very Difficult
    ];
    
    int colorIndex = 0;
    return moodCounts.entries.map((entry) {
      final percentage = total > 0 ? (entry.value / total * 100) : 0.0;
      final section = PieChartSectionData(
        value: percentage,
        title: '${percentage.toStringAsFixed(1)}%',
        color: colors[colorIndex % colors.length],
        radius: 60,
      );
      colorIndex++;
      return section;
    }).toList();
  }

  List<FlSpot> _buildWeeklySpots() {
    final weeklyVictories = _stats['weeklyVictories'] as Map<int, int>;
    if (weeklyVictories.isEmpty) return [];
    
    final sortedWeeks = weeklyVictories.keys.toList()..sort();
    return sortedWeeks.asMap().entries.map((entry) {
      final weekKey = entry.value;
      final count = weeklyVictories[weekKey] ?? 0;
      return FlSpot(entry.key.toDouble(), count.toDouble());
    }).toList();
  }

  List<BarChartGroupData> _buildScheduleBarGroups() {
    final scheduleStats = _stats['scheduleStats'] as List<Map<String, dynamic>>;
    if (scheduleStats.isEmpty) return [];
    
    return scheduleStats.asMap().entries.map((entry) {
      final stat = entry.value;
      final percentageStr = stat['percentage'] as String? ?? '0';
      final percentage = double.tryParse(percentageStr) ?? 0.0;
      return BarChartGroupData(
        x: entry.key,
        barRods: [
          BarChartRodData(
            toY: percentage,
            color: percentage >= 90 
                ? const Color(0xFF10B981)
                : percentage >= 70
                    ? const Color(0xFFF59E0B)
                    : const Color(0xFFEF4444),
            width: 20,
          ),
        ],
      );
    }).toList();
  }

  int _calculateActiveDays() {
    final victoryLogs = _stats['victoryLogs'] as List? ?? [];
    final checkIns = _stats['checkIns'] as List? ?? [];
    final allDates = <int>{};
    
    for (var log in victoryLogs) {
      try {
        final dateMs = log['date'] as int?;
        if (dateMs != null) {
          final date = DateTime.fromMillisecondsSinceEpoch(dateMs);
          allDates.add(DateTime(date.year, date.month, date.day).millisecondsSinceEpoch);
        }
      } catch (e) {
        // Skip invalid entries
      }
    }
    
    for (var checkIn in checkIns) {
      try {
        final timestamp = checkIn['timestamp'] as int?;
        if (timestamp != null) {
          final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
          allDates.add(DateTime(date.year, date.month, date.day).millisecondsSinceEpoch);
        }
      } catch (e) {
        // Skip invalid entries
      }
    }
    
    return allDates.length;
  }
}
