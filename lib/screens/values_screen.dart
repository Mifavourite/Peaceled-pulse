import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/database_service.dart';

/// Values Screen - Store 5 personal values (encrypted)
class ValuesScreen extends StatefulWidget {
  const ValuesScreen({super.key});

  @override
  State<ValuesScreen> createState() => _ValuesScreenState();
}

class _ValuesScreenState extends State<ValuesScreen> {
  final _authService = AuthService();
  final _databaseService = DatabaseService();
  final List<TextEditingController> _controllers = List.generate(
    5,
    (_) => TextEditingController(),
  );
  bool _isLoading = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadValues();
  }

  Future<void> _loadValues() async {
    setState(() => _isLoading = true);

    try {
      final userId = await _authService.getCurrentUserId();
      if (userId != null) {
        final values = await _databaseService.getUserValues(userId);
        for (int i = 0; i < values.length && i < 5; i++) {
          _controllers[i].text = values[i];
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading values: $e')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _saveValues() async {
    setState(() => _isSaving = true);

    try {
      final userId = await _authService.getCurrentUserId();
      if (userId != null) {
        final values = _controllers
            .map((controller) => controller.text.trim())
            .where((value) => value.isNotEmpty)
            .toList();

        final success = await _databaseService.saveUserValues(userId, values);

        if (success && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Values saved securely'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          throw Exception('Failed to save values');
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving values: $e')),
        );
      }
    } finally {
      setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'My Values',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Select your 5 core values\n(Stored encrypted, no analytics)',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    ...List.generate(5, (index) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: TextField(
                          controller: _controllers[index],
                          decoration: InputDecoration(
                            labelText: 'Value ${index + 1}',
                            prefixIcon: const Icon(Icons.favorite),
                            border: const OutlineInputBorder(),
                            filled: true,
                            fillColor: Colors.grey.shade50,
                          ),
                        ),
                      );
                    }),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _isSaving ? null : _saveValues,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: Colors.blue.shade900,
                        foregroundColor: Colors.white,
                      ),
                      child: _isSaving
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Save Values'),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }
}
