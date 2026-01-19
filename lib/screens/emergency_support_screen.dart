import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

/// Emergency Support Screen - Crisis resources and quick help
class EmergencySupportScreen extends StatelessWidget {
  const EmergencySupportScreen({super.key});

  Future<void> _makePhoneCall(String phoneNumber) async {
    final uri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _sendSMS(String phoneNumber, String message) async {
    final uri = Uri(scheme: 'sms', path: phoneNumber, queryParameters: {'body': message});
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  void _copyToClipboard(BuildContext context, String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Copied to clipboard'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Emergency Support'),
        backgroundColor: Colors.red.shade700,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Urgent Crisis Banner
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.red.shade300, width: 2),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.warning_amber_rounded,
                    size: 48,
                    color: Colors.red.shade700,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'In Crisis? You\'re Not Alone',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.red.shade900,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Help is available 24/7. Reach out now.',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.red.shade800,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // National Crisis Hotlines
            const Text(
              'Crisis Hotlines (USA)',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),

            _buildHotlineCard(
              context,
              'National Suicide Prevention Lifeline',
              '988',
              'Available 24/7 for anyone in crisis',
              Icons.phone_in_talk,
              Colors.red,
            ),

            _buildHotlineCard(
              context,
              'Crisis Text Line',
              'Text HOME to 741741',
              'Free, 24/7 support via text message',
              Icons.message,
              Colors.blue,
            ),

            _buildHotlineCard(
              context,
              'SAMHSA National Helpline',
              '1-800-662-4357',
              'Substance abuse and mental health services',
              Icons.local_hospital,
              Colors.green,
            ),

            const SizedBox(height: 24),

            // Quick Coping Strategies
            const Text(
              'Quick Coping Strategies',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),

            _buildCopingCard(
              'Breathing Exercise',
              'Take 5 slow, deep breaths. Inhale for 4, hold for 4, exhale for 6.',
              Icons.air,
              Colors.blue.shade100,
            ),

            _buildCopingCard(
              'Grounding Technique',
              'Name 5 things you see, 4 you can touch, 3 you hear, 2 you smell, 1 you taste.',
              Icons.spa,
              Colors.green.shade100,
            ),

            _buildCopingCard(
              'Call Your Support Person',
              'Reach out to someone you trust. You don\'t have to face this alone.',
              Icons.people,
              Colors.purple.shade100,
            ),

            _buildCopingCard(
              'Physical Activity',
              'Take a walk, do jumping jacks, or any movement to shift your energy.',
              Icons.directions_run,
              Colors.orange.shade100,
            ),

            const SizedBox(height: 24),

            // Accountability Partner Section
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.amber.shade50,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.amber.shade300, width: 2),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.people_alt,
                    size: 40,
                    color: Colors.amber.shade700,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Accountability Partner',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Having someone to talk to can make all the difference. Consider sharing this app with a trusted friend or sponsor.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, height: 1.4),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () {
                      // TODO: Implement contact selection
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Feature coming soon: Add accountability partner'),
                        ),
                      );
                    },
                    icon: const Icon(Icons.person_add),
                    label: const Text('Add Accountability Partner'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amber.shade700,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Reminders Section
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.favorite, color: Colors.pink.shade400),
                      const SizedBox(width: 8),
                      const Text(
                        'Remember',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildReminderItem('Recovery is possible and you deserve it'),
                  _buildReminderItem('This feeling is temporary'),
                  _buildReminderItem('You\'ve overcome challenges before'),
                  _buildReminderItem('One moment at a time is enough'),
                  _buildReminderItem('You are stronger than you think'),
                ],
              ),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildHotlineCard(
    BuildContext context,
    String title,
    String number,
    String description,
    IconData icon,
    Color color,
  ) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color, size: 28),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        description,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Text(
                    number,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ),
                if (number.contains('741741'))
                  ElevatedButton.icon(
                    onPressed: () => _sendSMS('741741', 'HOME'),
                    icon: const Icon(Icons.message, size: 18),
                    label: const Text('Text'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: color,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                    ),
                  )
                else
                  ElevatedButton.icon(
                    onPressed: () => _makePhoneCall(number.replaceAll(RegExp(r'[^0-9]'), '')),
                    icon: const Icon(Icons.phone, size: 18),
                    label: const Text('Call'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: color,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                    ),
                  ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: () => _copyToClipboard(context, number),
                  icon: const Icon(Icons.copy, size: 20),
                  tooltip: 'Copy number',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCopingCard(String title, String description, IconData icon, Color color) {
    return Card(
      elevation: 1,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 32, color: Colors.black54),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade800,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReminderItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.check_circle, size: 20, color: Colors.green),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 14, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
}
