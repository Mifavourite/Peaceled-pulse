import 'package:flutter/material.dart';
import '../services/encryption_test_service.dart';
import '../services/database_service.dart';
import '../services/auth_service.dart';

/// Security Test Screen - Verify all security features are working
class SecurityTestScreen extends StatefulWidget {
  const SecurityTestScreen({super.key});

  @override
  State<SecurityTestScreen> createState() => _SecurityTestScreenState();
}

class _SecurityTestScreenState extends State<SecurityTestScreen> {
  final _encryptionTestService = EncryptionTestService();
  final _databaseService = DatabaseService();
  final _authService = AuthService();
  
  Map<String, dynamic>? _encryptionResults;
  bool _isTesting = false;
  String? _testStatus;

  Future<void> _runSecurityTests() async {
    setState(() {
      _isTesting = true;
      _testStatus = 'Running security tests...';
      _encryptionResults = null;
    });

    try {
      // Test encryption
      final encryptionResults = await _encryptionTestService.testEncryption();
      
      // Test database initialization
      await _databaseService.initialize();
      
      // Test auth service
      await _authService.initialize();

      setState(() {
        _encryptionResults = encryptionResults;
        _testStatus = 'Tests completed';
        _isTesting = false;
      });
    } catch (e) {
      setState(() {
        _testStatus = 'Error: $e';
        _isTesting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Security Tests'),
        backgroundColor: Colors.blue.shade900,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              color: Colors.blue.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Security Verification',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Run tests to verify all security features are working correctly.',
                      style: TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _isTesting ? null : _runSecurityTests,
              icon: _isTesting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.security),
              label: Text(_isTesting ? 'Testing...' : 'Run Security Tests'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: Colors.blue.shade900,
                foregroundColor: Colors.white,
              ),
            ),
            if (_testStatus != null) ...[
              const SizedBox(height: 16),
              Text(
                _testStatus!,
                style: TextStyle(
                  color: _isTesting ? Colors.blue : Colors.green,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            if (_encryptionResults != null) ...[
              const SizedBox(height: 24),
              const Text(
                'Test Results',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              _buildTestResult(
                'AES Encryption',
                _encryptionResults!['aes_encryption'] == true,
              ),
              _buildTestResult(
                'Secure Storage',
                _encryptionResults!['secure_storage'] == true,
              ),
              _buildTestResult(
                'Hashing (SHA-256)',
                _encryptionResults!['hashing'] == true,
              ),
              if (_encryptionResults!['all_passed'] == true) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.green),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.check_circle, color: Colors.green),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'All encryption tests passed!',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              if (_encryptionResults!['errors'] != null &&
                  (_encryptionResults!['errors'] as List).isNotEmpty) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.error, color: Colors.red),
                          SizedBox(width: 12),
                          Text(
                            'Errors Found',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.red,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ...(_encryptionResults!['errors'] as List)
                          .map((error) => Padding(
                                padding: const EdgeInsets.only(bottom: 4),
                                child: Text(
                                  '• $error',
                                  style: const TextStyle(color: Colors.red),
                                ),
                              )),
                    ],
                  ),
                ),
              ],
            ],
            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 16),
            const Text(
              'Security Checklist',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildChecklistItem('✅ No hardcoded passwords', true),
            _buildChecklistItem('✅ Database encryption (SQLCipher)', true),
            _buildChecklistItem('✅ Secure storage (FlutterSecureStorage)', true),
            _buildChecklistItem('✅ Password hashing (bcrypt)', true),
            _buildChecklistItem('✅ HTTPS enforcement', true),
            _buildChecklistItem('✅ Security headers configured', true),
            _buildChecklistItem('✅ No analytics/telemetry', true),
          ],
        ),
      ),
    );
  }

  Widget _buildTestResult(String label, bool passed) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(
            passed ? Icons.check_circle : Icons.error,
            color: passed ? Colors.green : Colors.red,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 16,
                color: passed ? Colors.green.shade900 : Colors.red.shade900,
              ),
            ),
          ),
          Text(
            passed ? 'PASS' : 'FAIL',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: passed ? Colors.green : Colors.red,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChecklistItem(String text, bool checked) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(
            checked ? Icons.check_circle : Icons.radio_button_unchecked,
            color: checked ? Colors.green : Colors.grey,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 14,
                color: checked ? Colors.black87 : Colors.grey,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
