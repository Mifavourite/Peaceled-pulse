import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';

/// Beta Testing Service - Comprehensive feedback and bug tracking
class BetaTestingService {
  /// Collect comprehensive feedback with device info
  Future<bool> submitDetailedFeedback({
    required String category,
    required String message,
    required String severity,
    Map<String, dynamic>? metadata,
    Map<String, dynamic>? performanceData,
  }) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final feedbackDir = Directory(path.join(directory.path, 'beta_feedback'));
      
      if (!await feedbackDir.exists()) {
        await feedbackDir.create(recursive: true);
      }

      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final deviceInfo = await _getDeviceInfo();
      final appInfo = await _getAppInfo();
      
      final feedbackData = {
        'id': timestamp,
        'timestamp': DateTime.now().toIso8601String(),
        'category': category,
        'severity': severity,
        'message': message,
        'device_info': deviceInfo,
        'app_info': appInfo,
        'metadata': metadata ?? {},
        'performance': performanceData ?? {},
      };

      final fileName = 'feedback_$timestamp.json';
      final file = File(path.join(feedbackDir.path, fileName));
      
      await file.writeAsString(jsonEncode(feedbackData));

      return true;
    } catch (e) {
      debugPrint('Error saving detailed feedback: $e');
      return false;
    }
  }

  /// Report bug with automatic device info
  Future<bool> reportBug({
    required String description,
    required String stepsToReproduce,
    String? expectedBehavior,
    String? actualBehavior,
    String? severity,
    Map<String, dynamic>? screenshots,
  }) async {
    return await submitDetailedFeedback(
      category: 'bug',
      message: _formatBugReport(
        description: description,
        stepsToReproduce: stepsToReproduce,
        expectedBehavior: expectedBehavior,
        actualBehavior: actualBehavior,
      ),
      severity: severity ?? 'medium',
      metadata: {
        'type': 'bug_report',
        'steps_to_reproduce': stepsToReproduce,
        'expected_behavior': expectedBehavior ?? 'N/A',
        'actual_behavior': actualBehavior ?? 'N/A',
        'screenshots': screenshots ?? {},
      },
    );
  }

  /// Log performance issue
  Future<bool> logPerformanceIssue({
    required String description,
    required Map<String, dynamic> performanceMetrics,
    String? screen,
    String? action,
  }) async {
    return await submitDetailedFeedback(
      category: 'performance',
      message: description,
      severity: 'medium',
      metadata: {
        'type': 'performance_issue',
        'screen': screen ?? 'unknown',
        'action': action ?? 'unknown',
      },
      performanceData: performanceMetrics,
    );
  }

  /// Get device information for testing
  Future<Map<String, dynamic>> _getDeviceInfo() async {
    try {
      final deviceInfoPlugin = DeviceInfoPlugin();
      Map<String, dynamic> deviceData = {
        'platform': Platform.operatingSystem,
        'platform_version': Platform.operatingSystemVersion,
      };

      if (Platform.isAndroid) {
        final androidInfo = await deviceInfoPlugin.androidInfo;
        deviceData.addAll({
          'manufacturer': androidInfo.manufacturer,
          'model': androidInfo.model,
          'brand': androidInfo.brand,
          'device': androidInfo.device,
          'android_version': androidInfo.version.release,
          'sdk_int': androidInfo.version.sdkInt,
          'hardware': androidInfo.hardware,
          'screen_size': '${androidInfo.displayMetrics.widthPx}x${androidInfo.displayMetrics.heightPx}',
          'screen_density': androidInfo.displayMetrics.densityDpi,
        });
      } else if (Platform.isIOS) {
        final iosInfo = await deviceInfoPlugin.iosInfo;
        deviceData.addAll({
          'name': iosInfo.name,
          'model': iosInfo.model,
          'system_name': iosInfo.systemName,
          'system_version': iosInfo.systemVersion,
          'identifier_for_vendor': iosInfo.identifierForVendor,
        });
      }

      return deviceData;
    } catch (e) {
      return {'error': e.toString()};
    }
  }

  /// Get app information
  Future<Map<String, dynamic>> _getAppInfo() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      return {
        'app_name': packageInfo.appName,
        'package_name': packageInfo.packageName,
        'version': packageInfo.version,
        'build_number': packageInfo.buildNumber,
      };
    } catch (e) {
      return {'error': e.toString()};
    }
  }

  /// Format bug report
  String _formatBugReport({
    required String description,
    required String stepsToReproduce,
    String? expectedBehavior,
    String? actualBehavior,
  }) {
    final buffer = StringBuffer();
    buffer.writeln('**Bug Report**\n');
    buffer.writeln('**Description:**');
    buffer.writeln(description);
    buffer.writeln('\n**Steps to Reproduce:**');
    buffer.writeln(stepsToReproduce);
    if (expectedBehavior != null) {
      buffer.writeln('\n**Expected Behavior:**');
      buffer.writeln(expectedBehavior);
    }
    if (actualBehavior != null) {
      buffer.writeln('\n**Actual Behavior:**');
      buffer.writeln(actualBehavior);
    }
    return buffer.toString();
  }

  /// Get all feedback files for analysis
  Future<List<FeedbackFile>> getAllFeedbackFiles() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final feedbackDir = Directory(path.join(directory.path, 'beta_feedback'));
      
      if (!await feedbackDir.exists()) {
        return [];
      }
      
      final files = feedbackDir.listSync()
          .whereType<File>()
          .where((f) => f.path.endsWith('.json'))
          .map((f) => FeedbackFile(
                path: f.path,
                name: path.basename(f.path),
                size: f.lengthSync(),
                modified: f.lastModifiedSync(),
              ))
          .toList();
      
      files.sort((a, b) => b.modified.compareTo(a.modified));
      return files;
    } catch (e) {
      return [];
    }
  }

  /// Analyze feedback and generate summary
  Future<FeedbackSummary> analyzeFeedback() async {
    final files = await getAllFeedbackFiles();
    final List<Map<String, dynamic>> feedbacks = [];
    
    for (final file in files) {
      try {
        final content = await File(file.path).readAsString();
        final data = jsonDecode(content) as Map<String, dynamic>;
        feedbacks.add(data);
      } catch (e) {
        // Skip invalid files
      }
    }
    
    final categories = <String, int>{};
    final severities = <String, int>{};
    final devices = <String, int>{};
    
    for (final feedback in feedbacks) {
      final category = feedback['category'] as String? ?? 'unknown';
      final severity = feedback['severity'] as String? ?? 'unknown';
      final deviceInfo = feedback['device_info'] as Map<String, dynamic>?;
      
      categories[category] = (categories[category] ?? 0) + 1;
      severities[severity] = (severities[severity] ?? 0) + 1;
      
      if (deviceInfo != null) {
        final deviceKey = '${deviceInfo['manufacturer'] ?? 'unknown'}_${deviceInfo['model'] ?? 'unknown'}';
        devices[deviceKey] = (devices[deviceKey] ?? 0) + 1;
      }
    }
    
    return FeedbackSummary(
      totalFeedbacks: feedbacks.length,
      categories: categories,
      severities: severities,
      devices: devices,
      latestFeedback: feedbacks.isNotEmpty ? feedbacks.first : null,
    );
  }

  /// Export feedback summary for analysis
  Future<String> exportFeedbackSummary() async {
    final summary = await analyzeFeedback();
    final buffer = StringBuffer();
    
    buffer.writeln('=== BETA TESTING FEEDBACK SUMMARY ===\n');
    buffer.writeln('Generated: ${DateTime.now().toIso8601String()}\n');
    buffer.writeln('Total Feedbacks: ${summary.totalFeedbacks}\n');
    
    buffer.writeln('--- Categories ---');
    summary.categories.forEach((key, value) {
      buffer.writeln('$key: $value');
    });
    buffer.writeln('');
    
    buffer.writeln('--- Severities ---');
    summary.severities.forEach((key, value) {
      buffer.writeln('$key: $value');
    });
    buffer.writeln('');
    
    buffer.writeln('--- Test Devices ---');
    summary.devices.forEach((key, value) {
      buffer.writeln('$key: $value feedback(s)');
    });
    
    return buffer.toString();
  }

  /// Clear all feedback (for testing)
  Future<bool> clearAllFeedback() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final feedbackDir = Directory(path.join(directory.path, 'beta_feedback'));
      
      if (await feedbackDir.exists()) {
        await feedbackDir.delete(recursive: true);
      }
      
      return true;
    } catch (e) {
      return false;
    }
  }
}

// Data classes
class FeedbackFile {
  final String path;
  final String name;
  final int size;
  final DateTime modified;

  FeedbackFile({
    required this.path,
    required this.name,
    required this.size,
    required this.modified,
  });
}

class FeedbackSummary {
  final int totalFeedbacks;
  final Map<String, int> categories;
  final Map<String, int> severities;
  final Map<String, int> devices;
  final Map<String, dynamic>? latestFeedback;

  FeedbackSummary({
    required this.totalFeedbacks,
    required this.categories,
    required this.severities,
    required this.devices,
    this.latestFeedback,
  });
}

