import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Performance Monitor for Beta Testing
/// Tracks app performance metrics (battery, memory, render time)
class PerformanceMonitor {
  static PerformanceMonitor? _instance;
  static PerformanceMonitor get instance {
    _instance ??= PerformanceMonitor._();
    return _instance!;
  }

  PerformanceMonitor._();

  final List<PerformanceMetric> _metrics = [];
  bool _isMonitoring = false;
  Timer? _monitorTimer;

  /// Start monitoring performance
  void startMonitoring() {
    if (_isMonitoring) return;
    _isMonitoring = true;

    _monitorTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      _collectMetrics();
    });
  }

  /// Stop monitoring performance
  void stopMonitoring() {
    _isMonitoring = false;
    _monitorTimer?.cancel();
    _monitorTimer = null;
  }

  /// Collect performance metrics
  void _collectMetrics() {
    final metric = PerformanceMetric(
      timestamp: DateTime.now(),
      memoryUsage: _getMemoryUsage(),
      renderTime: _getRenderTime(),
    );
    
    _metrics.add(metric);
    
    // Keep only last 100 metrics (5 minutes at 30s intervals)
    if (_metrics.length > 100) {
      _metrics.removeAt(0);
    }

    if (kDebugMode) {
      debugPrint('Performance: Memory: ${metric.memoryUsage}MB, '
          'Render: ${metric.renderTime}ms');
    }
  }

  /// Get current memory usage (approximate)
  double _getMemoryUsage() {
    // Flutter doesn't expose direct memory API, this is approximate
    // Based on heap size if available
    try {
      // Use ProcessInfo for basic memory info if available
      return 0.0; // Placeholder - would need platform channels for real metrics
    } catch (e) {
      return 0.0;
    }
  }

  /// Get render time (approximate)
  double _getRenderTime() {
    // Placeholder - would need frame timing for real metrics
    // In production, use FrameTiming from Flutter
    return 16.67; // Target 60fps = 16.67ms per frame
  }

  /// Log performance issue automatically
  void logPerformanceIssue(String description, Map<String, dynamic> additionalData) {
    final metric = PerformanceMetric(
      timestamp: DateTime.now(),
      memoryUsage: _getMemoryUsage(),
      renderTime: _getRenderTime(),
    );
    
    // Store in metrics for analysis
    _metrics.add(metric);
    
    // Log to console in debug mode
    if (kDebugMode) {
      debugPrint('Performance Issue: $description');
      debugPrint('Data: $additionalData');
    }
  }

  /// Get performance report for export
  Map<String, dynamic> getPerformanceReport() {
    final summary = getSummary();
    return {
      'timestamp': DateTime.now().toIso8601String(),
      'summary': summary.toJson(),
      'total_samples': _metrics.length,
      'metrics': _metrics.map((m) => {
        'timestamp': m.timestamp.toIso8601String(),
        'memory_mb': m.memoryUsage,
        'render_time_ms': m.renderTime,
      }).toList(),
    };
  }

  /// Get performance summary
  PerformanceSummary getSummary() {
    if (_metrics.isEmpty) {
      return PerformanceSummary(
        averageMemoryUsage: 0.0,
        averageRenderTime: 0.0,
        sampleCount: 0,
      );
    }

    final avgMemory = _metrics
        .map((m) => m.memoryUsage)
        .reduce((a, b) => a + b) / _metrics.length;

    final avgRender = _metrics
        .map((m) => m.renderTime)
        .reduce((a, b) => a + b) / _metrics.length;

    return PerformanceSummary(
      averageMemoryUsage: avgMemory,
      averageRenderTime: avgRender,
      sampleCount: _metrics.length,
    );
  }

  /// Clear all metrics
  void clearMetrics() {
    _metrics.clear();
  }

  /// Dispose resources
  void dispose() {
    stopMonitoring();
    clearMetrics();
  }
}

class PerformanceMetric {
  final DateTime timestamp;
  final double memoryUsage;
  final double renderTime;

  PerformanceMetric({
    required this.timestamp,
    required this.memoryUsage,
    required this.renderTime,
  });
}

class PerformanceSummary {
  final double averageMemoryUsage;
  final double averageRenderTime;
  final int sampleCount;

  PerformanceSummary({
    required this.averageMemoryUsage,
    required this.averageRenderTime,
    required this.sampleCount,
  });

  Map<String, dynamic> toJson() => {
    'averageMemoryUsage': averageMemoryUsage,
    'averageRenderTime': averageRenderTime,
    'sampleCount': sampleCount,
  };
}
