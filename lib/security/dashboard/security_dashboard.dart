import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../monitoring/intrusion_detection.dart';
import '../monitoring/behavior_analytics.dart';
import '../monitoring/threat_intelligence.dart';
import '../authentication/biometric_auth.dart';
import '../network/vpn_detection.dart';
import 'pentest_screen.dart';

/// Security Dashboard - Main security monitoring interface
/// Press F10 to open, Ctrl+Shift+X for penetration test
class SecurityDashboard extends StatefulWidget {
  const SecurityDashboard({super.key});

  @override
  State<SecurityDashboard> createState() => _SecurityDashboardState();
}

class _SecurityDashboardState extends State<SecurityDashboard> {
  final IntrusionDetectionService _ids = IntrusionDetectionService();
  final BehaviorAnalyticsService _behaviorAnalytics = BehaviorAnalyticsService();
  final ThreatIntelligenceService _threatIntel = ThreatIntelligenceService();
  final BiometricAuth _biometricAuth = BiometricAuth();
  final VPNDetectionService _vpnDetection = VPNDetectionService();

  Map<String, dynamic> _securityStats = {};
  Map<String, dynamic> _networkSecurity = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSecurityData();
    _setupKeyboardShortcuts();
  }

  void _setupKeyboardShortcuts() {
    // F10: Open security dashboard (already open, but can refresh)
    RawKeyboard.instance.addListener(_handleKeyEvent);
  }

  void _handleKeyEvent(RawKeyEvent event) {
    if (event is RawKeyDownEvent) {
      // Ctrl+Shift+X: Penetration test
      if (event.isControlPressed &&
          event.isShiftPressed &&
          event.logicalKey == LogicalKeyboardKey.keyX) {
        _runPenetrationTest();
      }
      // F10: Refresh dashboard
      if (event.logicalKey == LogicalKeyboardKey.f10) {
        _loadSecurityData();
      }
    }
  }

  Future<void> _loadSecurityData() async {
    setState(() => _isLoading = true);

    // Load security statistics
    final stats = _ids.getStatistics();
    
    // Load network security info
    final networkInfo = await _vpnDetection.checkNetworkSecurity();

    setState(() {
      _securityStats = stats;
      _networkSecurity = networkInfo;
      _isLoading = false;
    });
  }

  void _runPenetrationTest() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const PentestScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Security Dashboard'),
        backgroundColor: Colors.red.shade900,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadSecurityData,
            tooltip: 'Refresh (F10)',
          ),
          IconButton(
            icon: const Icon(Icons.bug_report),
            onPressed: _runPenetrationTest,
            tooltip: 'Penetration Test (Ctrl+Shift+X)',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSecurityOverview(),
                  const SizedBox(height: 16),
                  _buildNetworkSecurity(),
                  const SizedBox(height: 16),
                  _buildThreatIntelligence(),
                  const SizedBox(height: 16),
                  _buildIntrusionDetection(),
                  const SizedBox(height: 16),
                  _buildQuickActions(),
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _loadSecurityData,
        child: const Icon(Icons.refresh),
        tooltip: 'Refresh Security Data',
      ),
    );
  }

  Widget _buildSecurityOverview() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Security Overview',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatCard(
                  'Total Events',
                  _securityStats['totalEvents']?.toString() ?? '0',
                  Icons.event,
                  Colors.blue,
                ),
                _buildStatCard(
                  'Threats',
                  _securityStats['threats']?.toString() ?? '0',
                  Icons.warning,
                  Colors.red,
                ),
                _buildStatCard(
                  'Blocked IPs',
                  _securityStats['blockedIPs']?.toString() ?? '0',
                  Icons.block,
                  Colors.orange,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 32),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color),
        ),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }

  Widget _buildNetworkSecurity() {
    final isSecure = _networkSecurity['isSecure'] ?? false;
    final vpnActive = _networkSecurity['vpnActive'] ?? false;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  isSecure ? Icons.check_circle : Icons.warning,
                  color: isSecure ? Colors.green : Colors.orange,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Network Security',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildInfoRow('VPN Active', vpnActive ? 'Yes' : 'No', vpnActive),
            _buildInfoRow(
              'Connection Type',
              _networkSecurity['connectionType']?.toString() ?? 'Unknown',
              false,
            ),
            if (_networkSecurity['warnings'] != null)
              ...(_networkSecurity['warnings'] as List)
                  .map((warning) => Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Row(
                          children: [
                            const Icon(Icons.info, size: 16, color: Colors.orange),
                            const SizedBox(width: 8),
                            Expanded(child: Text(warning.toString())),
                          ],
                        ),
                      )),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, bool isWarning) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isWarning ? Colors.orange : Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThreatIntelligence() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Threat Intelligence',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            const Text('Threat database initialized'),
            const Text('Real-time threat detection active'),
          ],
        ),
      ),
    );
  }

  Widget _buildIntrusionDetection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Intrusion Detection',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text('Recent Events: ${_securityStats['recentEvents'] ?? 0}'),
            Text('Failed Attempts: ${_securityStats['failedAttempts'] ?? 0}'),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Quick Actions',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: _runPenetrationTest,
              icon: const Icon(Icons.bug_report),
              label: const Text('Run Penetration Test (Ctrl+Shift+X)'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: () async {
                final available = await _biometricAuth.isAvailable();
                if (available) {
                  final authenticated = await _biometricAuth.authenticate();
                  if (authenticated) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Biometric authentication successful')),
                    );
                  }
                }
              },
              icon: const Icon(Icons.fingerprint),
              label: const Text('Test Biometric Auth'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    RawKeyboard.instance.removeListener(_handleKeyEvent);
    super.dispose();
  }
}
