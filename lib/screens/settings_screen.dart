import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/backup_service.dart';
import '../services/auth_service.dart';
import '../services/emergency_override_service.dart';
import 'package:file_picker/file_picker.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:io';
import 'about_screen.dart';
import 'export_screen.dart';

/// Settings Screen with sensitivity, sounds, and backup options
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _backupService = BackupService();
  final _authService = AuthService();
  final _overrideService = EmergencyOverrideService();
  
  double _confidenceThreshold = 0.8;
  int _lockDurationMinutes = 3;
  bool _soundEnabled = true;
  bool _notificationEnabled = true;
  bool _overrideEnabled = true;
  int _overrideDelay = 10;
  
  final _backupPasswordController = TextEditingController();
  final _restorePasswordController = TextEditingController();
  bool _isLoading = false;
  bool _isExporting = false;
  bool _isImporting = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  @override
  void dispose() {
    _backupPasswordController.dispose();
    _restorePasswordController.dispose();
    super.dispose();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final overrideDelay = await _overrideService.getOverrideDelay();
    final overrideEnabled = await _overrideService.isOverrideEnabled();
    
    setState(() {
      _confidenceThreshold = prefs.getDouble('confidence_threshold') ?? 0.8;
      _lockDurationMinutes = prefs.getInt('lock_duration_minutes') ?? 3;
      _soundEnabled = prefs.getBool('sound_enabled') ?? true;
      _notificationEnabled = prefs.getBool('notification_enabled') ?? true;
      _overrideDelay = overrideDelay;
      _overrideEnabled = overrideEnabled;
    });
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('confidence_threshold', _confidenceThreshold);
    await prefs.setInt('lock_duration_minutes', _lockDurationMinutes);
    await prefs.setBool('sound_enabled', _soundEnabled);
    await prefs.setBool('notification_enabled', _notificationEnabled);
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Settings saved'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _exportBackup() async {
    if (_backupPasswordController.text.isEmpty) {
      _showPasswordDialog(true);
      return;
    }

    setState(() => _isExporting = true);

    try {
      final result = await _backupService.exportBackup(
        userPassword: _backupPasswordController.text,
      );

      setState(() => _isExporting = false);
      _backupPasswordController.clear();

      if (mounted) {
        if (result.success && result.filePath != null) {
          // Share backup file
          await Share.shareXFiles(
            [XFile(result.filePath!)],
            text: 'Secure App Backup - Encrypted',
            subject: 'Backup Export',
          );

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Backup exported successfully (${_formatFileSize(result.size ?? 0)})'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Export failed: ${result.error ?? "Unknown error"}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      setState(() => _isExporting = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _importBackup() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['secure'],
      );

      if (result == null || result.files.single.path == null) {
        return;
      }

      final filePath = result.files.single.path!;
      
      // Show password dialog
      final password = await _showPasswordDialog(false);
      if (password == null || password.isEmpty) {
        return;
      }

      setState(() => _isImporting = true);

      final restoreResult = await _backupService.importBackup(
        backupFilePath: filePath,
        userPassword: password,
      );

      setState(() => _isImporting = false);

      if (mounted) {
        if (restoreResult.success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(restoreResult.message ?? 'Backup restored successfully'),
              backgroundColor: Colors.green,
            ),
          );
          // Reload settings after restore
          _loadSettings();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Restore failed: ${restoreResult.error ?? "Unknown error"}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      setState(() => _isImporting = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<String?> _showPasswordDialog(bool forExport) async {
    final controller = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(forExport ? 'Enter Backup Password' : 'Enter Backup Password'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(forExport
                ? 'Enter a password to encrypt your backup. Remember this password to restore later.'
                : 'Enter the password used to encrypt this backup.'),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
              ),
              autofocus: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(null),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(controller.text),
            child: const Text('Continue'),
          ),
        ],
      ),
    );
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final isSmallScreen = mediaQuery.size.width < 360;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: Colors.blue.shade900,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const AboutScreen()),
              );
            },
            tooltip: 'About',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(isSmallScreen ? 12.0 : 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Detection Settings
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Detection Settings',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade900,
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Confidence Threshold
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Confidence Threshold'),
                        Text(
                          '${(_confidenceThreshold * 100).toStringAsFixed(0)}%',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue.shade900,
                          ),
                        ),
                      ],
                    ),
                    Slider(
                      value: _confidenceThreshold,
                      min: 0.60,
                      max: 0.95,
                      divisions: 35,
                      label: '${(_confidenceThreshold * 100).toStringAsFixed(0)}%',
                      onChanged: (value) {
                        setState(() => _confidenceThreshold = value);
                        _saveSettings();
                      },
                    ),
                    
                    const Divider(),
                    
                    // Lock Duration
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Lock Duration'),
                        Text(
                          '$_lockDurationMinutes min',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.orange.shade900,
                          ),
                        ),
                      ],
                    ),
                    Slider(
                      value: _lockDurationMinutes.toDouble(),
                      min: 1.0,
                      max: 5.0,
                      divisions: 4,
                      label: '$_lockDurationMinutes min',
                      onChanged: (value) {
                        setState(() => _lockDurationMinutes = value.toInt());
                        _saveSettings();
                      },
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Audio & Notifications
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Audio & Notifications',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade900,
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    SwitchListTile(
                      title: const Text('Sound Effects'),
                      subtitle: const Text('Play shofar sound on detection'),
                      value: _soundEnabled,
                      onChanged: (value) {
                        setState(() => _soundEnabled = value);
                        _saveSettings();
                      },
                    ),
                    
                    SwitchListTile(
                      title: const Text('Notifications'),
                      subtitle: const Text('Enable detection notifications'),
                      value: _notificationEnabled,
                      onChanged: (value) {
                        setState(() => _notificationEnabled = value);
                        _saveSettings();
                      },
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Progress Reports & Backup
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Data & Reports',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade900,
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Progress Report Button
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => const ExportScreen(),
                            ),
                          );
                        },
                        icon: const Icon(Icons.assessment),
                        label: const Text('Progress Reports'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.purple.shade700,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    const Divider(),
                    const SizedBox(height: 8),
                    
                    Text(
                      'Encrypted Backups',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade900,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Export encrypted backup or restore from backup',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton.icon(
                        onPressed: _isExporting ? null : _exportBackup,
                        icon: _isExporting
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(Icons.file_download),
                        label: Text(_isExporting ? 'Exporting...' : 'Export Backup'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green.shade700,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 8),
                    
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton.icon(
                        onPressed: _isImporting ? null : _importBackup,
                        icon: _isImporting
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(Icons.file_upload),
                        label: Text(_isImporting ? 'Importing...' : 'Import Backup'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue.shade700,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Emergency Override Settings
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Emergency Override',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade900,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Override lock period with delay for emergencies',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    SwitchListTile(
                      title: const Text('Enable Override'),
                      subtitle: const Text('Allow emergency override with delay'),
                      value: _overrideEnabled,
                      onChanged: (value) async {
                        setState(() => _overrideEnabled = value);
                        await _overrideService.setOverrideEnabled(value);
                        _saveSettings();
                      },
                    ),
                    
                    if (_overrideEnabled) ...[
                      const Divider(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Override Delay'),
                          Text(
                            '$_overrideDelay seconds',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.orange.shade900,
                            ),
                          ),
                        ],
                      ),
                      Slider(
                        value: _overrideDelay.toDouble(),
                        min: 5.0,
                        max: 60.0,
                        divisions: 11,
                        label: '$_overrideDelay seconds',
                        onChanged: (value) async {
                          setState(() => _overrideDelay = value.toInt());
                          await _overrideService.setOverrideDelay(value.toInt());
                          _saveSettings();
                        },
                      ),
                    ],
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
}
