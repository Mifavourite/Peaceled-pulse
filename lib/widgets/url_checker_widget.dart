import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../services/porn_detection_service.dart';
import '../screens/porn_warning_screen.dart';

/// URL Checker Widget - For web browsers to check current URL
class UrlCheckerWidget extends StatefulWidget {
  const UrlCheckerWidget({super.key});

  @override
  State<UrlCheckerWidget> createState() => _UrlCheckerWidgetState();
}

class _UrlCheckerWidgetState extends State<UrlCheckerWidget> {
  final _detectionService = PornDetectionService();
  final _urlController = TextEditingController();
  bool _isChecking = false;

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  Future<void> _checkUrl() async {
    final url = _urlController.text.trim();
    if (url.isEmpty) return;

    setState(() => _isChecking = true);

    // Small delay for UX
    await Future.delayed(const Duration(milliseconds: 500));

    final isPorn = await _detectionService.checkCurrentPage(url);

    setState(() => _isChecking = false);

    if (isPorn && mounted) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => PornWarningScreen(detectedUrl: url),
        ),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✓ URL is safe'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!kIsWeb) {
      return const SizedBox.shrink();
    }

    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Row(
              children: [
                Icon(Icons.security, color: Colors.blue),
                SizedBox(width: 8),
                Text(
                  'URL Safety Checker',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'Check if a URL contains inappropriate content before visiting.',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _urlController,
              decoration: InputDecoration(
                hintText: 'Enter URL to check...',
                prefixIcon: const Icon(Icons.link),
                border: const OutlineInputBorder(),
                suffixIcon: _isChecking
                    ? const Padding(
                        padding: EdgeInsets.all(12),
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      )
                    : IconButton(
                        icon: const Icon(Icons.check),
                        onPressed: _checkUrl,
                      ),
              ),
              onSubmitted: (_) => _checkUrl(),
            ),
            const SizedBox(height: 8),
            TextButton.icon(
              onPressed: () {
                // Copy current browser URL if possible
                if (kIsWeb) {
                  // On web, we can't directly access window.location due to security
                  // User needs to manually paste the URL
                  _urlController.text = 'Paste URL here from your browser address bar';
                  _urlController.selection = TextSelection(
                    baseOffset: 0,
                    extentOffset: _urlController.text.length,
                  );
                }
              },
              icon: const Icon(Icons.paste),
              label: const Text('Check Current Page URL'),
            ),
          ],
        ),
      ),
    );
  }
}
