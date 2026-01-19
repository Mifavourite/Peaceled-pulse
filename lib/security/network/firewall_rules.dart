import 'package:dio/dio.dart';

/// Firewall Rules Service for network traffic control
class FirewallRulesService {
  final List<FirewallRule> _rules = [];
  final Dio _dio = Dio();

  /// Add firewall rule
  void addRule(FirewallRule rule) {
    _rules.add(rule);
  }

  /// Remove firewall rule
  void removeRule(FirewallRule rule) {
    _rules.remove(rule);
  }

  /// Check if request is allowed
  bool isAllowed(String url, {String? method}) {
    for (final rule in _rules) {
      if (rule.matches(url, method: method)) {
        return rule.action == FirewallAction.allow;
      }
    }
    // Default deny if no rule matches
    return false;
  }

  /// Make secure HTTP request with firewall rules
  Future<Response> secureRequest(
    String url, {
    String method = 'GET',
    Map<String, dynamic>? data,
    Map<String, String>? headers,
  }) async {
    if (!isAllowed(url, method: method)) {
      throw Exception('Request blocked by firewall rule');
    }

    return await _dio.request(
      url,
      data: data,
      options: Options(
        method: method,
        headers: headers,
      ),
    );
  }

  /// Add allow rule for domain
  void allowDomain(String domain) {
    addRule(FirewallRule(
      pattern: domain,
      action: FirewallAction.allow,
    ));
  }

  /// Add deny rule for domain
  void denyDomain(String domain) {
    addRule(FirewallRule(
      pattern: domain,
      action: FirewallAction.deny,
    ));
  }

  /// Clear all rules
  void clearRules() {
    _rules.clear();
  }

  /// Get all rules
  List<FirewallRule> getRules() {
    return List.unmodifiable(_rules);
  }
}

enum FirewallAction {
  allow,
  deny,
}

class FirewallRule {
  final String pattern;
  final FirewallAction action;
  final String? method;

  FirewallRule({
    required this.pattern,
    required this.action,
    this.method,
  });

  bool matches(String url, {String? method}) {
    if (this.method != null && method != null) {
      if (this.method!.toUpperCase() != method.toUpperCase()) {
        return false;
      }
    }

    // Simple pattern matching - can be enhanced with regex
    return url.contains(pattern);
  }
}
