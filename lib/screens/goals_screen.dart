import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/auth_service.dart';
import '../services/database_service.dart';

/// Goals Screen - Set and track short/long-term goals
class GoalsScreen extends StatefulWidget {
  const GoalsScreen({super.key});

  @override
  State<GoalsScreen> createState() => _GoalsScreenState();
}

class _GoalsScreenState extends State<GoalsScreen> {
  final _authService = AuthService();
  final _databaseService = DatabaseService();
  
  List<Map<String, dynamic>> _goals = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadGoals();
  }

  Future<void> _loadGoals() async {
    setState(() => _isLoading = true);
    try {
      final userId = await _authService.getCurrentUserId();
      if (userId != null) {
        final goals = await _databaseService.getGoals(userId);
        setState(() {
          _goals = goals;
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _addGoal() async {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    DateTime? targetDate;
    String goalType = 'short'; // short or long

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('New Goal'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    labelText: 'Goal Title',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: goalType,
                  decoration: const InputDecoration(
                    labelText: 'Goal Type',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'short', child: Text('Short-term (1-3 months)')),
                    DropdownMenuItem(value: 'long', child: Text('Long-term (6+ months)')),
                  ],
                  onChanged: (value) {
                    setDialogState(() => goalType = value!);
                  },
                ),
                const SizedBox(height: 12),
                ListTile(
                  title: Text(
                    targetDate == null
                        ? 'Select Target Date (Optional)'
                        : 'Target: ${DateFormat('MMM d, yyyy').format(targetDate)}',
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.calendar_today),
                    onPressed: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now().add(const Duration(days: 30)),
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                      );
                      if (picked != null) {
                        setDialogState(() => targetDate = picked);
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Create'),
            ),
          ],
        ),
      ),
    );

    if (result == true && titleController.text.trim().isNotEmpty) {
      try {
        final userId = await _authService.getCurrentUserId();
        if (userId != null) {
          await _databaseService.addGoal(
            userId,
            titleController.text.trim(),
            descriptionController.text.trim(),
            goalType,
            targetDate,
          );
          await _loadGoals();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error creating goal: $e')),
          );
        }
      }
    }
  }

  Future<void> _toggleGoalComplete(String goalId, bool currentStatus) async {
    try {
      final userId = await _authService.getCurrentUserId();
      if (userId != null) {
        await _databaseService.updateGoalStatus(userId, goalId, !currentStatus);
        await _loadGoals();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating goal: $e')),
        );
      }
    }
  }

  Future<void> _deleteGoal(String goalId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Goal'),
        content: const Text('Are you sure you want to delete this goal?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final userId = await _authService.getCurrentUserId();
        if (userId != null) {
          await _databaseService.deleteGoal(userId, goalId);
          await _loadGoals();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error deleting goal: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final activeGoals = _goals.where((g) => g['completed'] == 0).toList();
    final completedGoals = _goals.where((g) => g['completed'] == 1).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Goals'),
        backgroundColor: const Color(0xFF6366F1),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _addGoal,
            tooltip: 'New Goal',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Stats
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
                      _buildStatItem('Active', '${activeGoals.length}', Icons.flag),
                      _buildStatItem('Completed', '${completedGoals.length}', Icons.check_circle),
                      _buildStatItem('Total', '${_goals.length}', Icons.track_changes),
                    ],
                  ),
                ),

                // Active Goals
                if (activeGoals.isNotEmpty) ...[
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        const Icon(Icons.flag, color: Color(0xFF6366F1)),
                        const SizedBox(width: 8),
                        const Text(
                          'Active Goals',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: activeGoals.length,
                      itemBuilder: (context, index) {
                        return _buildGoalCard(activeGoals[index], false);
                      },
                    ),
                  ),
                ],

                // Completed Goals
                if (completedGoals.isNotEmpty) ...[
                  const Divider(),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        const Icon(Icons.check_circle, color: Colors.green),
                        const SizedBox(width: 8),
                        const Text(
                          'Completed Goals',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: completedGoals.length,
                      itemBuilder: (context, index) {
                        return _buildGoalCard(completedGoals[index], true);
                      },
                    ),
                  ),
                ],

                // Empty state
                if (_goals.isEmpty)
                  Expanded(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.flag, size: 64, color: Colors.grey),
                          const SizedBox(height: 16),
                          const Text(
                            'No goals yet',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Set goals to track your progress',
                            style: TextStyle(color: Colors.grey),
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton.icon(
                            onPressed: _addGoal,
                            icon: const Icon(Icons.add),
                            label: const Text('Create Your First Goal'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF6366F1),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
      floatingActionButton: _goals.isNotEmpty
          ? FloatingActionButton(
              onPressed: _addGoal,
              backgroundColor: const Color(0xFF6366F1),
              child: const Icon(Icons.add, color: Colors.white),
            )
          : null,
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
            fontSize: 24,
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

  Widget _buildGoalCard(Map<String, dynamic> goal, bool isCompleted) {
    final createdDate = DateTime.fromMillisecondsSinceEpoch(goal['created_at'] as int);
    final targetDate = goal['target_date'] != null
        ? DateTime.fromMillisecondsSinceEpoch(goal['target_date'] as int)
        : null;
    final isOverdue = targetDate != null && 
        !isCompleted && 
        targetDate.isBefore(DateTime.now());

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: isCompleted 
          ? Colors.green.shade50 
          : isOverdue 
              ? Colors.orange.shade50 
              : Colors.white,
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Checkbox(
          value: isCompleted,
          onChanged: (value) => _toggleGoalComplete(
            goal['id'].toString(),
            isCompleted,
          ),
        ),
        title: Text(
          goal['title'] as String,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            decoration: isCompleted ? TextDecoration.lineThrough : null,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (goal['description'] != null && (goal['description'] as String).isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(goal['description'] as String),
            ],
            const SizedBox(height: 8),
            Row(
              children: [
                Chip(
                  label: Text(
                    goal['type'] == 'short' ? 'Short-term' : 'Long-term',
                    style: const TextStyle(fontSize: 11),
                  ),
                  backgroundColor: const Color(0xFF6366F1).withOpacity(0.1),
                ),
                if (targetDate != null) ...[
                  const SizedBox(width: 8),
                  Chip(
                    label: Text(
                      isOverdue 
                          ? 'Overdue'
                          : 'Due: ${DateFormat('MMM d').format(targetDate)}',
                      style: const TextStyle(fontSize: 11),
                    ),
                    backgroundColor: isOverdue 
                        ? Colors.orange.withOpacity(0.1)
                        : Colors.blue.withOpacity(0.1),
                  ),
                ],
              ],
            ),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete, color: Colors.red),
          onPressed: () => _deleteGoal(goal['id'].toString()),
        ),
      ),
    );
  }
}
