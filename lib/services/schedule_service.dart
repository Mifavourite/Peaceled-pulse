import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:intl/intl.dart';

/// Schedule Service - Manages timetable, tracking, points, and trophies
class ScheduleService {
  SharedPreferences? _prefs;

  Future<void> _ensureInitialized() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  /// Save activity for a specific day and time slot
  Future<void> saveActivity(int userId, String day, String timeSlot, String activity) async {
    await _ensureInitialized();
    final key = 'schedule_$userId';
    final scheduleJson = _prefs!.getString(key) ?? '{}';
    final schedule = jsonDecode(scheduleJson) as Map<String, dynamic>;
    
    if (!schedule.containsKey(day)) {
      schedule[day] = <String, dynamic>{};
    }
    (schedule[day] as Map<String, dynamic>)[timeSlot] = activity;
    
    await _prefs!.setString(key, jsonEncode(schedule));
  }

  /// Get full schedule
  Future<Map<String, Map<String, String>>> getSchedule(int userId) async {
    await _ensureInitialized();
    final key = 'schedule_$userId';
    final scheduleJson = _prefs!.getString(key) ?? '{}';
    final schedule = jsonDecode(scheduleJson) as Map<String, dynamic>;
    
    final result = <String, Map<String, String>>{};
    schedule.forEach((day, activities) {
      result[day] = Map<String, String>.from(activities as Map);
    });
    
    return result;
  }

  /// Mark activity as completed
  Future<void> markCompletion(int userId, String day, String timeSlot, bool completed) async {
    await _ensureInitialized();
    final dateKey = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final key = 'completions_$userId_$dateKey';
    final completionsJson = _prefs!.getString(key) ?? '{}';
    final completions = jsonDecode(completionsJson) as Map<String, dynamic>;
    
    if (!completions.containsKey(day)) {
      completions[day] = <String, dynamic>{};
    }
    (completions[day] as Map<String, dynamic>)[timeSlot] = completed;
    
    await _prefs!.setString(key, jsonEncode(completions));
    
    // Award points
    if (completed) {
      await _awardPoints(userId, 10);
    }
  }

  /// Get today's completions
  Future<Map<String, Map<String, bool>>> getTodayCompletions(int userId) async {
    await _ensureInitialized();
    final dateKey = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final key = 'completions_$userId_$dateKey';
    final completionsJson = _prefs!.getString(key) ?? '{}';
    final completions = jsonDecode(completionsJson) as Map<String, dynamic>;
    
    final result = <String, Map<String, bool>>{};
    completions.forEach((day, activities) {
      result[day] = Map<String, bool>.from(
        (activities as Map).map((k, v) => MapEntry(k.toString(), v as bool)),
      );
    });
    
    return result;
  }

  /// Award points
  Future<void> _awardPoints(int userId, int points) async {
    await _ensureInitialized();
    final dateKey = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final key = 'points_$userId_$dateKey';
    final currentPoints = _prefs!.getInt(key) ?? 0;
    await _prefs!.setInt(key, currentPoints + points);
  }

  /// Get today's stats
  Future<Map<String, dynamic>> getTodayStats(int userId) async {
    await _ensureInitialized();
    final schedule = await getSchedule(userId);
    final completions = await getTodayCompletions(userId);
    
    final today = _getCurrentDay();
    final daySchedule = schedule[today] ?? {};
    final dayCompletions = completions[today] ?? {};
    
    int total = daySchedule.values.where((v) => v.isNotEmpty).length;
    int completed = dayCompletions.values.where((v) => v).length;
    
    final percentage = total > 0 ? (completed / total * 100) : 0.0;
    
    final dateKey = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final pointsKey = 'points_$userId_$dateKey';
    final points = _prefs!.getInt(pointsKey) ?? 0;
    
    return {
      'percentage': percentage,
      'points': points,
      'completed': completed,
      'total': total,
    };
  }

  String _getCurrentDay() {
    final now = DateTime.now();
    final days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    return days[now.weekday - 1];
  }

  /// Get monthly statistics
  Future<List<Map<String, dynamic>>> getMonthlyStats(int userId) async {
    await _ensureInitialized();
    final now = DateTime.now();
    final stats = <Map<String, dynamic>>[];
    
    // Get last 6 months
    for (int i = 0; i < 6; i++) {
      final month = DateTime(now.year, now.month - i, 1);
      final monthKey = DateFormat('yyyy-MM').format(month);
      final monthName = DateFormat('MMMM yyyy').format(month);
      
      // Calculate monthly average
      double totalPercentage = 0.0;
      int totalPoints = 0;
      int daysWithData = 0;
      
      for (int day = 1; day <= 31; day++) {
        try {
          final date = DateTime(month.year, month.month, day);
          if (date.month != month.month) break;
          
          final dateKey = DateFormat('yyyy-MM-dd').format(date);
          final completionsKey = 'completions_$userId_$dateKey';
          final pointsKey = 'points_$userId_$dateKey';
          
          final completionsJson = _prefs!.getString(completionsKey);
          final points = _prefs!.getInt(pointsKey) ?? 0;
          
          if (completionsJson != null) {
            final schedule = await getSchedule(userId);
            final dayName = _getDayName(date.weekday);
            final daySchedule = schedule[dayName] ?? {};
            final dayCompletions = jsonDecode(completionsJson) as Map<String, dynamic>;
            final dayCompletionsMap = (dayCompletions[dayName] as Map?) ?? {};
            
            int total = daySchedule.values.where((v) => v.isNotEmpty).length;
            int completed = dayCompletionsMap.values.where((v) => v == true).length;
            
            if (total > 0) {
              totalPercentage += (completed / total * 100);
              daysWithData++;
            }
            totalPoints += points;
          }
        } catch (e) {
          // Skip invalid dates
        }
      }
      
      final avgPercentage = daysWithData > 0 ? (totalPercentage / daysWithData) : 0.0;
      
      // Check if earned trophy (90%+)
      if (avgPercentage >= 90.0) {
        stats.add({
          'month': monthName,
          'percentage': avgPercentage.toStringAsFixed(1),
          'points': totalPoints,
          'trophy': true,
        });
      } else {
        stats.add({
          'month': monthName,
          'percentage': avgPercentage.toStringAsFixed(1),
          'points': totalPoints,
          'trophy': false,
        });
      }
    }
    
    return stats.reversed.toList();
  }

  /// Get trophies (months with 90%+ completion)
  Future<List<Map<String, dynamic>>> getTrophies(int userId) async {
    final stats = await getMonthlyStats(userId);
    return stats.where((s) => s['trophy'] == true).toList();
  }

  String _getDayName(int weekday) {
    const days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    return days[weekday - 1];
  }
}
