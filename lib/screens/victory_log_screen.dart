import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/database_service.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

/// Victory Log Screen - Track successful days (encrypted storage)
class VictoryLogScreen extends StatefulWidget {
  const VictoryLogScreen({super.key});

  @override
  State<VictoryLogScreen> createState() => _VictoryLogScreenState();
}

class _VictoryLogScreenState extends State<VictoryLogScreen> {
  final _authService = AuthService();
  final _databaseService = DatabaseService();
  final _notesController = TextEditingController();
  List<Map<String, dynamic>> _victoryLogs = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadVictoryLogs();
  }

  Future<void> _loadVictoryLogs() async {
    setState(() => _isLoading = true);

    try {
      final userId = await _authService.getCurrentUserId();
      if (userId != null) {
        final logs = await _databaseService.getVictoryLogs(userId);
        setState(() {
          _victoryLogs = logs;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading logs: $e')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _addVictoryLog() async {
    if (_notesController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter notes')),
      );
      return;
    }

    try {
      final userId = await _authService.getCurrentUserId();
      if (userId != null) {
        final now = DateTime.now();
        final id = await _databaseService.addVictoryLog(
          userId,
          now,
          notes: _notesController.text.trim(),
        );

        if (id != null) {
          _notesController.clear();
          await _loadVictoryLogs();
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Victory logged!'),
                backgroundColor: Colors.green,
              ),
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error logging victory: $e')),
        );
      }
    }
  }

  List<Map<String, int>> _getMonthlyData() {
    final monthCounts = <int, int>{};
    final now = DateTime.now();
    
    for (var i = 5; i >= 0; i--) {
      final month = DateTime(now.year, now.month - i, 1);
      monthCounts[month.month] = 0;
    }
    
    for (var log in _victoryLogs) {
      final date = DateTime.fromMillisecondsSinceEpoch(log['date'] as int);
      if (date.isAfter(DateTime(now.year, now.month - 5, 1))) {
        monthCounts[date.month] = (monthCounts[date.month] ?? 0) + 1;
      }
    }
    
    return monthCounts.entries
        .map((e) => {'month': e.key, 'count': e.value})
        .toList();
  }

  Widget _buildProgressChart() {
    if (_victoryLogs.isEmpty) return const SizedBox.shrink();
    
    final monthlyData = _getMonthlyData();
    final maxCount = monthlyData.map((e) => e['count']!).reduce((a, b) => a > b ? a : b);
    
    return Container(
      height: 200,
      padding: const EdgeInsets.all(16),
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: (maxCount + 5).toDouble(),
          barTouchData: BarTouchData(enabled: true),
          titlesData: FlTitlesData(
            show: true,
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  const months = ['', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
                  return Text(
                    months[value.toInt()],
                    style: const TextStyle(fontSize: 10),
                  );
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 30,
                getTitlesWidget: (value, meta) {
                  return Text(
                    value.toInt().toString(),
                    style: const TextStyle(fontSize: 10),
                  );
                },
              ),
            ),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: 5,
            getDrawingHorizontalLine: (value) {
              return FlLine(
                color: Colors.grey.shade300,
                strokeWidth: 1,
              );
            },
          ),
          borderData: FlBorderData(show: false),
          barGroups: monthlyData.asMap().entries.map((entry) {
            return BarChartGroupData(
              x: entry.value['month']!,
              barRods: [
                BarChartRodData(
                  toY: entry.value['count']!.toDouble(),
                  color: Colors.green.shade600,
                  width: 20,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Expanded(
                        child: Text(
                          'Victory Log',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      if (_victoryLogs.isNotEmpty)
                        IconButton(
                          icon: const Icon(Icons.delete_outline, color: Colors.red),
                          onPressed: _confirmDeleteAll,
                          tooltip: 'Delete all logs',
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Track your successful days\n(Encrypted local storage, no cloud)',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  
                  // Achievement badges
                  if (_victoryLogs.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    _buildAchievementBadges(),
                  ],
                  
                  const SizedBox(height: 16),
                  TextField(
                    controller: _notesController,
                    decoration: const InputDecoration(
                      labelText: 'Notes (what made this day successful?)',
                      prefixIcon: Icon(Icons.note),
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: _addVictoryLog,
                    icon: const Icon(Icons.add),
                    label: const Text('Log Victory'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: Colors.green.shade700,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            
            // Progress Chart
            if (_victoryLogs.isNotEmpty) ...[
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    Icon(Icons.bar_chart, color: Colors.blue),
                    SizedBox(width: 8),
                    Text(
                      'Monthly Progress',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Card(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                child: _buildProgressChart(),
              ),
            ],
            
            const Divider(),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _victoryLogs.isEmpty
                      ? const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.celebration,
                                size: 64,
                                color: Colors.grey,
                              ),
                              SizedBox(height: 16),
                              Text(
                                'No victory logs yet',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.grey,
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Start logging your successful days!',
                                style: TextStyle(
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _victoryLogs.length,
                          itemBuilder: (context, index) {
                            final log = _victoryLogs[index];
                            final date = DateTime.fromMillisecondsSinceEpoch(
                              log['date'] as int,
                            );
                            final notes = log['notes'] as String?;

                            return Card(
                              margin: const EdgeInsets.only(bottom: 12),
                              child: ListTile(
                                leading: const Icon(
                                  Icons.celebration,
                                  color: Colors.amber,
                                ),
                                title: Text(
                                  _formatDate(date),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                subtitle: notes != null && notes.isNotEmpty
                                    ? Text(notes)
                                    : const Text('No notes'),
                                trailing: const Icon(Icons.check_circle, color: Colors.green),
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildAchievementBadges() {
    final badges = <Widget>[];
    
    if (_victoryLogs.length >= 7) {
      badges.add(_buildBadge(Icons.star, '7 Days', Colors.blue));
    }
    if (_victoryLogs.length >= 30) {
      badges.add(_buildBadge(Icons.emoji_events, '30 Days', Colors.green));
    }
    if (_victoryLogs.length >= 90) {
      badges.add(_buildBadge(Icons.military_tech, '90 Days', Colors.orange));
    }
    if (_victoryLogs.length >= 365) {
      badges.add(_buildBadge(Icons.diamond, '1 Year', Colors.purple));
    }
    
    if (badges.isEmpty) return const SizedBox.shrink();
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.amber.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.workspace_premium, color: Colors.amber),
              SizedBox(width: 8),
              Text(
                'Achievements Unlocked',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: badges,
          ),
        ],
      ),
    );
  }
  
  Widget _buildBadge(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color, width: 2),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDeleteAll() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete All Victory Logs'),
        content: const Text(
          'Are you sure you want to delete all victory logs? This action cannot be undone. This will give you a fresh start.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete All'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _deleteAllLogs();
    }
  }

  Future<void> _deleteAllLogs() async {
    try {
      final userId = await _authService.getCurrentUserId();
      if (userId != null) {
        await _databaseService.clearVictoryLogs(userId);
        await _loadVictoryLogs();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('All victory logs deleted. Fresh start!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting logs: $e')),
        );
      }
    }
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }
}
