import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:async';

/// Porn Detection Service - Detects and warns about porn-related content
class PornDetectionService {
  SharedPreferences? _prefs;
  Timer? _monitoringTimer;
  
  // List of porn-related keywords to detect
  final List<String> _pornKeywords = [
    'porn', 'xxx', 'sex', 'adult', 'nsfw', 'nude', 'naked',
    'hentai', 'erotic', 'explicit', 'mature', 'adult content',
    'pornhub', 'xvideos', 'redtube', 'youporn', 'xhamster',
    'onlyfans', 'chaturbate', 'cam4', 'livejasmin',
  ];

  // Bible verses for warnings
  final List<Map<String, String>> _warningVerses = [
    {
      'reference': '1 Corinthians 6:18',
      'text': 'Flee from sexual immorality. All other sins a person commits are outside the body, but whoever sins sexually, sins against their own body.'
    },
    {
      'reference': 'Matthew 5:28',
      'text': 'But I tell you that anyone who looks at a woman lustfully has already committed adultery with her in his heart.'
    },
    {
      'reference': 'Job 31:1',
      'text': 'I made a covenant with my eyes not to look lustfully at a young woman.'
    },
    {
      'reference': 'Proverbs 6:25',
      'text': 'Do not lust in your heart after her beauty or let her captivate you with her eyes.'
    },
    {
      'reference': 'Ephesians 5:3',
      'text': 'But among you there must not be even a hint of sexual immorality, or of any kind of impurity, or of greed, because these are improper for God\'s people.'
    },
    {
      'reference': '1 Thessalonians 4:3-4',
      'text': 'It is God\'s will that you should be sanctified: that you should avoid sexual immorality; that each of you should learn to control your own body in a way that is holy and honorable.'
    },
    {
      'reference': 'Galatians 5:19-21',
      'text': 'The acts of the flesh are obvious: sexual immorality, impurity and debauchery... I warn you, as I did before, that those who live like this will not inherit the kingdom of God.'
    },
    {
      'reference': 'Colossians 3:5',
      'text': 'Put to death, therefore, whatever belongs to your earthly nature: sexual immorality, impurity, lust, evil desires and greed, which is idolatry.'
    },
  ];

  Future<void> _ensureInitialized() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  /// Check if URL contains porn-related content
  bool isPornRelated(String url) {
    final lowerUrl = url.toLowerCase();
    return _pornKeywords.any((keyword) => lowerUrl.contains(keyword));
  }

  /// Get a random warning verse
  Map<String, String> getWarningVerse() {
    final random = DateTime.now().millisecondsSinceEpoch % _warningVerses.length;
    return _warningVerses[random];
  }

  /// Log porn attempt
  Future<void> logAttempt(String url) async {
    await _ensureInitialized();
    final now = DateTime.now();
    final dateKey = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    final key = 'porn_attempts_$dateKey';
    
    final attemptsJson = _prefs!.getString(key) ?? '[]';
    final attempts = jsonDecode(attemptsJson) as List;
    
    attempts.add({
      'url': url,
      'timestamp': now.millisecondsSinceEpoch,
      'time': '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}',
    });
    
    await _prefs!.setString(key, jsonEncode(attempts));
  }

  /// Get today's attempts
  Future<List<Map<String, dynamic>>> getTodayAttempts() async {
    await _ensureInitialized();
    final now = DateTime.now();
    final dateKey = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    final key = 'porn_attempts_$dateKey';
    
    final attemptsJson = _prefs!.getString(key) ?? '[]';
    return List<Map<String, dynamic>>.from(jsonDecode(attemptsJson) as List);
  }

  /// Start monitoring (for web - checks current URL)
  void startMonitoring(Function(String url, Map<String, String> verse) onDetection) {
    if (!kIsWeb) return;
    
    _monitoringTimer?.cancel();
    _monitoringTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      // On web, we can't directly access browser URL due to security
      // This would need to be implemented via browser extension
      // For now, we'll provide a manual check function
    });
  }

  /// Stop monitoring
  void stopMonitoring() {
    _monitoringTimer?.cancel();
    _monitoringTimer = null;
  }

  /// Manual check (for web - user can check current page)
  Future<bool> checkCurrentPage(String? url) async {
    if (url == null) return false;
    
    if (isPornRelated(url)) {
      await logAttempt(url);
      return true;
    }
    return false;
  }
}
