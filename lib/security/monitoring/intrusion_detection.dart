import 'dart:collection';

/// Intrusion Detection System
class IntrusionDetectionService {
  final Queue<SecurityEvent> _eventLog = Queue();
  final Map<String, int> _failedAttempts = {};
  final Map<String, DateTime> _blockedIPs = {};
  
  static const int maxFailedAttempts = 5;
  static const Duration blockDuration = Duration(minutes: 15);
  static const int maxLogSize = 1000;

  /// Log security event
  void logEvent(SecurityEvent event) {
    _eventLog.addLast(event);
    
    // Maintain log size
    if (_eventLog.length > maxLogSize) {
      _eventLog.removeFirst();
    }

    // Check for intrusion patterns
    _analyzeEvent(event);
  }

  /// Check if IP is blocked
  bool isBlocked(String identifier) {
    final blockedUntil = _blockedIPs[identifier];
    if (blockedUntil == null) return false;
    
    if (DateTime.now().isAfter(blockedUntil)) {
      _blockedIPs.remove(identifier);
      return false;
    }
    
    return true;
  }

  /// Get security events
  List<SecurityEvent> getEvents({int? limit}) {
    final events = _eventLog.toList().reversed.toList();
    if (limit != null) {
      return events.take(limit).toList();
    }
    return events;
  }

  /// Get security statistics
  Map<String, dynamic> getStatistics() {
    final now = DateTime.now();
    final last24Hours = now.subtract(const Duration(hours: 24));
    
    final recentEvents = _eventLog.where((e) => e.timestamp.isAfter(last24Hours)).toList();
    
    return {
      'totalEvents': _eventLog.length,
      'recentEvents': recentEvents.length,
      'blockedIPs': _blockedIPs.length,
      'failedAttempts': _failedAttempts.length,
      'threats': recentEvents.where((e) => e.severity == SecuritySeverity.critical).length,
      'warnings': recentEvents.where((e) => e.severity == SecuritySeverity.warning).length,
    };
  }

  void _analyzeEvent(SecurityEvent event) {
    if (event.type == SecurityEventType.failedAuth) {
      final identifier = event.identifier ?? 'unknown';
      _failedAttempts[identifier] = (_failedAttempts[identifier] ?? 0) + 1;
      
      if (_failedAttempts[identifier]! >= maxFailedAttempts) {
        _blockIP(identifier);
        logEvent(SecurityEvent(
          type: SecurityEventType.intrusionDetected,
          severity: SecuritySeverity.critical,
          message: 'Multiple failed attempts from $identifier',
          identifier: identifier,
        ));
      }
    }
  }

  void _blockIP(String identifier) {
    _blockedIPs[identifier] = DateTime.now().add(blockDuration);
    _failedAttempts.remove(identifier);
  }

  /// Clear event log
  void clearLog() {
    _eventLog.clear();
  }

  /// Reset failed attempts for identifier
  void resetFailedAttempts(String identifier) {
    _failedAttempts.remove(identifier);
  }
}

enum SecurityEventType {
  failedAuth,
  suspiciousActivity,
  intrusionDetected,
  dataBreach,
  unauthorizedAccess,
  configurationChange,
}

enum SecuritySeverity {
  info,
  warning,
  critical,
}

class SecurityEvent {
  final SecurityEventType type;
  final SecuritySeverity severity;
  final String message;
  final DateTime timestamp;
  final String? identifier;
  final Map<String, dynamic>? metadata;

  SecurityEvent({
    required this.type,
    required this.severity,
    required this.message,
    DateTime? timestamp,
    this.identifier,
    this.metadata,
  }) : timestamp = timestamp ?? DateTime.now();
}
