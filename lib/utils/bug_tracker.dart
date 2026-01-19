import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';

/// Bug Tracker for Beta Testing
/// Tracks bugs, their status, and fixes
class BugTracker {
  static const String _bugsKey = 'tracked_bugs';
  
  /// Report a bug
  Future<String> reportBug({
    required String description,
    required String category,
    required String severity,
    required List<String> stepsToReproduce,
    String? expectedBehavior,
    String? actualBehavior,
    Map<String, dynamic>? deviceInfo,
    Map<String, dynamic>? metadata,
  }) async {
    final bugId = _generateBugId();
    final bug = BugReport(
      id: bugId,
      description: description,
      category: category,
      severity: severity,
      status: BugStatus.open,
      stepsToReproduce: stepsToReproduce,
      expectedBehavior: expectedBehavior,
      actualBehavior: actualBehavior,
      deviceInfo: deviceInfo ?? {},
      metadata: metadata ?? {},
      reportedAt: DateTime.now(),
    );
    
    await _saveBug(bug);
    return bugId;
  }

  /// Get all bugs
  Future<List<BugReport>> getAllBugs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final bugsJson = prefs.getStringList(_bugsKey) ?? [];
      
      return bugsJson
          .map((json) => BugReport.fromJson(jsonDecode(json)))
          .toList()
        ..sort((a, b) => b.reportedAt.compareTo(a.reportedAt));
    } catch (e) {
      return [];
    }
  }

  /// Get bug by ID
  Future<BugReport?> getBug(String bugId) async {
    final bugs = await getAllBugs();
    try {
      return bugs.firstWhere((bug) => bug.id == bugId);
    } catch (e) {
      return null;
    }
  }

  /// Update bug status
  Future<bool> updateBugStatus(String bugId, BugStatus status, {String? fixVersion, String? notes}) async {
    final bug = await getBug(bugId);
    if (bug == null) return false;
    
    final updatedBug = bug.copyWith(
      status: status,
      fixedIn: fixVersion,
      fixNotes: notes,
      fixedAt: status == BugStatus.fixed ? DateTime.now() : bug.fixedAt,
    );
    
    await _saveBug(updatedBug);
    return true;
  }

  /// Get bugs by status
  Future<List<BugReport>> getBugsByStatus(BugStatus status) async {
    final bugs = await getAllBugs();
    return bugs.where((bug) => bug.status == status).toList();
  }

  /// Get bugs by severity
  Future<List<BugReport>> getBugsBySeverity(String severity) async {
    final bugs = await getAllBugs();
    return bugs.where((bug) => bug.severity == severity).toList();
  }

  /// Export bugs to JSON
  Future<String> exportBugs() async {
    final bugs = await getAllBugs();
    final bugsJson = bugs.map((bug) => bug.toJson()).toList();
    return jsonEncode(bugsJson);
  }

  /// Save bug
  Future<void> _saveBug(BugReport bug) async {
    final prefs = await SharedPreferences.getInstance();
    final bugs = await getAllBugs();
    
    // Remove existing bug with same ID
    bugs.removeWhere((b) => b.id == bug.id);
    bugs.add(bug);
    
    final bugsJson = bugs.map((b) => jsonEncode(b.toJson())).toList();
    await prefs.setStringList(_bugsKey, bugsJson);
  }

  /// Generate unique bug ID
  String _generateBugId() {
    return 'BUG-${DateTime.now().millisecondsSinceEpoch}';
  }

  /// Get bug statistics
  Future<BugStatistics> getStatistics() async {
    final bugs = await getAllBugs();
    
    final byStatus = <BugStatus, int>{};
    final bySeverity = <String, int>{};
    final byCategory = <String, int>{};
    
    for (final bug in bugs) {
      byStatus[bug.status] = (byStatus[bug.status] ?? 0) + 1;
      bySeverity[bug.severity] = (bySeverity[bug.severity] ?? 0) + 1;
      byCategory[bug.category] = (byCategory[bug.category] ?? 0) + 1;
    }
    
    return BugStatistics(
      total: bugs.length,
      byStatus: byStatus,
      bySeverity: bySeverity,
      byCategory: byCategory,
      open: bugs.where((b) => b.status == BugStatus.open).length,
      fixed: bugs.where((b) => b.status == BugStatus.fixed).length,
      verified: bugs.where((b) => b.status == BugStatus.verified).length,
    );
  }

  /// Clear all bugs (for testing)
  Future<void> clearAllBugs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_bugsKey);
  }
}

/// Bug Report Model
class BugReport {
  final String id;
  final String description;
  final String category;
  final String severity;
  final BugStatus status;
  final List<String> stepsToReproduce;
  final String? expectedBehavior;
  final String? actualBehavior;
  final Map<String, dynamic> deviceInfo;
  final Map<String, dynamic> metadata;
  final DateTime reportedAt;
  final DateTime? fixedAt;
  final String? fixedIn;
  final String? fixNotes;

  BugReport({
    required this.id,
    required this.description,
    required this.category,
    required this.severity,
    required this.status,
    required this.stepsToReproduce,
    this.expectedBehavior,
    this.actualBehavior,
    required this.deviceInfo,
    required this.metadata,
    required this.reportedAt,
    this.fixedAt,
    this.fixedIn,
    this.fixNotes,
  });

  BugReport copyWith({
    String? id,
    String? description,
    String? category,
    String? severity,
    BugStatus? status,
    List<String>? stepsToReproduce,
    String? expectedBehavior,
    String? actualBehavior,
    Map<String, dynamic>? deviceInfo,
    Map<String, dynamic>? metadata,
    DateTime? reportedAt,
    DateTime? fixedAt,
    String? fixedIn,
    String? fixNotes,
  }) {
    return BugReport(
      id: id ?? this.id,
      description: description ?? this.description,
      category: category ?? this.category,
      severity: severity ?? this.severity,
      status: status ?? this.status,
      stepsToReproduce: stepsToReproduce ?? this.stepsToReproduce,
      expectedBehavior: expectedBehavior ?? this.expectedBehavior,
      actualBehavior: actualBehavior ?? this.actualBehavior,
      deviceInfo: deviceInfo ?? this.deviceInfo,
      metadata: metadata ?? this.metadata,
      reportedAt: reportedAt ?? this.reportedAt,
      fixedAt: fixedAt ?? this.fixedAt,
      fixedIn: fixedIn ?? this.fixedIn,
      fixNotes: fixNotes ?? this.fixNotes,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'description': description,
    'category': category,
    'severity': severity,
    'status': status.toString().split('.').last,
    'steps_to_reproduce': stepsToReproduce,
    'expected_behavior': expectedBehavior,
    'actual_behavior': actualBehavior,
    'device_info': deviceInfo,
    'metadata': metadata,
    'reported_at': reportedAt.toIso8601String(),
    'fixed_at': fixedAt?.toIso8601String(),
    'fixed_in': fixedIn,
    'fix_notes': fixNotes,
  };

  factory BugReport.fromJson(Map<String, dynamic> json) {
    return BugReport(
      id: json['id'],
      description: json['description'],
      category: json['category'],
      severity: json['severity'],
      status: BugStatus.values.firstWhere(
        (e) => e.toString().split('.').last == json['status'],
        orElse: () => BugStatus.open,
      ),
      stepsToReproduce: List<String>.from(json['steps_to_reproduce']),
      expectedBehavior: json['expected_behavior'],
      actualBehavior: json['actual_behavior'],
      deviceInfo: Map<String, dynamic>.from(json['device_info'] ?? {}),
      metadata: Map<String, dynamic>.from(json['metadata'] ?? {}),
      reportedAt: DateTime.parse(json['reported_at']),
      fixedAt: json['fixed_at'] != null ? DateTime.parse(json['fixed_at']) : null,
      fixedIn: json['fixed_in'],
      fixNotes: json['fix_notes'],
    );
  }
}

enum BugStatus {
  open,
  inProgress,
  fixed,
  verified,
  closed,
  rejected,
}

class BugStatistics {
  final int total;
  final Map<BugStatus, int> byStatus;
  final Map<String, int> bySeverity;
  final Map<String, int> byCategory;
  final int open;
  final int fixed;
  final int verified;

  BugStatistics({
    required this.total,
    required this.byStatus,
    required this.bySeverity,
    required this.byCategory,
    required this.open,
    required this.fixed,
    required this.verified,
  });
}
