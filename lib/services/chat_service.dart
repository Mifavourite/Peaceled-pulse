import 'dart:convert';
import 'package:flutter/services.dart';

/// Local AI Chat Service with pre-programmed responses and scripture suggestions
class ChatService {
  List<Map<String, dynamic>>? _responses;
  List<Map<String, dynamic>>? _defaultResponses;
  bool _isInitialized = false;

  /// Initialize chat service by loading local JSON
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      final String jsonString = await rootBundle.loadString('lib/data/scriptures.json');
      final Map<String, dynamic> jsonData = json.decode(jsonString);

      _responses = List<Map<String, dynamic>>.from(jsonData['responses'] ?? []);
      _defaultResponses = List<Map<String, dynamic>>.from(jsonData['default_responses'] ?? []);

      _isInitialized = true;
    } catch (e) {
      // If JSON fails to load, use fallback responses
      _responses = [];
      _defaultResponses = [
        {
          'response': 'I\'m here to support you. How can I help?',
          'scripture': {
            'reference': 'Psalm 46:1',
            'text': 'God is our refuge and strength, an ever-present help in trouble.'
          }
        }
      ];
      _isInitialized = true;
    }
  }

  /// Get response based on user message
  Map<String, dynamic> getResponse(String userMessage) {
    if (!_isInitialized || _responses == null) {
      return _getDefaultResponse();
    }

    // Normalize message for matching
    final normalizedMessage = userMessage.toLowerCase().trim();

    // Find matching response based on keywords
    for (final responseData in _responses!) {
      final keywords = List<String>.from(responseData['keywords'] ?? []);
      
      // Check if any keyword matches
      for (final keyword in keywords) {
        if (normalizedMessage.contains(keyword.toLowerCase())) {
          return {
            'response': responseData['response'] as String,
            'scripture': responseData['scripture'] as Map<String, dynamic>,
            'matched': true,
          };
        }
      }
    }

    // No match found, return default response
    return _getDefaultResponse();
  }

  /// Get a random default response
  Map<String, dynamic> _getDefaultResponse() {
    if (_defaultResponses == null || _defaultResponses!.isEmpty) {
      return {
        'response': 'I\'m here to support you. How can I help?',
        'scripture': {
          'reference': 'Psalm 46:1',
          'text': 'God is our refuge and strength, an ever-present help in trouble.'
        },
        'matched': false,
      };
    }

    // Return a random default response
    final randomIndex = DateTime.now().millisecondsSinceEpoch % _defaultResponses!.length;
    final defaultResponse = _defaultResponses![randomIndex];
    
    return {
      'response': defaultResponse['response'] as String,
      'scripture': defaultResponse['scripture'] as Map<String, dynamic>,
      'matched': false,
    };
  }

  /// Get all available keywords (for help/suggestions)
  List<String> getAllKeywords() {
    if (!_isInitialized || _responses == null) return [];

    final keywords = <String>[];
    for (final responseData in _responses!) {
      final responseKeywords = List<String>.from(responseData['keywords'] ?? []);
      keywords.addAll(responseKeywords);
    }
    return keywords.toSet().toList(); // Remove duplicates
  }

  /// Check if service is initialized
  bool get isInitialized => _isInitialized;
}
