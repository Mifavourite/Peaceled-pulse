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

  /// Get response based on user message with multiple verses
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
          // Get multiple relevant verses (3-5 verses)
          final verses = _getMultipleVerses(responseData['scripture'] as Map<String, dynamic>);
          return {
            'response': responseData['response'] as String,
            'scripture': responseData['scripture'] as Map<String, dynamic>,
            'verses': verses, // Multiple verses
            'matched': true,
          };
        }
      }
    }

    // No match found, return default response with multiple verses
    final defaultResp = _getDefaultResponse();
    final verses = _getMultipleVerses(defaultResp['scripture'] as Map<String, dynamic>);
    defaultResp['verses'] = verses;
    return defaultResp;
  }

  /// Get multiple relevant Bible verses (3-5 verses) for encouragement
  List<Map<String, dynamic>> _getMultipleVerses(Map<String, dynamic> primaryVerse) {
    final allVerses = <Map<String, dynamic>>[];
    
    // Add the primary verse
    allVerses.add(primaryVerse);
    
    // Add additional encouraging verses related to decision-making and overcoming addictions
    final additionalVerses = [
      {
        'reference': '1 Corinthians 10:13',
        'text': 'No temptation has overtaken you except what is common to mankind. And God is faithful; he will not let you be tempted beyond what you can bear. But when you are tempted, he will also provide a way out so that you can endure it.'
      },
      {
        'reference': 'James 4:7',
        'text': 'Submit yourselves, then, to God. Resist the devil, and he will flee from you.'
      },
      {
        'reference': 'Romans 12:2',
        'text': 'Do not conform to the pattern of this world, but be transformed by the renewing of your mind. Then you will be able to test and approve what God\'s will is—his good, pleasing and perfect will.'
      },
      {
        'reference': 'Proverbs 3:5-6',
        'text': 'Trust in the Lord with all your heart and lean not on your own understanding; in all your ways submit to him, and he will make your paths straight.'
      },
      {
        'reference': 'Isaiah 40:31',
        'text': 'But those who hope in the Lord will renew their strength. They will soar on wings like eagles; they will run and not grow weary, they will walk and not be faint.'
      },
      {
        'reference': '2 Timothy 1:7',
        'text': 'For the Spirit God gave us does not make us timid, but gives us power, love and self-discipline.'
      },
      {
        'reference': 'Galatians 5:1',
        'text': 'It is for freedom that Christ has set us free. Stand firm, then, and do not let yourselves be burdened again by a yoke of slavery.'
      },
      {
        'reference': 'Psalm 119:11',
        'text': 'I have hidden your word in my heart that I might not sin against you.'
      },
    ];
    
    // Randomly select 2-4 additional verses (avoid duplicates)
    final random = DateTime.now().millisecondsSinceEpoch;
    final selected = <Map<String, dynamic>>[];
    final used = <int>{};
    
    // Don't add the primary verse again
    for (var verse in additionalVerses) {
      if (verse['reference'] == primaryVerse['reference']) continue;
      selected.add(verse);
    }
    
    // Shuffle and take 2-4 random verses
    selected.shuffle();
    final count = 2 + (random % 3); // 2-4 verses
    for (int i = 0; i < count && i < selected.length; i++) {
      allVerses.add(selected[i]);
    }
    
    return allVerses;
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
