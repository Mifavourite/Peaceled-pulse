import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import '../services/auth_service.dart';

/// Feedback Service for Beta Testing
/// Stores feedback locally (no external transmission per security requirements)
class FeedbackService {
  final AuthService _authService = AuthService();
  
  /// Save feedback to local file
  Future<bool> submitFeedback({
    required String category,
    required String message,
    String? severity,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final feedbackDir = Directory(path.join(directory.path, 'beta_feedback'));
      
      if (!await feedbackDir.exists()) {
        await feedbackDir.create(recursive: true);
      }

      final userId = await _authService.getCurrentUserId();
      final timestamp = DateTime.now().toIso8601String();
      final timestampForFile = DateTime.now().millisecondsSinceEpoch;
      
      final feedbackData = {
        'id': timestampForFile,
        'userId': userId,
        'timestamp': timestamp,
        'category': category,
        'severity': severity ?? 'info',
        'message': message,
        'metadata': metadata ?? {},
      };

      final fileName = 'feedback_$timestampForFile.json';
      final file = File(path.join(feedbackDir.path, fileName));
      
      await file.writeAsString(_formatFeedbackJson(feedbackData));

      return true;
    } catch (e) {
      debugPrint('Error saving feedback: $e');
      return false;
    }
  }

  /// Get all feedback files (for export)
  Future<List<File>> getAllFeedbackFiles() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final feedbackDir = Directory(path.join(directory.path, 'beta_feedback'));
      
      if (!await feedbackDir.exists()) {
        return [];
      }

      final files = feedbackDir.listSync()
          .whereType<File>()
          .where((f) => f.path.endsWith('.json'))
          .toList();
      
      return files;
    } catch (e) {
      debugPrint('Error getting feedback files: $e');
      return [];
    }
  }

  /// Get feedback directory path for sharing
  Future<String> getFeedbackDirectoryPath() async {
    final directory = await getApplicationDocumentsDirectory();
    return path.join(directory.path, 'beta_feedback');
  }

  /// Format feedback as JSON string
  String _formatFeedbackJson(Map<String, dynamic> data) {
    final buffer = StringBuffer();
    buffer.writeln('{');
    buffer.writeln('  "id": ${data['id']},');
    buffer.writeln('  "userId": ${data['userId'] ?? 'null'},');
    buffer.writeln('  "timestamp": "${data['timestamp']}",');
    buffer.writeln('  "category": "${data['category']}",');
    buffer.writeln('  "severity": "${data['severity']}",');
    buffer.writeln('  "message": "${_escapeJson(data['message'])}",');
    buffer.writeln('  "metadata": {');
    if (data['metadata'] != null && data['metadata'] is Map) {
      final metadata = data['metadata'] as Map<String, dynamic>;
      final entries = metadata.entries.toList();
      for (int i = 0; i < entries.length; i++) {
        final entry = entries[i];
        final isLast = i == entries.length - 1;
        buffer.writeln('    "${entry.key}": "${_escapeJson(entry.value.toString())}"${isLast ? '' : ','}');
      }
    }
    buffer.writeln('  }');
    buffer.writeln('}');
    return buffer.toString();
  }

  String _escapeJson(String str) {
    return str
        .replaceAll('\\', '\\\\')
        .replaceAll('"', '\\"')
        .replaceAll('\n', '\\n')
        .replaceAll('\r', '\\r')
        .replaceAll('\t', '\\t');
  }
}
