import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'database_service.dart';
import 'auth_service.dart';

/// Service for exporting user data and progress reports
class ExportService {
  final DatabaseService _databaseService = DatabaseService();
  final AuthService _authService = AuthService();

  /// Generate a comprehensive progress report as JSON
  Future<Map<String, dynamic>> generateProgressReport() async {
    final userId = await _authService.getCurrentUserId();
    if (userId == null) {
      throw Exception('User not authenticated');
    }

    // Get all user data
    final victoryLogs = await _databaseService.getVictoryLogs(userId);
    final values = await _databaseService.getUserValues(userId);
    final detectionLogs = await _databaseService.getDetectionLogs(userId);
    
    // Get check-ins
    final db = await _databaseService.database;
    final checkIns = await db.query(
      'check_ins',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'timestamp DESC',
    );

    // Calculate statistics
    final stats = await _calculateStatistics(userId, victoryLogs, checkIns);

    return {
      'export_date': DateTime.now().toIso8601String(),
      'user_id': userId,
      'statistics': stats,
      'core_values': values,
      'victory_logs': victoryLogs.map((log) => {
        'date': DateTime.fromMillisecondsSinceEpoch(log['date'] as int).toIso8601String(),
        'notes': log['notes'],
      }).toList(),
      'check_ins': checkIns.map((checkIn) => {
        'timestamp': DateTime.fromMillisecondsSinceEpoch(checkIn['timestamp'] as int).toIso8601String(),
        'mood': checkIn['mood'],
        'triggers': checkIn['triggers'],
        'notes': checkIn['notes'],
      }).toList(),
      'total_detections': detectionLogs.length,
    };
  }

  Future<Map<String, dynamic>> _calculateStatistics(
    int userId,
    List<Map<String, dynamic>> victoryLogs,
    List<Map<String, dynamic>> checkIns,
  ) async {
    // Calculate streak
    int streak = 0;
    if (victoryLogs.isNotEmpty) {
      victoryLogs.sort((a, b) => (b['date'] as int).compareTo(a['date'] as int));
      DateTime now = DateTime.now();
      DateTime today = DateTime(now.year, now.month, now.day);

      for (var log in victoryLogs) {
        DateTime logDate = DateTime.fromMillisecondsSinceEpoch(log['date'] as int);
        DateTime logDay = DateTime(logDate.year, logDate.month, logDate.day);
        DateTime expectedDate = today.subtract(Duration(days: streak));
        
        if (logDay.isAtSameMomentAs(expectedDate)) {
          streak++;
        } else if (logDay.isBefore(expectedDate)) {
          break;
        }
      }
    }

    // Calculate mood trends
    final moodCounts = <String, int>{};
    for (var checkIn in checkIns) {
      final mood = checkIn['mood'] as String?;
      if (mood != null) {
        moodCounts[mood] = (moodCounts[mood] ?? 0) + 1;
      }
    }

    // Calculate trigger frequency
    final triggerCounts = <String, int>{};
    for (var checkIn in checkIns) {
      final triggers = checkIn['triggers'] as String?;
      if (triggers != null && triggers.isNotEmpty) {
        final triggerList = triggers.split(',');
        for (var trigger in triggerList) {
          triggerCounts[trigger] = (triggerCounts[trigger] ?? 0) + 1;
        }
      }
    }

    // Calculate milestones achieved
    final milestones = {
      '7_days': victoryLogs.length >= 7,
      '30_days': victoryLogs.length >= 30,
      '90_days': victoryLogs.length >= 90,
      '365_days': victoryLogs.length >= 365,
    };

    return {
      'current_streak': streak,
      'total_victories': victoryLogs.length,
      'total_check_ins': checkIns.length,
      'mood_distribution': moodCounts,
      'common_triggers': triggerCounts,
      'milestones_achieved': milestones,
      'longest_streak': streak, // TODO: Calculate actual longest streak
    };
  }

  /// Export progress report as JSON file
  Future<String> exportAsJSON() async {
    final report = await generateProgressReport();
    final jsonString = const JsonEncoder.withIndent('  ').convert(report);
    
    // Get app documents directory
    final directory = await getApplicationDocumentsDirectory();
    final filePath = '${directory.path}/recovery_progress_${DateTime.now().millisecondsSinceEpoch}.json';
    
    // Write to file
    final file = File(filePath);
    await file.writeAsString(jsonString);
    
    return filePath;
  }

  /// Export progress report as readable text
  Future<String> exportAsText() async {
    final report = await generateProgressReport();
    final stats = report['statistics'] as Map<String, dynamic>;
    
    final buffer = StringBuffer();
    buffer.writeln('═══════════════════════════════════════════');
    buffer.writeln('      RECOVERY PROGRESS REPORT');
    buffer.writeln('═══════════════════════════════════════════');
    buffer.writeln();
    buffer.writeln('Export Date: ${report['export_date']}');
    buffer.writeln();
    buffer.writeln('───────────────────────────────────────────');
    buffer.writeln('STATISTICS');
    buffer.writeln('───────────────────────────────────────────');
    buffer.writeln('Current Streak: ${stats['current_streak']} days');
    buffer.writeln('Total Victories: ${stats['total_victories']}');
    buffer.writeln('Total Check-ins: ${stats['total_check_ins']}');
    buffer.writeln();
    
    // Milestones
    buffer.writeln('───────────────────────────────────────────');
    buffer.writeln('MILESTONES ACHIEVED');
    buffer.writeln('───────────────────────────────────────────');
    final milestones = stats['milestones_achieved'] as Map<String, dynamic>;
    if (milestones['7_days'] == true) buffer.writeln('✓ 7 Days');
    if (milestones['30_days'] == true) buffer.writeln('✓ 30 Days');
    if (milestones['90_days'] == true) buffer.writeln('✓ 90 Days');
    if (milestones['365_days'] == true) buffer.writeln('✓ 1 Year');
    buffer.writeln();
    
    // Core values
    final values = report['core_values'] as List;
    if (values.isNotEmpty) {
      buffer.writeln('───────────────────────────────────────────');
      buffer.writeln('CORE VALUES');
      buffer.writeln('───────────────────────────────────────────');
      for (int i = 0; i < values.length; i++) {
        buffer.writeln('${i + 1}. ${values[i]}');
      }
      buffer.writeln();
    }
    
    // Mood distribution
    final moodDist = stats['mood_distribution'] as Map<String, dynamic>;
    if (moodDist.isNotEmpty) {
      buffer.writeln('───────────────────────────────────────────');
      buffer.writeln('MOOD TRENDS');
      buffer.writeln('───────────────────────────────────────────');
      moodDist.forEach((mood, count) {
        buffer.writeln('$mood: $count times');
      });
      buffer.writeln();
    }
    
    // Common triggers
    final triggers = stats['common_triggers'] as Map<String, dynamic>;
    if (triggers.isNotEmpty) {
      buffer.writeln('───────────────────────────────────────────');
      buffer.writeln('COMMON TRIGGERS');
      buffer.writeln('───────────────────────────────────────────');
      final sortedTriggers = triggers.entries.toList()
        ..sort((a, b) => (b.value as int).compareTo(a.value as int));
      for (var entry in sortedTriggers.take(5)) {
        buffer.writeln('${entry.key}: ${entry.value} times');
      }
      buffer.writeln();
    }
    
    buffer.writeln('═══════════════════════════════════════════');
    buffer.writeln('      Keep going! You\'re doing great!');
    buffer.writeln('═══════════════════════════════════════════');
    
    // Write to file
    final directory = await getApplicationDocumentsDirectory();
    final filePath = '${directory.path}/recovery_report_${DateTime.now().millisecondsSinceEpoch}.txt';
    final file = File(filePath);
    await file.writeAsString(buffer.toString());
    
    return filePath;
  }

  /// Share progress report
  Future<void> shareProgressReport({bool asText = true}) async {
    final filePath = asText ? await exportAsText() : await exportAsJSON();
    
    await Share.shareXFiles(
      [XFile(filePath)],
      subject: 'My Recovery Progress Report',
      text: 'Sharing my recovery progress',
    );
  }

  /// Backup all data
  Future<String> createBackup() async {
    final report = await generateProgressReport();
    final jsonString = const JsonEncoder.withIndent('  ').convert(report);
    
    final directory = await getApplicationDocumentsDirectory();
    final filePath = '${directory.path}/recovery_backup_${DateTime.now().millisecondsSinceEpoch}.json';
    
    final file = File(filePath);
    await file.writeAsString(jsonString);
    
    return filePath;
  }
}
