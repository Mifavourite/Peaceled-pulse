import 'dart:convert';
import 'package:crypto/crypto.dart';

/// Threat Intelligence Service
class ThreatIntelligenceService {
  final Set<String> _knownThreats = {};
  final Map<String, ThreatInfo> _threatDatabase = {};

  /// Initialize with threat database
  void initialize(List<ThreatInfo> threats) {
    for (final threat in threats) {
      _knownThreats.add(threat.identifier);
      _threatDatabase[threat.identifier] = threat;
    }
  }

  /// Check if identifier is a known threat
  bool isKnownThreat(String identifier) {
    return _knownThreats.contains(identifier);
  }

  /// Get threat information
  ThreatInfo? getThreatInfo(String identifier) {
    return _threatDatabase[identifier];
  }

  /// Analyze data for threats
  ThreatAnalysisResult analyzeData(String data) {
    final threats = <ThreatInfo>[];
    final hash = sha256.convert(utf8.encode(data)).toString();

    // Check hash against known threats
    if (_knownThreats.contains(hash)) {
      final threat = _threatDatabase[hash];
      if (threat != null) {
        threats.add(threat);
      }
    }

    // Check for suspicious patterns
    final suspiciousPatterns = _detectSuspiciousPatterns(data);
    if (suspiciousPatterns.isNotEmpty) {
      threats.add(ThreatInfo(
        identifier: 'pattern_${sha256.convert(utf8.encode(data)).toString().substring(0, 8)}',
        type: ThreatType.suspiciousPattern,
        severity: ThreatSeverity.medium,
        description: 'Suspicious patterns detected: ${suspiciousPatterns.join(", ")}',
      ));
    }

    return ThreatAnalysisResult(
      isThreat: threats.isNotEmpty,
      threats: threats,
      riskScore: _calculateRiskScore(threats),
    );
  }

  /// Add threat to database
  void addThreat(ThreatInfo threat) {
    _knownThreats.add(threat.identifier);
    _threatDatabase[threat.identifier] = threat;
  }

  /// Remove threat from database
  void removeThreat(String identifier) {
    _knownThreats.remove(identifier);
    _threatDatabase.remove(identifier);
  }

  List<String> _detectSuspiciousPatterns(String data) {
    final patterns = <String>[];
    
    // SQL injection patterns
    if (RegExp(r'(?i)(union|select|drop|insert|delete|update|exec|script)').hasMatch(data)) {
      patterns.add('SQL injection pattern');
    }
    
    // XSS patterns
    if (RegExp(r'(?i)(<script|javascript:|onerror=|onload=)').hasMatch(data)) {
      patterns.add('XSS pattern');
    }
    
    // Command injection patterns
    if (RegExp(r'[;&|`$()]').hasMatch(data)) {
      patterns.add('Command injection pattern');
    }

    return patterns;
  }

  double _calculateRiskScore(List<ThreatInfo> threats) {
    if (threats.isEmpty) return 0.0;
    
    double score = 0.0;
    for (final threat in threats) {
      switch (threat.severity) {
        case ThreatSeverity.low:
          score += 0.2;
          break;
        case ThreatSeverity.medium:
          score += 0.5;
          break;
        case ThreatSeverity.high:
          score += 0.8;
          break;
        case ThreatSeverity.critical:
          score += 1.0;
          break;
      }
    }
    
    return (score / threats.length).clamp(0.0, 1.0);
  }
}

enum ThreatType {
  malware,
  phishing,
  suspiciousPattern,
  knownBadActor,
  compromisedCredential,
}

enum ThreatSeverity {
  low,
  medium,
  high,
  critical,
}

class ThreatInfo {
  final String identifier;
  final ThreatType type;
  final ThreatSeverity severity;
  final String description;
  final DateTime? detectedAt;
  final Map<String, dynamic>? metadata;

  ThreatInfo({
    required this.identifier,
    required this.type,
    required this.severity,
    required this.description,
    this.detectedAt,
    this.metadata,
  });
}

class ThreatAnalysisResult {
  final bool isThreat;
  final List<ThreatInfo> threats;
  final double riskScore;

  ThreatAnalysisResult({
    required this.isThreat,
    required this.threats,
    required this.riskScore,
  });
}
