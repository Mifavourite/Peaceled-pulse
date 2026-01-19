import 'dart:collection';

/// Behavior Analytics Service for anomaly detection
class BehaviorAnalyticsService {
  final Map<String, UserBehaviorProfile> _profiles = {};
  final Queue<BehaviorEvent> _eventHistory = Queue();

  /// Record user behavior event
  void recordEvent(BehaviorEvent event) {
    _eventHistory.addLast(event);
    
    // Maintain history size
    if (_eventHistory.length > 10000) {
      _eventHistory.removeFirst();
    }

    // Update user profile
    _updateProfile(event);
  }

  /// Analyze behavior for anomalies
  AnomalyResult analyzeBehavior(String userId) {
    final profile = _profiles[userId];
    if (profile == null) {
      return AnomalyResult(isAnomalous: false, score: 0.0, reasons: []);
    }

    final recentEvents = _getRecentEvents(userId, Duration(hours: 1));
    final anomalies = <String>[];
    double anomalyScore = 0.0;

    // Check login time patterns
    final currentHour = DateTime.now().hour;
    if (!profile.typicalLoginHours.contains(currentHour)) {
      anomalies.add('Unusual login time');
      anomalyScore += 0.3;
    }

    // Check location patterns
    if (recentEvents.isNotEmpty) {
      final lastLocation = recentEvents.last.location;
      if (lastLocation != null && !profile.typicalLocations.contains(lastLocation)) {
        anomalies.add('Unusual location');
        anomalyScore += 0.4;
      }
    }

    // Check action frequency
    final actionCounts = <String, int>{};
    for (final event in recentEvents) {
      actionCounts[event.action] = (actionCounts[event.action] ?? 0) + 1;
    }

    for (final entry in actionCounts.entries) {
      final typicalFreq = profile.typicalActionFrequencies[entry.key] ?? 0;
      if (entry.value > typicalFreq * 2) {
        anomalies.add('Unusual ${entry.key} frequency');
        anomalyScore += 0.2;
      }
    }

    return AnomalyResult(
      isAnomalous: anomalyScore > 0.5,
      score: anomalyScore,
      reasons: anomalies,
    );
  }

  /// Get user behavior profile
  UserBehaviorProfile? getProfile(String userId) {
    return _profiles[userId];
  }

  void _updateProfile(BehaviorEvent event) {
    final profile = _profiles.putIfAbsent(
      event.userId,
      () => UserBehaviorProfile(userId: event.userId),
    );

    // Update login hours
    final hour = event.timestamp.hour;
    if (!profile.typicalLoginHours.contains(hour)) {
      profile.typicalLoginHours.add(hour);
    }

    // Update locations
    if (event.location != null) {
      if (!profile.typicalLocations.contains(event.location!)) {
        profile.typicalLocations.add(event.location!);
      }
    }

    // Update action frequencies
    profile.typicalActionFrequencies[event.action] =
        (profile.typicalActionFrequencies[event.action] ?? 0) + 1;
  }

  List<BehaviorEvent> _getRecentEvents(String userId, Duration duration) {
    final cutoff = DateTime.now().subtract(duration);
    return _eventHistory
        .where((e) => e.userId == userId && e.timestamp.isAfter(cutoff))
        .toList();
  }
}

class BehaviorEvent {
  final String userId;
  final String action;
  final DateTime timestamp;
  final String? location;
  final Map<String, dynamic>? metadata;

  BehaviorEvent({
    required this.userId,
    required this.action,
    DateTime? timestamp,
    this.location,
    this.metadata,
  }) : timestamp = timestamp ?? DateTime.now();
}

class UserBehaviorProfile {
  final String userId;
  final Set<int> typicalLoginHours = {};
  final Set<String> typicalLocations = {};
  final Map<String, int> typicalActionFrequencies = {};

  UserBehaviorProfile({required this.userId});
}

class AnomalyResult {
  final bool isAnomalous;
  final double score;
  final List<String> reasons;

  AnomalyResult({
    required this.isAnomalous,
    required this.score,
    required this.reasons,
  });
}
