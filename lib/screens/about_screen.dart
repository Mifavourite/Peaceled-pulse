import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

/// About Screen with Privacy Policy
class AboutScreen extends StatefulWidget {
  const AboutScreen({super.key});

  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> {
  PackageInfo? _packageInfo;

  @override
  void initState() {
    super.initState();
    _loadPackageInfo();
  }

  Future<void> _loadPackageInfo() async {
    final packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      _packageInfo = packageInfo;
    });
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final isSmallScreen = mediaQuery.size.width < 360;

    return Scaffold(
      appBar: AppBar(
        title: const Text('About'),
        backgroundColor: Colors.blue.shade900,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(isSmallScreen ? 12.0 : 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // App Info
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    Icon(
                      Icons.security,
                      size: 64,
                      color: Colors.blue.shade700,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Secure App',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade900,
                      ),
                    ),
                    if (_packageInfo != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        'Version ${_packageInfo!.version} (${_packageInfo!.buildNumber})',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Privacy Policy
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.privacy_tip, color: Colors.blue.shade700),
                        const SizedBox(width: 8),
                        Text(
                          'Privacy Policy',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue.shade900,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    _buildSection(
                      'Data Collection',
                      'We do not collect, transmit, or store any personal data externally. All data remains on your device and is encrypted locally.',
                    ),
                    
                    const Divider(height: 24),
                    
                    _buildSection(
                      'Local Storage',
                      'All app data (detection logs, user values, victory logs) is stored locally in an encrypted SQLite database on your device. No data leaves your device unless you explicitly export it.',
                    ),
                    
                    const Divider(height: 24),
                    
                    _buildSection(
                      'Backup & Export',
                      'Backups are encrypted with a password you choose. You have full control over when and what data to backup or export. Backups are stored locally unless you choose to share them.',
                    ),
                    
                    const Divider(height: 24),
                    
                    _buildSection(
                      'Camera & Permissions',
                      'Camera access is only used for real-time detection. Images are processed locally and not stored unless you explicitly save them. No images are transmitted externally.',
                    ),
                    
                    const Divider(height: 24),
                    
                    _buildSection(
                      'No Analytics',
                      'This app does not use any analytics, tracking, or telemetry services. We do not track your usage, behavior, or any personal information.',
                    ),
                    
                    const Divider(height: 24),
                    
                    _buildSection(
                      'Feedback',
                      'Beta feedback is stored locally on your device. You control what feedback to export and share with developers. No feedback is transmitted automatically.',
                    ),
                    
                    const Divider(height: 24),
                    
                    _buildSection(
                      'Security',
                      'All sensitive data is encrypted using industry-standard encryption (AES-256). Your data is protected both at rest (in the database) and in transit (if exported).',
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Contact
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.contact_support, color: Colors.blue.shade700),
                        const SizedBox(width: 8),
                        Text(
                          'Support',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue.shade900,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'For questions, feedback, or support, use the Feedback feature in the app.',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // License
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.description, color: Colors.blue.shade700),
                        const SizedBox(width: 8),
                        Text(
                          'License',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue.shade900,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'This application is provided "as is" without warranty of any kind. Use at your own risk.',
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
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          content,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade700,
            height: 1.5,
          ),
        ),
      ],
    );
  }
}
