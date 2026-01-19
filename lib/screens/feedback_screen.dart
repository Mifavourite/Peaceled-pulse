import 'package:flutter/material.dart';
import 'dart:io';
import '../services/feedback_service.dart';
import 'package:share_plus/share_plus.dart';

/// Feedback Screen for Beta Testing
class FeedbackScreen extends StatefulWidget {
  const FeedbackScreen({super.key});

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  final _feedbackService = FeedbackService();
  final _formKey = GlobalKey<FormState>();
  final _messageController = TextEditingController();
  
  String _selectedCategory = 'bug';
  String _selectedSeverity = 'medium';
  bool _isSubmitting = false;
  bool _isExporting = false;

  final List<Map<String, String>> _categories = [
    {'value': 'bug', 'label': '🐛 Bug Report'},
    {'value': 'feature', 'label': '✨ Feature Request'},
    {'value': 'ui', 'label': '🎨 UI/UX Feedback'},
    {'value': 'performance', 'label': '⚡ Performance'},
    {'value': 'other', 'label': '💬 Other'},
  ];

  final List<Map<String, String>> _severities = [
    {'value': 'low', 'label': 'Low - Minor issue'},
    {'value': 'medium', 'label': 'Medium - Should be fixed'},
    {'value': 'high', 'label': 'High - Important'},
    {'value': 'critical', 'label': 'Critical - Blocks usage'},
  ];

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _submitFeedback() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isSubmitting = true);

    final success = await _feedbackService.submitFeedback(
      category: _selectedCategory,
      message: _messageController.text.trim(),
      severity: _selectedSeverity,
      metadata: {
        'app_version': '1.0.0-beta',
        'platform': Platform.isAndroid ? 'android' : 'ios',
      },
    );

    setState(() => _isSubmitting = false);

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Feedback submitted! Thank you for testing.'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );
        _messageController.clear();
        setState(() {
          _selectedCategory = 'bug';
          _selectedSeverity = 'medium';
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('❌ Failed to save feedback. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _exportFeedback() async {
    setState(() => _isExporting = true);

    try {
      final files = await _feedbackService.getAllFeedbackFiles();
      
      if (files.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('No feedback files to export.'),
              backgroundColor: Colors.orange,
            ),
          );
        }
        setState(() => _isExporting = false);
        return;
      }

      // Share all feedback files
      final directory = await _feedbackService.getFeedbackDirectoryPath();
      
      if (mounted) {
        await Share.shareXFiles(
          files.map((f) => XFile(f.path)).toList(),
          text: 'Beta Testing Feedback Files',
          subject: 'Beta Feedback Export',
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error exporting feedback: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _isExporting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final isSmallScreen = mediaQuery.size.width < 360;
    final buttonHeight = 56.0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Beta Feedback'),
        backgroundColor: Colors.blue.shade900,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.upload_file),
            onPressed: _isExporting ? null : _exportFeedback,
            tooltip: 'Export Feedback',
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(isSmallScreen ? 16.0 : 24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header
                Card(
                  color: Colors.blue.shade50,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Icon(
                          Icons.feedback,
                          size: 48,
                          color: Colors.blue.shade700,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Help Improve the App',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue.shade900,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Your feedback helps us make the app better',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Category Selection
                Text(
                  'Category',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade800,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _categories.map((cat) {
                    final isSelected = _selectedCategory == cat['value'];
                    return ChoiceChip(
                      label: Text(cat['label']!),
                      selected: isSelected,
                      onSelected: (selected) {
                        if (selected) {
                          setState(() => _selectedCategory = cat['value']!);
                        }
                      },
                      selectedColor: Colors.blue.shade200,
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.blue.shade900 : Colors.grey.shade700,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    );
                  }).toList(),
                ),

                const SizedBox(height: 24),

                // Severity Selection
                Text(
                  'Severity',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade800,
                  ),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: _selectedSeverity,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                  items: _severities.map((sev) {
                    return DropdownMenuItem(
                      value: sev['value'],
                      child: Text(sev['label']!),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _selectedSeverity = value);
                    }
                  },
                ),

                const SizedBox(height: 24),

                // Message Input
                Text(
                  'Message',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade800,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _messageController,
                  maxLines: 6,
                  decoration: InputDecoration(
                    hintText: 'Describe the issue, feature request, or feedback...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    contentPadding: const EdgeInsets.all(16),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter your feedback';
                    }
                    if (value.trim().length < 10) {
                      return 'Please provide more details (at least 10 characters)';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 32),

                // Submit Button
                SizedBox(
                  height: buttonHeight,
                  child: ElevatedButton.icon(
                    onPressed: _isSubmitting ? null : _submitFeedback,
                    icon: _isSubmitting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.send),
                    label: Text(
                      _isSubmitting ? 'Submitting...' : 'Submit Feedback',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade700,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Info Card
                Card(
                  color: Colors.grey.shade50,
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline, size: 20, color: Colors.grey.shade700),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Feedback is stored locally. Use Export to share with developers.',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
